import SwiftUI

/// The three marker layouts.
public enum ShadMarkerVariant: String, CaseIterable, Sendable {
    /// An inline marker for status, notes and actions.
    case `default`
    /// A default marker with a rule underneath, separating rows.
    case border
    /// A centred label with divider lines on each side.
    case separator
}

/// An inline status, system note, bordered row or labelled separator in a
/// conversation. Designed to compose with ``ShadMessage``.
///
/// ```swift
/// ShadMarker {
///     ShadMarkerIcon(.check)
///     ShadMarkerContent("Explored 4 files")
/// }
///
/// ShadMarker(variant: .separator) {
///     ShadMarkerContent("Today")
/// }
/// ```
public struct ShadMarker<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let variant: ShadMarkerVariant
    private let action: (() -> Void)?
    private let content: Content

    public init(
        variant: ShadMarkerVariant = .default,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { row }
                    .buttonStyle(.shadPlain)
                    .focusEffectDisabled()
                    .shadHover($isHovering, enabled: isEnabled)
                    .shadPointerCursor(isEnabled)
            } else {
                row
            }
        }
        .animation(theme.interactionAnimation, value: isHovering)
    }

    @ViewBuilder
    private var row: some View {
        switch variant {
        case .default:
            inline
        case .border:
            VStack(alignment: .leading, spacing: 0) {
                inline
                ShadSeparator().padding(.top, 8)
            }
        case .separator:
            HStack(spacing: 12) {
                ShadSeparator()
                HStack(spacing: 6) { content }
                    .font(theme.font(theme.typography.xs))
                    .foregroundStyle(theme.colors.mutedForeground)
                    .fixedSize()
                ShadSeparator()
            }
        }
    }

    private var inline: some View {
        HStack(spacing: 6) {
            content
        }
        .font(theme.font(theme.typography.xs))
        .foregroundStyle(isHovering && action != nil ? theme.colors.foreground : theme.colors.mutedForeground)
        .shadIf(action != nil && isHovering) { $0.underline() }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

/// The decorative icon slot, hidden from assistive technology.
public struct ShadMarkerIcon<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .accessibilityHidden(true)
    }
}

extension ShadMarkerIcon where Content == ShadIconView {
    public init(_ icon: ShadIcon, size: CGFloat = 14) {
        self.init { ShadIconView(icon, size: size) }
    }
}

/// The marker's text.
public struct ShadMarkerContent<Content: View>: View {
    private let content: Content
    private let shimmer: Bool

    public init(shimmer: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.shimmer = shimmer
    }

    public var body: some View {
        content
            .shadIf(shimmer) { $0.shadShimmer() }
    }
}

extension ShadMarkerContent where Content == Text {
    public init(_ text: String, shimmer: Bool = false) {
        self.init(shimmer: shimmer) { Text(text) }
    }
}

/// The animated sweep shadcn uses for streaming text.
struct ShadShimmerModifier: ViewModifier {
    @Environment(\.shadTheme) private var theme
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [.clear, theme.colors.foreground.opacity(0.75), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.6)
                    .offset(x: phase * proxy.size.width * 1.6)
                    .blendMode(.plusLighter)
                }
                .mask(content)
                .allowsHitTesting(false)
            }
            .onAppear {
                guard theme.motion.isEnabled else { return }
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Sweeps a highlight across this view, for streaming status text.
    public func shadShimmer() -> some View {
        modifier(ShadShimmerModifier())
    }
}
