import SwiftUI
import Combine

/// The status types a toast can carry. Each renders its own icon and colour.
public enum ShadToastType: String, CaseIterable, Sendable {
    case normal
    case success
    case error
    case warning
    case info
    case loading

    func icon(_ colors: ShadColors) -> (ShadIcon, Color)? {
        switch self {
        case .normal, .loading: return nil
        case .success: return (.circleCheck, colors.success)
        case .error: return (.circleX, colors.destructive)
        case .warning: return (.triangleAlert, colors.warning)
        case .info: return (.info, colors.info)
        }
    }
}

/// Where the stack of toasts sits in the window.
public enum ShadToastPosition: String, CaseIterable, Sendable {
    case topLeading
    case topCenter
    case topTrailing
    case bottomLeading
    case bottomCenter
    case bottomTrailing

    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topCenter: return .top
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomCenter: return .bottom
        case .bottomTrailing: return .bottomTrailing
        }
    }

    var isTop: Bool {
        self == .topLeading || self == .topCenter || self == .topTrailing
    }

    var isTrailing: Bool {
        self == .topTrailing || self == .bottomTrailing
    }
}

/// One toast. Create them through ``ShadToastCenter``, not directly.
public struct ShadToast: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var type: ShadToastType
    public var duration: TimeInterval?
    public var actionTitle: String?
    public var actionHandler: (() -> Void)?
    public var isDismissible: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        type: ShadToastType = .normal,
        duration: TimeInterval? = 4,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil,
        isDismissible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.duration = duration
        self.actionTitle = actionTitle
        self.actionHandler = actionHandler
        self.isDismissible = isDismissible
    }

    public static func == (lhs: ShadToast, rhs: ShadToast) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.description == rhs.description
            && lhs.type == rhs.type
    }
}

/// Owns the queue of visible toasts.
///
/// ```swift
/// @StateObject private var toast = ShadToastCenter()
/// …
/// ContentView().shadToaster(toast)
/// …
/// toast.success("Event created", description: "Sunday, December 3 at 9:00 AM")
/// ```
@MainActor
public final class ShadToastCenter: ObservableObject {
    @Published public private(set) var toasts: [ShadToast] = []

    /// Most toasts visible at once. Older ones are dropped from the back.
    public var limit: Int
    /// Default lifetime for toasts that do not specify one.
    public var defaultDuration: TimeInterval

    private var timers: [UUID: Task<Void, Never>] = [:]

    public init(limit: Int = 3, defaultDuration: TimeInterval = 4) {
        self.limit = limit
        self.defaultDuration = defaultDuration
    }

    // MARK: Adding

    @discardableResult
    public func add(_ toast: ShadToast) -> UUID {
        toasts.insert(toast, at: 0)
        if toasts.count > limit {
            for dropped in toasts[limit...] { cancelTimer(dropped.id) }
            toasts = Array(toasts.prefix(limit))
        }
        scheduleDismissal(for: toast)
        return toast.id
    }

    @discardableResult
    public func add(
        title: String,
        description: String? = nil,
        type: ShadToastType = .normal,
        duration: TimeInterval? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> UUID {
        add(ShadToast(
            title: title,
            description: description,
            type: type,
            duration: duration ?? (type == .loading ? nil : defaultDuration),
            actionTitle: actionTitle,
            actionHandler: action
        ))
    }

    @discardableResult
    public func success(_ title: String, description: String? = nil, duration: TimeInterval? = nil) -> UUID {
        add(title: title, description: description, type: .success, duration: duration)
    }

    @discardableResult
    public func error(_ title: String, description: String? = nil, duration: TimeInterval? = nil) -> UUID {
        add(title: title, description: description, type: .error, duration: duration)
    }

    @discardableResult
    public func warning(_ title: String, description: String? = nil, duration: TimeInterval? = nil) -> UUID {
        add(title: title, description: description, type: .warning, duration: duration)
    }

    @discardableResult
    public func info(_ title: String, description: String? = nil, duration: TimeInterval? = nil) -> UUID {
        add(title: title, description: description, type: .info, duration: duration)
    }

    @discardableResult
    public func loading(_ title: String, description: String? = nil) -> UUID {
        add(title: title, description: description, type: .loading, duration: nil)
    }

    /// Updates an existing toast in place — the mechanism behind ``promise(_:loading:success:failure:)``.
    public func update(
        _ id: UUID,
        title: String? = nil,
        description: String? = nil,
        type: ShadToastType? = nil,
        duration: TimeInterval? = nil
    ) {
        guard let index = toasts.firstIndex(where: { $0.id == id }) else { return }
        if let title { toasts[index].title = title }
        if let description { toasts[index].description = description }
        if let type { toasts[index].type = type }
        toasts[index].duration = duration ?? defaultDuration
        cancelTimer(id)
        scheduleDismissal(for: toasts[index])
    }

    /// Drives one toast through loading → success or error.
    @discardableResult
    public func promise<T>(
        _ operation: @escaping () async throws -> T,
        loading loadingTitle: String,
        success: @escaping (T) -> String,
        failure: @escaping (Error) -> String
    ) -> UUID {
        let id = loading(loadingTitle)
        Task { @MainActor in
            do {
                let value = try await operation()
                update(id, title: success(value), type: .success)
            } catch {
                update(id, title: failure(error), type: .error)
            }
        }
        return id
    }

    // MARK: Removing

    public func close(_ id: UUID) {
        cancelTimer(id)
        toasts.removeAll { $0.id == id }
    }

    public func closeAll() {
        for toast in toasts { cancelTimer(toast.id) }
        toasts.removeAll()
    }

    /// Suspends auto-dismissal, e.g. while the pointer is over the stack.
    public func pauseTimers() {
        for (id, task) in timers {
            task.cancel()
            timers[id] = nil
        }
    }

    /// Restarts auto-dismissal for everything still on screen.
    public func resumeTimers() {
        for toast in toasts where timers[toast.id] == nil {
            scheduleDismissal(for: toast)
        }
    }

    private func scheduleDismissal(for toast: ShadToast) {
        guard let duration = toast.duration, duration > 0 else { return }
        let id = toast.id
        timers[id] = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.close(id)
        }
    }

