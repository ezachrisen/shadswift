import SwiftUI

/// How a field arranges its label and control.
public enum ShadFieldOrientation: String, CaseIterable, Sendable {
    /// Label above the control. The default.
    case vertical
    /// Label and control side by side.
    case horizontal
    /// Horizontal when there is room, vertical when there is not.
    case responsive
}

struct ShadFieldContext {
    var isInvalid: Bool = false
    var orientation: ShadFieldOrientation = .vertical
}

private struct ShadFieldContextKey: EnvironmentKey {
    static let defaultValue = ShadFieldContext()
}

extension EnvironmentValues {
    var shadFieldContext: ShadFieldContext {
        get { self[ShadFieldContextKey.self] }
        set { self[ShadFieldContextKey.self] = newValue }
    }
}

/// The wrapper for a single form field.
///
/// ```swift
/// ShadField {
///     ShadFieldLabel("Username")
///     ShadInput("shadcn", text: $username, isInvalid: !isValid)
///     ShadFieldDescription("This is your public display name.")
/// }
///
/// ShadField(orientation: .horizontal) {
///     ShadFieldContent {
///         ShadFieldLabel("Multi-factor authentication")
///         ShadFieldDescription("Adds an extra layer of security.")
///     }
///     ShadSwitch(isOn: $mfa)
/// }
/// ```
public struct ShadField<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    private let orientation: ShadFieldOrientation
    private let isInvalid: Bool
    private let spacing: CGFloat?
    private let alignment: VerticalAlignment
    private let content: Content

    /// Width at which `.responsive` switches to a horizontal layout.
    public static var responsiveBreakpoint: CGFloat { 440 }

    public init(
        orientation: ShadFieldOrientation = .vertical,
        isInvalid: Bool = false,
        spacing: CGFloat? = nil,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.orientation = orientation
        self.isInvalid = isInvalid
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        Group {
            switch orientation {
            case .vertical:
                vertical
            case .horizontal:
                horizontal
            case .responsive:
                ViewThatFits(in: .horizontal) {
                    horizontal.frame(minWidth: Self.responsiveBreakpoint)
                    vertical
                }
            }
        }
        .environment(\.shadFieldContext, ShadFieldContext(isInvalid: isInvalid, orientation: orientation))
    }

    private var vertical: some View {
        VStack(alignment: .leading, spacing: spacing ?? 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var horizontal: some View {
        HStack(alignment: alignment, spacing: spacing ?? 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A field's label. Tints itself when the field is invalid.
public struct ShadFieldLabel: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadFieldContext) private var field
    @Environment(\.isEnabled) private var isEnabled

    private let text: String
    private let isRequired: Bool

    public init(_ text: String, isRequired: Bool = false) {
        self.text = text
        self.isRequired = isRequired
    }

    public var body: some View {
        HStack(spacing: 2) {
            Text(text)
            if isRequired { Text("*").foregroundStyle(theme.colors.destructive) }
        }
        .font(theme.font(theme.typography.sm, theme.typography.medium))
        .foregroundStyle(field.isInvalid ? theme.colors.destructive : theme.colors.foreground)
        .opacity(isEnabled ? 1 : 0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// Helper text under a control.
public struct ShadFieldDescription: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.mutedForeground)
            .opacity(isEnabled ? 1 : 0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// The error slot. Accepts one message or a list of them, and renders nothing
/// when there is nothing to say.
public struct ShadFieldError: View {
    @Environment(\.shadTheme) private var theme

    private let messages: [String]

    public init(_ message: String?) {
        self.messages = message.map { [$0] } ?? []
    }

    public init(_ messages: [String]) {
        self.messages = messages
    }

    public var body: some View {
        if !messages.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(messages, id: \.self) { message in
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        ShadIconView(.circleAlert, size: 13)
                        Text(message)
                    }
                }
            }
            .font(theme.font(theme.typography.sm, theme.typography.medium))
            .foregroundStyle(theme.colors.destructive)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Groups a label and description into one column so the control can sit
/// beside them in a horizontal field.
public struct ShadFieldContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A title inside ``ShadFieldContent`` — label styling without the `for`
/// association.
public struct ShadFieldTitle: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm, theme.typography.medium))
            .foregroundStyle(theme.colors.foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Stacks fields with the spacing shadcn uses between form rows.
public struct ShadFieldGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A semantic group of related fields.
public struct ShadFieldSet<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The heading for a ``ShadFieldSet``.
public struct ShadFieldLegend: View {
    /// `legend` is a section heading; `label` matches ``ShadFieldLabel``.
    public enum Variant: String, CaseIterable, Sendable {
        case legend
        case label
    }

    @Environment(\.shadTheme) private var theme
    private let text: String
    private let variant: Variant

    public init(_ text: String, variant: Variant = .legend) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .font(variant == .legend
                  ? theme.font(theme.typography.base, theme.typography.semibold)
                  : theme.font(theme.typography.sm, theme.typography.medium))
            .foregroundStyle(theme.colors.foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A divider between sections of a form, optionally with a centred label.
public struct ShadFieldSeparator: View {
    @Environment(\.shadTheme) private var theme
    private let label: String?

    public init(_ label: String? = nil) { self.label = label }

    public var body: some View {
        if let label {
            HStack(spacing: 12) {
                ShadSeparator()
                Text(label)
                    .font(theme.font(theme.typography.xs))
                    .foregroundStyle(theme.colors.mutedForeground)
                    .fixedSize()
                ShadSeparator()
            }
        } else {
            ShadSeparator()
        }
    }
}


// MARK: - Choice cards

/// A bordered, clickable card wrapping a control and its copy — shadcn's
/// "Choice Card" and card-style checkbox.
///
/// The whole card is the hit target, and a selected card picks up a tinted
/// border and background derived from `primary`.
///
/// ```swift
/// ShadChoiceCard(isSelected: plan == .pro) { plan = .pro } content: {
///     ShadFieldContent {
///         ShadFieldTitle("Pro")
///         ShadFieldDescription("$20 per month, billed annually.")
///     }
///     ShadRadioIndicator(isSelected: plan == .pro)
/// }
/// ```
public struct ShadChoiceCard<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let isSelected: Bool
    private let alignment: VerticalAlignment
    private let action: () -> Void
    private let content: Content

    public init(
        isSelected: Bool,
        alignment: VerticalAlignment = .center,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.alignment = alignment
        self.action = action
        self.content = content()
    }

    private var isDark: Bool { theme.colorScheme == .dark }

    private var background: Color {
        if isSelected { return theme.colors.primary.opacity(isDark ? 0.10 : 0.05) }
        return isHovering && isEnabled ? theme.colors.muted.opacity(0.5) : .clear
    }

    private var border: Color {
        isSelected ? theme.colors.primary.opacity(isDark ? 0.20 : 0.30) : theme.colors.border
    }

    public var body: some View {
        Button(action: action) {
            HStack(alignment: alignment, spacing: 8) {
                content
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg).fill(background)
            )
            .overlay(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                    .strokeBorder(border, lineWidth: theme.borderWidth)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(theme.interactionAnimation, value: isHovering)
        .animation(theme.interactionAnimation, value: isSelected)
    }
}

/// The circular indicator a radio-style choice card uses.
public struct ShadRadioIndicator: View {
    @Environment(\.shadTheme) private var theme
    private let isSelected: Bool
    private let size: CGFloat

    public init(isSelected: Bool, size: CGFloat = 16) {
        self.isSelected = isSelected
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(isSelected ? theme.colors.primary : .clear)
            .overlay(
                Circle().strokeBorder(isSelected ? theme.colors.primary : theme.colors.input,
                                      lineWidth: theme.borderWidth)
            )
            .overlay {
                if isSelected {
                    Circle()
                        .fill(theme.colors.primaryForeground)
                        .frame(width: size * 0.375, height: size * 0.375)
                }
            }
            .frame(width: size, height: size)
            .animation(theme.interactionAnimation, value: isSelected)
    }
}

/// A card-style checkbox: the border, the copy and the box in one hit target.
public struct ShadCheckboxCard: View {
    @Binding private var isOn: Bool
    private let title: String
    private let description: String?

    public init(_ title: String, description: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.description = description
        self._isOn = isOn
    }

    public var body: some View {
        ShadChoiceCard(isSelected: isOn, alignment: description == nil ? .center : .top) {
            isOn.toggle()
        } content: {
            ShadCheckbox(isOn: $isOn)
                .allowsHitTesting(false)
                .padding(.top, description == nil ? 0 : 2)
            ShadFieldContent {
                ShadFieldTitle(title)
                if let description { ShadFieldDescription(description) }
            }
        }
    }
}

/// A card-style switch, the "Choice Card" example on the Switch page.
public struct ShadSwitchCard: View {
    @Binding private var isOn: Bool
    private let title: String
    private let description: String?

    public init(_ title: String, description: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.description = description
        self._isOn = isOn
    }

    public var body: some View {
        ShadChoiceCard(isSelected: isOn) {
            isOn.toggle()
        } content: {
            ShadFieldContent {
                ShadFieldTitle(title)
                if let description { ShadFieldDescription(description) }
            }
            ShadSwitch(isOn: $isOn)
                .allowsHitTesting(false)
        }
    }
}
