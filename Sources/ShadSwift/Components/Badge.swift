import SwiftUI

/// The badge treatments, matching shadcn's `badgeVariants`.
public enum ShadBadgeVariant: String, CaseIterable, Sendable {
    case `default`
    case secondary
    /// A soft destructive wash with destructive text.
    case destructive
    case outline
    case ghost
    case link
}

/// A ready-made tinted palette, mirroring the "Custom Colors" example in the
/// shadcn docs (Tailwind's `bg-{hue}-50 text-{hue}-700`, flipped to
/// `bg-{hue}-950 text-{hue}-300` in dark mode).
public struct ShadBadgeColor: Sendable, Hashable {
    public var lightBackground: Color
    public var lightForeground: Color
    public var darkBackground: Color
    public var darkForeground: Color

    public init(lightBackground: Color, lightForeground: Color, darkBackground: Color, darkForeground: Color) {
        self.lightBackground = lightBackground
        self.lightForeground = lightForeground
        self.darkBackground = darkBackground
        self.darkForeground = darkForeground
    }

    func background(_ scheme: ColorScheme) -> Color { scheme == .dark ? darkBackground : lightBackground }
    func foreground(_ scheme: ColorScheme) -> Color { scheme == .dark ? darkForeground : lightForeground }

    public static let blue = ShadBadgeColor(
        lightBackground: Color(oklch: 0.970, 0.014, 254.60), lightForeground: Color(oklch: 0.488, 0.243, 264.38),
        darkBackground: Color(oklch: 0.282, 0.091, 267.94), darkForeground: Color(oklch: 0.809, 0.105, 251.81)
    )
    public static let green = ShadBadgeColor(
        lightBackground: Color(oklch: 0.982, 0.018, 155.83), lightForeground: Color(oklch: 0.530, 0.150, 149.00),
        darkBackground: Color(oklch: 0.266, 0.065, 152.93), darkForeground: Color(oklch: 0.871, 0.150, 154.45)
    )
    public static let sky = ShadBadgeColor(
        lightBackground: Color(oklch: 0.977, 0.013, 236.62), lightForeground: Color(oklch: 0.504, 0.128, 245.46),
        darkBackground: Color(oklch: 0.293, 0.066, 243.16), darkForeground: Color(oklch: 0.828, 0.111, 230.32)
    )
    public static let purple = ShadBadgeColor(
        lightBackground: Color(oklch: 0.977, 0.014, 308.30), lightForeground: Color(oklch: 0.498, 0.263, 301.68),
        darkBackground: Color(oklch: 0.291, 0.149, 302.72), darkForeground: Color(oklch: 0.827, 0.119, 306.38)
    )
    public static let red = ShadBadgeColor(
        lightBackground: Color(oklch: 0.971, 0.013, 17.38), lightForeground: Color(oklch: 0.510, 0.209, 28.51),
        darkBackground: Color(oklch: 0.258, 0.092, 26.04), darkForeground: Color(oklch: 0.808, 0.114, 19.57)
    )

    /// Every built-in tint, in the order the shadcn demo shows them.
    public static let all: [(name: String, color: ShadBadgeColor)] = [
        ("blue", .blue), ("green", .green), ("sky", .sky), ("purple", .purple), ("red", .red),
    ]
}

/// Displays a badge, or a component that looks like one.
///
/// Badges are pills — shadcn's `rounded-4xl` — 20pt tall with `text-xs` labels.
///
/// ```swift
/// ShadBadge("Badge")
/// ShadBadge("Verified", variant: .secondary, icon: .circleCheck)
/// ShadBadge("Blue", color: .blue)
/// ShadBadge { ShadSpinner(size: 10); Text("Syncing") }
/// ```
public struct ShadBadge<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    private let variant: ShadBadgeVariant
    private let shape: ShadButtonShape
    private let color: ShadBadgeColor?
    private let content: Content

    public init(
        variant: ShadBadgeVariant = .default,
        shape: ShadButtonShape = .pill,
        color: ShadBadgeColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.shape = shape
        self.color = color
        self.content = content()
    }

    private var colors: ShadColors { theme.colors }
    private var isDark: Bool { theme.colorScheme == .dark }

    private var background: Color {
        if let color { return color.background(theme.colorScheme) }
        switch variant {
        case .default: return colors.primary
        case .secondary: return colors.secondary
        case .destructive: return colors.destructive.opacity(isDark ? 0.20 : 0.10)
        case .outline, .ghost, .link: return .clear
        }
    }

    private var foreground: Color {
        if let color { return color.foreground(theme.colorScheme) }
        switch variant {
        case .default: return colors.primaryForeground
        case .secondary: return colors.secondaryForeground
        case .destructive: return colors.destructive
        case .outline: return colors.foreground
        case .ghost: return colors.mutedForeground
        case .link: return colors.primary
        }
    }

    private var border: Color? {
        color == nil && variant == .outline ? colors.border : nil
    }

    private var cornerRadius: CGFloat {
        switch shape {
        case .pill: return theme.radius.full
        case .rounded: return theme.radius.md
        case .square: return 0
        }
    }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
        .font(theme.font(theme.typography.xs, theme.typography.medium))
        .foregroundStyle(foreground)
        .shadIf(variant == .link) { $0.underline() }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .frame(height: 20)
        .shadSurfaceStyle(
            fill: background,
            border: border,
            borderWidth: theme.borderWidth,
            cornerRadius: cornerRadius
        )
        .fixedSize()
    }
}

extension ShadBadge where Content == ShadBadgeLabel {
    /// A badge with a title and optional leading/trailing icons.
    public init(
        _ title: String,
        variant: ShadBadgeVariant = .default,
        shape: ShadButtonShape = .pill,
        color: ShadBadgeColor? = nil,
        icon: ShadIcon? = nil,
        trailingIcon: ShadIcon? = nil
    ) {
        self.init(variant: variant, shape: shape, color: color) {
            ShadBadgeLabel(title: title, icon: icon, trailingIcon: trailingIcon)
        }
    }
}

/// The default badge label.
public struct ShadBadgeLabel: View {
    let title: String
    var icon: ShadIcon? = nil
    var trailingIcon: ShadIcon? = nil

    public var body: some View {
        HStack(spacing: 4) {
            if let icon { ShadIconView(icon, size: 12) }
            Text(title)
            if let trailingIcon { ShadIconView(trailingIcon, size: 12) }
        }
    }
}

/// A small solid dot used to tint a badge with a status colour.
public struct ShadBadgeDot: View {
    private let color: Color
    private let size: CGFloat

    public init(_ color: Color, size: CGFloat = 6) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        Circle().fill(color).frame(width: size, height: size)
    }
}

/// A badge that behaves as a link: the solid `default` treatment with a
/// trailing arrow, which is what shadcn's "Link" example renders.
public struct ShadBadgeLink: View {
    @Environment(\.shadTheme) private var theme
    @State private var isHovering = false

    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ShadBadge(variant: .default) {
                Text(title)
                ShadIconView(.arrowUpRight, size: 12)
            }
            .opacity(isHovering ? 0.8 : 1)
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering)
        .shadPointerCursor()
        .animation(theme.interactionAnimation, value: isHovering)
    }
}
