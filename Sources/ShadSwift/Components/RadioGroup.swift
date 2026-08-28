import SwiftUI

/// A set of checkable buttons where only one may be checked at a time.
///
/// ```swift
/// ShadRadioGroup(selection: $plan) {
///     ShadRadio("Default", value: Plan.default)
///     ShadRadio("Comfortable", value: Plan.comfortable)
///     ShadRadio("Compact", value: Plan.compact)
/// }
/// ```
///
/// For the card treatment, use ``ShadRadioCard`` inside the same group.
public struct ShadRadioGroup<Value: Hashable, Content: View>: View {
    @Binding private var selection: Value?
    private let spacing: CGFloat
    private let content: Content

    public init(
        selection: Binding<Value?>,
        spacing: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.spacing = spacing
        self.content = content()
    }

    /// Non-optional convenience, for a group that always has a choice.
    public init(
        selection: Binding<Value>,
        spacing: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            selection: Binding(
                get: { Optional(selection.wrappedValue) },
                set: { if let value = $0 { selection.wrappedValue = value } }
            ),
            spacing: spacing,
            content: content
        )
    }

    private var context: ShadRadioContext {
        ShadRadioContext(
            selection: selection.map { AnyHashable($0) },
            select: { newValue in
                if let typed = newValue.base as? Value { selection = typed }
            }
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .environment(\.shadRadioContext, context)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}

struct ShadRadioContext {
    var selection: AnyHashable?
    var select: (AnyHashable) -> Void = { _ in }
}

private struct ShadRadioContextKey: EnvironmentKey {
    static let defaultValue = ShadRadioContext()
}

extension EnvironmentValues {
    var shadRadioContext: ShadRadioContext {
        get { self[ShadRadioContextKey.self] }
        set { self[ShadRadioContextKey.self] = newValue }
    }
}

/// The circle itself: a 16pt ring that fills with an 8pt dot when checked.
public struct ShadRadioGroupItem<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadRadioContext) private var group
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    private let value: Value
    private let isInvalid: Bool
    private let size: CGFloat

    public init(value: Value, isInvalid: Bool = false, size: CGFloat = 16) {
        self.value = value
        self.isInvalid = isInvalid
        self.size = size
    }

    private var isSelected: Bool { group.selection == AnyHashable(value) }

    private var borderColor: Color {
        if isInvalid { return theme.colors.destructive }
        return isSelected ? theme.colors.primary : theme.colors.input
    }

    public var body: some View {
        Button {
            group.select(AnyHashable(value))
        } label: {
            indicator
        }
        .buttonStyle(.shadPlain)
        .focusable(isEnabled)
        .focused($isFocused)
        .focusEffectDisabled()
        .shadPointerCursor(isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// Checked fills the whole circle with `primary` and punches an 8pt
    /// `primary-foreground` dot through it — a dark ring around a light middle,
    /// not a dark dot on a light field.
    private var fill: Color {
        if isSelected { return theme.colors.primary }
        return theme.colorScheme == .dark ? theme.colors.input.opacity(0.3) : .clear
    }

    @ViewBuilder
    private var indicator: some View {
        Circle()
            .fill(fill)
            .overlay(Circle().strokeBorder(borderColor, lineWidth: theme.borderWidth))
            .overlay {
                if isSelected {
                    Circle()
                        .fill(theme.colors.primaryForeground)
                        .frame(width: size * 0.5, height: size * 0.5)
                }
            }
            .frame(width: size, height: size)
            .shadFocusRing(
                size / 2,
                isFocused: isFocused,
                keyboardOnly: true,
                isPersistent: isInvalid,
                theme: theme,
                color: isInvalid ? theme.colors.destructive : theme.colors.ring
            )
            .animation(theme.interactionAnimation, value: isSelected)
    }
}

/// A radio button with a label, and optionally a description beneath it.
public struct ShadRadio<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadRadioContext) private var group
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let description: String?
    private let value: Value
    private let isInvalid: Bool

    public init(_ title: String, description: String? = nil, value: Value, isInvalid: Bool = false) {
        self.title = title
        self.description = description
        self.value = value
        self.isInvalid = isInvalid
    }

    public var body: some View {
        Button {
            group.select(AnyHashable(value))
        } label: {
            HStack(alignment: description == nil ? .center : .top, spacing: 8) {
                ShadRadioGroupItem(value: value, isInvalid: isInvalid)
                    .allowsHitTesting(false)
                    .padding(.top, description == nil ? 0 : 2)
                if let description {
                    ShadFieldContent {
                        ShadFieldTitle(title)
                        ShadFieldDescription(description)
                    }
                } else {
                    Text(title)
                        .font(theme.font(theme.typography.sm, theme.typography.medium))
                        .foregroundStyle(theme.colors.foreground)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadPointerCursor(isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

/// The card treatment: a bordered, clickable card with the radio on the right.
///
/// ```swift
/// ShadRadioGroup(selection: $environment) {
///     ShadRadioCard("Kubernetes",
///                   description: "Run GPU workloads on a K8s cluster.",
///                   value: Environment.kubernetes)
///     ShadRadioCard("Virtual Machine",
///                   description: "Access a cluster to run GPU workloads.",
///                   value: Environment.virtualMachine)
/// }
/// ```
public struct ShadRadioCard<Value: Hashable>: View {
    @Environment(\.shadRadioContext) private var group

    private let title: String
    private let description: String?
    private let value: Value

    public init(_ title: String, description: String? = nil, value: Value) {
        self.title = title
        self.description = description
        self.value = value
    }

    private var isSelected: Bool { group.selection == AnyHashable(value) }

    public var body: some View {
        ShadChoiceCard(isSelected: isSelected) {
            group.select(AnyHashable(value))
        } content: {
            ShadFieldContent {
                ShadFieldTitle(title)
                if let description { ShadFieldDescription(description) }
            }
            ShadRadioGroupItem(value: value)
                .allowsHitTesting(false)
        }
    }
}
