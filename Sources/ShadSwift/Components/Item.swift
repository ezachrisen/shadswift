import SwiftUI

/// The three Item treatments.
public enum ShadItemVariant: String, CaseIterable, Sendable {
    /// Transparent background with no border.
    case `default`
    /// Hairline border and rounded corners.
    case outline
    /// A muted background for secondary content.
    case muted
}

/// Item density.
public enum ShadItemSize: String, CaseIterable, Sendable {
    case `default`
    case sm
    case xs

    var padding: EdgeInsets {
        switch self {
        case .default: return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        case .sm: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        case .xs: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        }
    }

    var gap: CGFloat {
        switch self {
        case .default: return 16
        case .sm: return 10
        case .xs: return 8
        }
    }
}

/// A flex row for a title, a description and some actions.
///
/// `Item` is deliberately dumber than ``ShadField``: it lays content out, it
/// does not manage a form control.
///
/// ```swift
/// ShadItem(variant: .outline) {
///     ShadItemMedia(icon: .bell)
///     ShadItemContent {
///         ShadItemTitle("Notifications")
///         ShadItemDescription("You have 3 unread messages.")
///     }
///     ShadItemActions {
///         ShadButton("View", variant: .outline, size: .sm) {}
///     }
/// }
/// ```
public struct ShadItem<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    private let variant: ShadItemVariant
    private let size: ShadItemSize
    private let action: (() -> Void)?
    private let content: Content
    private var header: AnyView?
    private var footer: AnyView?

    @State private var isHovering = false

    public init(
        variant: ShadItemVariant = .default,
        size: ShadItemSize = .default,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.action = action
        self.content = content()
    }

    /// Content rendered above the main row.
    public func header<H: View>(@ViewBuilder _ builder: () -> H) -> ShadItem {
        var copy = self
        copy.header = AnyView(builder())
        return copy
    }

    /// Content rendered below the main row.
    public func footer<F: View>(@ViewBuilder _ builder: () -> F) -> ShadItem {
        var copy = self
        copy.footer = AnyView(builder())
        return copy
    }

    private var background: Color {
        switch variant {
        case .default: return isHovering && action != nil ? theme.colors.accent : .clear
        case .outline: return isHovering && action != nil ? theme.colors.accent : theme.colors.background
        case .muted: return theme.colors.muted.opacity(isHovering && action != nil ? 0.9 : 0.5)
        }
    }

    private var border: Color? {
        variant == .outline ? theme.colors.border : nil
    }

    public var body: some View {
        let body = VStack(alignment: .leading, spacing: size.gap * 0.5) {
            if let header {
                header
                    .font(theme.font(theme.typography.xs, theme.typography.medium))
                    .foregroundStyle(theme.colors.mutedForeground)
            }
            HStack(alignment: .center, spacing: size.gap) {
                content
            }
            if let footer {
                footer
                    .font(theme.font(theme.typography.xs))
                    .foregroundStyle(theme.colors.mutedForeground)
            }
        }
        .padding(size.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadSurfaceStyle(
            fill: background,
            border: border,
            borderWidth: theme.borderWidth,
            cornerRadius: variant == .default ? theme.radius.md : theme.radius.lg
        )
        .animation(theme.interactionAnimation, value: isHovering)

        if let action {
            Button(action: action) { body }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadHover($isHovering)
                .shadPointerCursor()
        } else {
            body
        }
    }
}

/// The leading slot: an icon, an avatar or an image.
public struct ShadItemMedia<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    /// How the media slot is framed.
    public enum Variant: String, CaseIterable, Sendable {
        /// No chrome — for avatars and images.
        case `default`
        /// A muted rounded square behind an icon.
        case icon
        /// A rounded rectangle sized for artwork.
        case image
    }

    private let variant: Variant
    private let size: CGFloat
    private let content: Content

    public init(variant: Variant = .default, size: CGFloat = 40, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.size = size
        self.content = content()
    }

    public var body: some View {
        Group {
            switch variant {
            case .default:
                content
            case .icon:
                content
                    .foregroundStyle(theme.colors.foreground)
                    .frame(width: size * 0.8, height: size * 0.8)
                    .background(
                        ShadRoundedRectangle(cornerRadius: theme.radius.md)
                            .fill(theme.colors.muted)
                    )
                    .overlay(
                        ShadRoundedRectangle(cornerRadius: theme.radius.md)
                            .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
                    )
            case .image:
                content
                    .frame(width: size, height: size)
                    .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.md))
            }
        }
    }
}

extension ShadItemMedia where Content == ShadIconView {
    /// An icon in a muted rounded square.
    public init(icon: ShadIcon, size: CGFloat = 40, iconSize: CGFloat = 16) {
        self.init(variant: .icon, size: size) { ShadIconView(icon, size: iconSize) }
    }
}

/// Wraps an item's title and description and absorbs the free horizontal space
/// so trailing actions stay pinned to the right.
public struct ShadItemContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// An item's primary line of text.
public struct ShadItemTitle: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm, theme.typography.medium))
            .foregroundStyle(theme.colors.foreground)
    }
}

/// An item's supporting line of text.
public struct ShadItemDescription: View {
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

/// The trailing slot for buttons and other controls.
public struct ShadItemActions<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: spacing) { content }
    }
}

/// Stacks items with consistent spacing, optionally as one bordered card.
public struct ShadItemGroup<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let spacing: CGFloat
    private let isBordered: Bool
    private let content: Content

    public init(spacing: CGFloat = 0, isBordered: Bool = false, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.isBordered = isBordered
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
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

/// A divider between grouped items.
public struct ShadItemSeparator: View {
    public init() {}
    public var body: some View { ShadSeparator() }
}
