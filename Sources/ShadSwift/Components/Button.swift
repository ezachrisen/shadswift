import SwiftUI

// MARK: - Variant & size

/// The six shadcn button treatments.
public enum ShadButtonVariant: String, CaseIterable, Sendable {
    /// Solid `primary` fill. The default.
    case `default`
    /// Solid `secondary` fill.
    case secondary
    /// A soft `destructive` wash with destructive text, for irreversible actions.
    case destructive
    /// Hairline border over the page background.
    case outline
    /// No fill or border until hovered.
    case ghost
    /// Renders as an inline text link.
    case link
}

/// The button size scale, including the icon-only sizes.
public enum ShadButtonSize: String, CaseIterable, Sendable {
    case xs
    case sm
    case `default`
    case lg
    case icon
    case iconXS
    case iconSM
    case iconLG

    /// True for the square, label-less sizes.
    public var isIconOnly: Bool {
        switch self {
        case .icon, .iconXS, .iconSM, .iconLG: return true
        default: return false
        }
    }

    var height: CGFloat {
        switch self {
        case .xs, .iconXS: return 24
        case .sm, .iconSM: return 28
        case .default, .icon: return 32
        case .lg, .iconLG: return 36
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .xs: return 8
        case .sm, .default, .lg: return 10
        case .icon, .iconXS, .iconSM, .iconLG: return 0
        }
    }

    var gap: CGFloat {
        switch self {
        case .xs, .sm, .iconXS, .iconSM: return 4
        default: return 6
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .xs, .iconXS: return 12
        case .sm, .iconSM: return 14
        default: return 16
        }
    }

    func fontSize(_ typography: ShadTypography) -> CGFloat {
        switch self {
        case .xs, .iconXS: return typography.xs
        case .sm, .iconSM: return typography.sm - 1.2
        default: return typography.sm
        }
    }

    /// `rounded-lg` at the two larger sizes, `rounded-md` below.
    func cornerRadius(_ radius: ShadRadius) -> CGFloat {
        switch self {
        case .xs, .iconXS, .sm, .iconSM: return radius.md
        default: return radius.lg
        }
    }
}

/// Overall shape of a button.
public enum ShadButtonShape: Sendable, Hashable {
    /// Rounded corners from the theme's radius scale.
    case rounded
    /// A pill, matching shadcn's `rounded-full` example.
    case pill
    /// Square corners.
    case square
}

// MARK: - Style

/// The `ButtonStyle` that powers ``ShadButton``.
///
/// Use it directly to give a plain SwiftUI `Button` shadcn styling:
///
/// ```swift
/// Button("Save") { save() }
///     .buttonStyle(.shad(.default, size: .sm))
/// ```
public struct ShadButtonStyle: ButtonStyle {
    public var variant: ShadButtonVariant
    public var size: ShadButtonSize
    public var shape: ShadButtonShape
    public var isLoading: Bool
    public var fillsWidth: Bool

    public init(
        variant: ShadButtonVariant = .default,
        size: ShadButtonSize = .default,
        shape: ShadButtonShape = .rounded,
        isLoading: Bool = false,
        fillsWidth: Bool = false
    ) {
        self.variant = variant
        self.size = size
        self.shape = shape
        self.isLoading = isLoading
        self.fillsWidth = fillsWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        ShadButtonSurface(
            variant: variant,
            size: size,
            shape: shape,
            isLoading: isLoading,
            fillsWidth: fillsWidth,
            isPressed: configuration.isPressed
        ) {
            configuration.label
        }
    }
}

extension ButtonStyle where Self == ShadButtonStyle {
    /// shadcn styling for a plain SwiftUI `Button`.
    public static func shad(
        _ variant: ShadButtonVariant = .default,
        size: ShadButtonSize = .default,
        shape: ShadButtonShape = .rounded,
        isLoading: Bool = false,
        fillsWidth: Bool = false
    ) -> ShadButtonStyle {
        ShadButtonStyle(variant: variant, size: size, shape: shape, isLoading: isLoading, fillsWidth: fillsWidth)
    }

    /// The default shadcn button.
    public static var shad: ShadButtonStyle { ShadButtonStyle() }
}

/// The visual chrome shared by ``ShadButton`` and ``ShadButtonStyle``.
///
/// Buttons carry no shadow — measured from shadcn, every variant is flat — and
/// they sink one point on press, which is shadcn's `active:translate-y-px`.
struct ShadButtonSurface<Label: View>: View {
    let variant: ShadButtonVariant
    let size: ShadButtonSize
    let shape: ShadButtonShape
    let isLoading: Bool
    let fillsWidth: Bool
    let isPressed: Bool
    /// Set while an attached menu is open, matching `aria-expanded`.
    var isExpanded: Bool = false
    @ViewBuilder let label: () -> Label

    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private var colors: ShadColors { theme.colors }
    private var isDark: Bool { theme.colorScheme == .dark }

    private var cornerRadius: CGFloat {
        switch shape {
        case .rounded: return size.cornerRadius(theme.radius)
        case .pill: return theme.radius.full
        case .square: return 0
        }
    }

    private var isHighlighted: Bool { isHovering || isExpanded }

    private var background: Color {
        switch variant {
        case .default:
            return isHighlighted ? colors.primary.opacity(0.8) : colors.primary
        case .secondary:
            return isHighlighted
                ? colors.secondary.shadMix(with: colors.foreground, amount: 0.05)
                : colors.secondary
        case .destructive:
            let base = isDark ? 0.20 : 0.10
            let hover = isDark ? 0.30 : 0.20
            return colors.destructive.opacity(isHighlighted ? hover : base)
        case .outline:
            return isHighlighted ? colors.muted : colors.background
        case .ghost:
            return isHighlighted ? colors.muted : .clear
        case .link:
            return .clear
        }
    }

