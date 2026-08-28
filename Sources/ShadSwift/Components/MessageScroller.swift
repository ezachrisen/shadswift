import SwiftUI

/// Where a transcript opens.
public enum ShadScrollPosition: String, CaseIterable, Sendable {
    /// The very bottom — the live edge.
    case end
    /// The very top.
    case start
    /// The last anchored turn, so a reopened thread starts somewhere useful.
    case lastAnchor
}

/// Owns scroll state for a transcript: auto-scroll, anchoring, visibility and
/// position preservation when history is prepended.
///
/// Reach it from anywhere below a ``ShadMessageScrollerProvider`` with
/// `@Environment(\.shadMessageScroller)`.
@MainActor
public final class ShadMessageScrollerModel: ObservableObject {
    /// Follow the live edge while new turns stream in.
    @Published public var autoScroll: Bool
    /// True while the last row is on screen.
    @Published public private(set) var isAtEnd = true
    /// True while the first row is on screen.
    @Published public private(set) var isAtStart = false
    /// Every row currently on screen.
    @Published public private(set) var visibleMessageIds: Set<AnyHashable> = []
    /// The anchored row nearest the top of the viewport.
    @Published public private(set) var currentAnchorId: AnyHashable?

    /// Where the transcript opens the first time it lays out.
    public var defaultScrollPosition: ShadScrollPosition
    /// Points of the previous row left visible when an anchor scrolls up.
    public var scrollPreviousItemPeek: CGFloat
    /// Keep the reader in place when older messages are inserted at the top.
    public var preserveScrollOnPrepend: Bool

    /// Called when the reader reaches the top, for loading older history.
    public var onReachStart: (() -> Void)?

    private(set) var ids: [AnyHashable] = []
    private var anchorIds: Set<AnyHashable> = []
    private var hasPerformedInitialScroll = false
    var viewportHeight: CGFloat = 400
    weak var proxyBox: ShadScrollProxyBox?

    public init(
        autoScroll: Bool = true,
        defaultScrollPosition: ShadScrollPosition = .end,
        scrollPreviousItemPeek: CGFloat = 0,
        preserveScrollOnPrepend: Bool = true
    ) {
        self.autoScroll = autoScroll
        self.defaultScrollPosition = defaultScrollPosition
        self.scrollPreviousItemPeek = scrollPreviousItemPeek
        self.preserveScrollOnPrepend = preserveScrollOnPrepend
    }

    // MARK: Public API

    /// Scrolls a specific message into view.
    public func scrollToMessage(_ id: AnyHashable, anchor: UnitPoint = .top, animated: Bool = true) {
        perform(animated: animated) { $0.scrollTo(id, anchor: anchor) }
    }

    /// Scrolls to the live edge.
    public func scrollToEnd(animated: Bool = true) {
        perform(animated: animated) { $0.scrollTo(ShadMessageScrollerEdge.end, anchor: .bottom) }
    }

    /// Scrolls to the oldest message.
    public func scrollToStart(animated: Bool = true) {
        perform(animated: animated) { $0.scrollTo(ShadMessageScrollerEdge.start, anchor: .top) }
    }

    /// Whether scrolling is possible in each direction.
    public var scrollable: (start: Bool, end: Bool) {
        (start: !isAtStart, end: !isAtEnd)
    }

    // MARK: Internal wiring

    func registerAnchor(_ id: AnyHashable, isAnchor: Bool) {
        if isAnchor {
            anchorIds.insert(id)
        } else {
            anchorIds.remove(id)
        }
    }

    func updateIds(_ newIds: [AnyHashable]) {
        let previous = ids
        ids = newIds
        guard !newIds.isEmpty else { return }

        if !hasPerformedInitialScroll {
            hasPerformedInitialScroll = true
            performInitialScroll()
            return
        }

        // Older history inserted above: hold the reader's place.
        if preserveScrollOnPrepend,
           let previousFirst = previous.first,
           let newIndex = newIds.firstIndex(of: previousFirst),
           newIndex > 0 {
            scrollToMessage(previousFirst, anchor: .top, animated: false)
            return
        }

        // New turn appended.
        if let last = newIds.last, previous.last != last {
            if anchorIds.contains(last) {
                scrollToAnchor(last)
            } else if autoScroll, isAtEnd {
                scrollToEnd()
            }
        }
    }

    private func performInitialScroll() {
        switch defaultScrollPosition {
        case .end:
            scrollToEnd(animated: false)
        case .start:
            scrollToStart(animated: false)
        case .lastAnchor:
            if let anchor = ids.last(where: { anchorIds.contains($0) }) {
                scrollToAnchor(anchor, animated: false)
            } else {
                scrollToEnd(animated: false)
            }
        }
    }

    /// Puts an anchored row near the top, leaving `scrollPreviousItemPeek`
    /// points of the previous row visible.
    func scrollToAnchor(_ id: AnyHashable, animated: Bool = true) {
        let fraction = viewportHeight > 0
            ? min(0.5, max(0, scrollPreviousItemPeek / viewportHeight))
            : 0
        perform(animated: animated) { $0.scrollTo(id, anchor: UnitPoint(x: 0, y: fraction)) }
        currentAnchorId = id
    }

    func setVisible(_ id: AnyHashable, _ visible: Bool) {
        if visible {
            visibleMessageIds.insert(id)
            if anchorIds.contains(id) { currentAnchorId = id }
        } else {
            visibleMessageIds.remove(id)
        }
    }

    func setAtEnd(_ value: Bool) {
        guard isAtEnd != value else { return }
        isAtEnd = value
    }

    func setAtStart(_ value: Bool) {
        guard isAtStart != value else { return }
        isAtStart = value
        if value { onReachStart?() }
    }

