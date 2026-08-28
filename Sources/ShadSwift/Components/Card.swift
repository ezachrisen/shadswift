import SwiftUI

private struct ShadCardSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 24
}

extension EnvironmentValues {
    /// The `--card-spacing` value for the current card. Header, content and
    /// footer all read it so a card's padding stays consistent.
    public var shadCardSpacing: CGFloat {
        get { self[ShadCardSpacingKey.self] }
        set { self[ShadCardSpacingKey.self] = newValue }
    }
}

/// Card sizes. `sm` tightens `--card-spacing` from 24pt to 16pt.
public enum ShadCardSize: String, CaseIterable, Sendable {
    case `default`
    case sm

    var spacing: CGFloat {
        switch self {
        case .default: return 24
        case .sm: return 16
        }
    }
}

/// The root card container.
///
/// ```swift
/// ShadCard {
///     ShadCardHeader {
///         ShadCardTitle("Login to your account")
///         ShadCardDescription("Enter your email below")
///     }
///     ShadCardContent { … }
///     ShadCardFooter { ShadButton("Login", fillsWidth: true) {} }
/// }
/// ```
public struct ShadCard<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    private let size: ShadCardSize
    private let spacingOverride: CGFloat?
    private let content: Content

    public init(
        size: ShadCardSize = .default,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.spacingOverride = spacing
        self.content = content()
    }

    private var spacing: CGFloat { spacingOverride ?? size.spacing }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .environment(\.shadCardSpacing, spacing)
        .padding(.vertical, spacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(theme.colors.cardForeground)
        .shadSurfaceStyle(
            fill: theme.colors.card,
            border: theme.colors.border,
            borderWidth: theme.borderWidth,
            cornerRadius: theme.radius.xl,
            shadow: theme.shadows.sm
        )
    }
}

/// The card's heading area. Pass `action` to place a control in the top-right,
/// which is shadcn's `CardAction` slot.
public struct ShadCardHeader<Content: View, Action: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadCardSpacing) private var spacing

    private let showsSeparator: Bool
    private let content: Content
    private let action: Action

    public init(
        showsSeparator: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action
    ) {
        self.showsSeparator = showsSeparator
        self.content = content()
        self.action = action()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                action
            }
            .padding(.horizontal, spacing)

            if showsSeparator {
                ShadSeparator().padding(.top, spacing)
            }
        }
    }
}

extension ShadCardHeader where Action == EmptyView {
    public init(showsSeparator: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(showsSeparator: showsSeparator, content: content, action: { EmptyView() })
    }
}

/// The card's primary heading text.
public struct ShadCardTitle: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.base, theme.typography.semibold))
            .foregroundStyle(theme.colors.cardForeground)
    }
}

/// Helper text under the title.
public struct ShadCardDescription: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.mutedForeground)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// The card's main body.
public struct ShadCardContent<Content: View>: View {
    @Environment(\.shadCardSpacing) private var spacing
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, spacing)
    }
}

/// Actions and secondary content at the bottom of a card.
public struct ShadCardFooter<Content: View>: View {
    @Environment(\.shadCardSpacing) private var spacing
    private let showsSeparator: Bool
    private let content: Content

    public init(showsSeparator: Bool = false, @ViewBuilder content: () -> Content) {
        self.showsSeparator = showsSeparator
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            if showsSeparator {
                ShadSeparator().padding(.bottom, spacing)
            }
            HStack(spacing: 8) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, spacing)
        }
    }
}