    private var foreground: Color {
        switch variant {
        case .default: return colors.primaryForeground
        case .secondary: return colors.secondaryForeground
        case .destructive: return colors.destructive
        case .outline, .ghost: return colors.foreground
        case .link: return colors.primary
        }
    }

    private var border: Color? {
        variant == .outline ? colors.border : nil
    }

    var body: some View {
        HStack(spacing: size.gap) {
            if isLoading {
                ShadSpinner(size: size.iconSize, color: foreground)
            }
            label()
        }
        .font(theme.font(size.fontSize(theme.typography), theme.typography.medium))
        .foregroundStyle(foreground)
        .shadIf(variant == .link && isHighlighted) { $0.underline() }
        .lineLimit(1)
        .padding(.horizontal, size.horizontalPadding)
        .frame(height: variant == .link ? nil : size.height)
        .frame(width: size.isIconOnly ? size.height : nil)
        .frame(maxWidth: fillsWidth ? .infinity : nil)
        .shadSurfaceStyle(
            fill: variant == .link ? .clear : background,
            border: border,
            borderWidth: theme.borderWidth,
            cornerRadius: variant == .link ? 0 : cornerRadius
        )
        .opacity(isEnabled ? 1 : 0.5)
        // shadcn's `active:translate-y-px`.
        .offset(y: isPressed && isEnabled ? 1 : 0)
        .animation(theme.interactionAnimation, value: isHovering)
        .animation(theme.interactionAnimation, value: isPressed)
        .shadHover($isHovering, enabled: isEnabled && !isLoading)
        .shadPointerCursor(isEnabled && !isLoading)
        .contentShape(ShadRoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Button

/// Displays a button, or a component that looks like a button.
///
/// ```swift
/// ShadButton("Continue") { next() }
/// ShadButton("Delete", variant: .destructive, icon: .trash) { delete() }
/// ShadButton(icon: .settings, size: .icon) { open() }
/// ShadButton("Saving", isLoading: true) {}
/// ```
public struct ShadButton<Label: View>: View {
    private let variant: ShadButtonVariant
    private let size: ShadButtonSize
    private let shape: ShadButtonShape
    private let isLoading: Bool
    private let fillsWidth: Bool
    private let action: () -> Void
    private let label: () -> Label

    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        variant: ShadButtonVariant = .default,
        size: ShadButtonSize = .default,
        shape: ShadButtonShape = .rounded,
        isLoading: Bool = false,
        fillsWidth: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.shape = shape
        self.isLoading = isLoading
        self.fillsWidth = fillsWidth
        self.action = action
        self.label = label
    }

    private var cornerRadius: CGFloat {
        switch shape {
        case .rounded: return size.cornerRadius(theme.radius)
        case .pill: return theme.radius.full
        case .square: return 0
        }
    }

    private var ringColor: Color {
        variant == .destructive ? theme.colors.destructive : theme.colors.ring
    }

    public var body: some View {
        Button(action: { if !isLoading { action() } }, label: label)
            .buttonStyle(ShadButtonStyle(
                variant: variant,
                size: size,
                shape: shape,
                isLoading: isLoading,
                fillsWidth: fillsWidth
            ))
            .focusable(isEnabled && !isLoading)
            .focused($isFocused)
            .focusEffectDisabled()
            .shadFocusRing(cornerRadius, isFocused: isFocused, keyboardOnly: true, theme: theme, color: ringColor)
            .disabled(isLoading)
    }
}

// MARK: - Convenience initialisers

extension ShadButton where Label == ShadButtonLabel {
    /// A button with a title and optional leading/trailing icons.
    public init(
        _ title: String,
        variant: ShadButtonVariant = .default,
        size: ShadButtonSize = .default,
        shape: ShadButtonShape = .rounded,
        icon: ShadIcon? = nil,
        trailingIcon: ShadIcon? = nil,
        isLoading: Bool = false,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            shape: shape,
            isLoading: isLoading,
            fillsWidth: fillsWidth,
            action: action
        ) {
            ShadButtonLabel(
                title: title,
                icon: isLoading ? nil : icon,
                trailingIcon: trailingIcon,
                iconSize: size.iconSize,
                gap: size.gap
            )
        }
    }

    /// An icon-only button. Pass an `accessibilityLabel` — shadcn's icon
    /// buttons always carry one.
    public init(
        icon: ShadIcon,
        variant: ShadButtonVariant = .default,
        size: ShadButtonSize = .icon,
        shape: ShadButtonShape = .rounded,
        accessibilityLabel: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(variant: variant, size: size, shape: shape, isLoading: isLoading, action: action) {
            ShadButtonLabel(
                title: nil,
                icon: isLoading ? nil : icon,
                trailingIcon: nil,
                iconSize: size.iconSize,
                gap: size.gap,
                accessibilityLabel: accessibilityLabel
            )
        }
    }
}

/// The default button label: an optional icon, an optional title and an
/// optional trailing icon.
public struct ShadButtonLabel: View {
    let title: String?
    let icon: ShadIcon?
    let trailingIcon: ShadIcon?
    let iconSize: CGFloat
    let gap: CGFloat
    var accessibilityLabel: String? = nil

    public var body: some View {
        HStack(spacing: gap) {
            if let icon { ShadIconView(icon, size: iconSize) }
            if let title { Text(title) }
            if let trailingIcon { ShadIconView(trailingIcon, size: iconSize) }
        }
        .shadIf(accessibilityLabel != nil) { view in
            view.accessibilityLabel(accessibilityLabel ?? "")
        }
    }
}