    private func perform(animated: Bool, _ body: @escaping (ScrollViewProxy) -> Void) {
        guard let proxy = proxyBox?.proxy else { return }
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.25)) { body(proxy) }
            } else {
                body(proxy)
            }
        }
    }
}

/// Sentinel ids used for the invisible rows at either end of the transcript.
enum ShadMessageScrollerEdge: Hashable {
    case start
    case end
}

/// Holds the `ScrollViewProxy` so the model can reach it without owning a View.
final class ShadScrollProxyBox {
    var proxy: ScrollViewProxy?
}

private struct ShadMessageScrollerKey: EnvironmentKey {
    @MainActor static var defaultValue: ShadMessageScrollerModel? { nil }
}

extension EnvironmentValues {
    /// The enclosing transcript's model.
    public var shadMessageScroller: ShadMessageScrollerModel? {
        get { self[ShadMessageScrollerKey.self] }
        set { self[ShadMessageScrollerKey.self] = newValue }
    }
}

/// Supplies scroll state to everything below it.
public struct ShadMessageScrollerProvider<Content: View>: View {
    @ObservedObject private var model: ShadMessageScrollerModel
    private let content: Content

    public init(_ model: ShadMessageScrollerModel, @ViewBuilder content: () -> Content) {
        self.model = model
        self.content = content()
    }

    public var body: some View {
        content.environment(\.shadMessageScroller, model)
    }
}

/// The framed transcript: viewport plus its controls.
public struct ShadMessageScroller<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let isBordered: Bool
    private let content: Content

    public init(isBordered: Bool = false, @ViewBuilder content: () -> Content) {
        self.isBordered = isBordered
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadIf(isBordered) { view in
            view.shadSurfaceStyle(
                fill: theme.colors.background,
                border: theme.colors.border,
                borderWidth: theme.borderWidth,
                cornerRadius: theme.radius.lg
            )
        }
    }
}

/// The scrolling element. It reports its height so anchoring can leave the
/// configured peek of the previous row visible.
public struct ShadMessageScrollerViewport<Content: View>: View {
    @Environment(\.shadMessageScroller) private var model
    private let content: Content
    @State private var proxyBox = ShadScrollProxyBox()

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ShadScrollContainer {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 1)
                            .id(ShadMessageScrollerEdge.start)
                            .onAppear { model?.setAtStart(true) }
                            .onDisappear { model?.setAtStart(false) }

                        content

                        Color.clear
                            .frame(height: 1)
                            .id(ShadMessageScrollerEdge.end)
                            .onAppear { model?.setAtEnd(true) }
                            .onDisappear { model?.setAtEnd(false) }
                    }
                }
                .onAppear {
                    proxyBox.proxy = scrollProxy
                    model?.proxyBox = proxyBox
                    model?.viewportHeight = proxy.size.height
                }
                .onChange(of: proxy.size.height) { _, height in
                    model?.viewportHeight = height
                }
            }
        }
    }
}

/// The transcript container. `ids` is the ordered list of message ids, which
/// is what lets the scroller tell an append from a prepend.
public struct ShadMessageScrollerContent<Content: View>: View {
    @Environment(\.shadMessageScroller) private var model

    private let ids: [AnyHashable]
    private let spacing: CGFloat
    private let content: Content

    public init<ID: Hashable>(ids: [ID], spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.ids = ids.map { AnyHashable($0) }
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        ShadLazyVStack(spacing: spacing) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { model?.updateIds(ids) }
        .onChange(of: ids) { _, newIds in model?.updateIds(newIds) }
        .accessibilityLabel("Conversation")
    }
}

/// A row boundary: gives the scroller something to measure, anchor and jump to.
public struct ShadMessageScrollerItem<ID: Hashable, Content: View>: View {
    @Environment(\.shadMessageScroller) private var model

    private let id: ID
    private let scrollAnchor: Bool
    private let content: Content

    public init(messageId: ID, scrollAnchor: Bool = false, @ViewBuilder content: () -> Content) {
        self.id = messageId
        self.scrollAnchor = scrollAnchor
        self.content = content()
    }

    public var body: some View {
        content
            .id(AnyHashable(id))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                model?.registerAnchor(AnyHashable(id), isAnchor: scrollAnchor)
                model?.setVisible(AnyHashable(id), true)
            }
            .onDisappear { model?.setVisible(AnyHashable(id), false) }
    }
}

/// The floating control that jumps to the live edge.
public struct ShadMessageScrollerButton: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadMessageScroller) private var model

    private let edge: Edge
    private let title: String?

    /// Which end the button scrolls to.
    public enum Edge: String, Sendable { case start, end }

    public init(edge: Edge = .end, title: String? = nil) {
        self.edge = edge
        self.title = title
    }

    private var isVisible: Bool {
        guard let model else { return false }
        return edge == .end ? !model.isAtEnd : !model.isAtStart
    }

    public var body: some View {
        Group {
            if isVisible {
                Button {
                    if edge == .end { model?.scrollToEnd() } else { model?.scrollToStart() }
                } label: {
                    HStack(spacing: 6) {
                        ShadIconView(edge == .end ? .arrowDown : .arrowUp, size: 14)
                        if let title { Text(title).font(theme.font(theme.typography.xs, theme.typography.medium)) }
                    }
                    .foregroundStyle(theme.colors.popoverForeground)
                    .padding(.horizontal, title == nil ? 8 : 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.colors.popover))
                    .overlay(Capsule().strokeBorder(theme.colors.border, lineWidth: theme.borderWidth))
                    .background(Capsule().fill(theme.colors.popover).shadShadow(theme.shadows.md))
                }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadPointerCursor()
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityLabel(edge == .end ? "Scroll to latest" : "Scroll to oldest")
            }
        }
        .animation(theme.presentationAnimation, value: isVisible)
    }
}