    private func cancelTimer(_ id: UUID) {
        timers[id]?.cancel()
        timers[id] = nil
    }
}

extension View {
    /// Renders `center`'s toasts over this view. Attach it once, at the root.
    public func shadToaster(
        _ center: ShadToastCenter,
        position: ShadToastPosition = .bottomTrailing,
        expandsOnHover: Bool = true
    ) -> some View {
        modifier(ShadToaster(center: center, position: position, expandsOnHover: expandsOnHover))
    }
}

private struct ShadToaster: ViewModifier {
    @ObservedObject var center: ShadToastCenter
    let position: ShadToastPosition
    let expandsOnHover: Bool

    @Environment(\.shadTheme) private var theme
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content.overlay(alignment: position.alignment) {
            ZStack(alignment: position.alignment) {
                ForEach(Array(center.toasts.enumerated()), id: \.element.id) { index, toast in
                    ShadToastView(toast: toast, onClose: { center.close(toast.id) })
                        .zIndex(Double(center.toasts.count - index))
                        .offset(y: offset(for: index))
                        .scaleEffect(scale(for: index), anchor: position.isTop ? .top : .bottom)
                        .opacity(index < 3 ? 1 : 0)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: position.isTop ? .top : .bottom).combined(with: .opacity),
                                removal: .opacity.combined(with: .scale(scale: 0.9))
                            )
                        )
                }
            }
            .padding(16)
            .animation(theme.presentationAnimation, value: center.toasts.map(\.id))
            .animation(theme.presentationAnimation, value: isHovering)
            .onHover { hovering in
                isHovering = hovering
                if hovering { center.pauseTimers() } else { center.resumeTimers() }
            }
        }
    }

    private var isExpanded: Bool { expandsOnHover && isHovering }

    private func offset(for index: Int) -> CGFloat {
        let direction: CGFloat = position.isTop ? 1 : -1
        if isExpanded {
            var total: CGFloat = 0
            for i in 0..<index { total += estimatedHeight(center.toasts[i]) + 10 }
            return direction * total
        }
        return direction * CGFloat(index) * 12
    }

    private func estimatedHeight(_ toast: ShadToast) -> CGFloat {
        toast.description == nil ? 56 : 76
    }

    private func scale(for index: Int) -> CGFloat {
        isExpanded ? 1 : max(0.88, 1 - CGFloat(index) * 0.05)
    }
}

/// The visual for a single toast.
public struct ShadToastView: View {
    @Environment(\.shadTheme) private var theme
    private let toast: ShadToast
    private let onClose: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isHovering = false

    public init(toast: ShadToast, onClose: @escaping () -> Void) {
        self.toast = toast
        self.onClose = onClose
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 4) {
                Text(toast.title)
                    .font(theme.font(theme.typography.sm, theme.typography.medium))
                    .foregroundStyle(theme.colors.popoverForeground)
                if let description = toast.description {
                    Text(description)
                        .font(theme.font(theme.typography.xs))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle = toast.actionTitle {
                ShadButton(actionTitle, variant: .outline, size: .xs) {
                    toast.actionHandler?()
                    onClose()
                }
            }
            if toast.isDismissible {
                Button(action: onClose) {
                    ShadIconView(.x, size: 14)
                        .foregroundStyle(theme.colors.mutedForeground)
                        .opacity(isHovering ? 1 : 0.7)
                }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadPointerCursor()
                .accessibilityLabel("Close")
            }
        }
        .padding(16)
        .frame(width: 372, alignment: .leading)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(theme.colors.popover)
        )
        .overlay(
            ShadRoundedRectangle(cornerRadius: theme.radius.xl)
                .strokeBorder(theme.colors.foreground.opacity(0.08), lineWidth: theme.borderWidth)
        )
        .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.xl))
        .shadElevation(theme.shadows.lg, cornerRadius: theme.radius.xl, fill: theme.colors.popover)
        .offset(x: dragOffset)
        .opacity(1 - min(1, abs(dragOffset) / 220))
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation.width }
                .onEnded { value in
                    if abs(value.translation.width) > 90 {
                        onClose()
                    } else {
                        withAnimation(theme.presentationAnimation) { dragOffset = 0 }
                    }
                }
        )
        .shadHover($isHovering)
        .animation(theme.interactionAnimation, value: isHovering)
    }

    @ViewBuilder
    private var leading: some View {
        if toast.type == .loading {
            ShadSpinner(size: 16)
                .padding(.top, 1)
        } else if let (icon, color) = toast.type.icon(theme.colors) {
            ShadIconView(icon, size: 16)
                .foregroundStyle(color)
                .padding(.top, 1)
        }
    }
}
