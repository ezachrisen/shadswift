import SwiftUI

/// The tri-state a checkbox can be in.
public enum ShadCheckboxState: Sendable, Hashable {
    case unchecked
    case checked
    case indeterminate

    /// Cycles unchecked → checked → unchecked. Indeterminate resolves to checked.
    public mutating func toggle() {
        self = (self == .checked) ? .unchecked : .checked
    }

    public var isOn: Bool { self == .checked }
}

/// A control that lets the user toggle between checked and not checked.
///
/// ```swift
/// ShadCheckbox(isOn: $accepted)
/// ShadCheckbox("Accept terms and conditions", isOn: $accepted)
/// ShadCheckbox(state: $selection)          // supports .indeterminate
/// ```
public struct ShadCheckbox: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    @State private var isHovering = false

    @Binding private var state: ShadCheckboxState
    private let label: String?
    private let isInvalid: Bool
    private let size: CGFloat

    public init(
        _ label: String? = nil,
        state: Binding<ShadCheckboxState>,
        isInvalid: Bool = false,
        size: CGFloat = 16
    ) {
        self.label = label
        self._state = state
        self.isInvalid = isInvalid
        self.size = size
    }

    public init(
        _ label: String? = nil,
        isOn: Binding<Bool>,
        isInvalid: Bool = false,
        size: CGFloat = 16
    ) {
        self.init(
            label,
            state: Binding(
                get: { isOn.wrappedValue ? .checked : .unchecked },
                set: { isOn.wrappedValue = $0 == .checked }
            ),
            isInvalid: isInvalid,
            size: size
        )
    }

    private var isOn: Bool { state != .unchecked }

    private var fill: Color {
        if isOn { return theme.colors.primary }
        return theme.colorScheme == .dark ? theme.colors.input.opacity(0.3) : .clear
    }

    private var borderColor: Color {
        if isInvalid { return theme.colors.destructive }
        if isOn { return theme.colors.primary }
        return isHovering ? theme.colors.ring : theme.colors.input
    }

    /// shadcn keeps a 3pt halo on an invalid checkbox even when it is not
    /// focused, which is the red glow around the red border.
    private var showsRing: Bool { isFocused || isInvalid }

    public var body: some View {
        Button {
            state.toggle()
        } label: {
            HStack(spacing: 8) {
                box
                if let label {
                    Text(label)
                        .font(theme.font(theme.typography.sm, theme.typography.medium))
                        .foregroundStyle(theme.colors.foreground)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .opacity(isEnabled ? 1 : 0.5)
        .focusable(isEnabled)
        .focused($isFocused)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private var box: some View {
        ShadRoundedRectangle(cornerRadius: 4)
            .fill(fill)
            .overlay(
                ShadRoundedRectangle(cornerRadius: 4)
                    .strokeBorder(borderColor, lineWidth: theme.borderWidth)
            )
            .overlay {
                switch state {
                case .checked:
                    ShadIconView(.check, size: size * 0.875)
                        .foregroundStyle(theme.colors.primaryForeground)
                case .indeterminate:
                    ShadIconView(.minus, size: size * 0.875)
                        .foregroundStyle(theme.colors.primaryForeground)
                case .unchecked:
                    EmptyView()
                }
            }
            .frame(width: size, height: size)
            .shadFocusRing(
                4,
                isFocused: isFocused,
                keyboardOnly: true,
                isPersistent: isInvalid,
                theme: theme,
                color: isInvalid ? theme.colors.destructive : theme.colors.ring
            )
            .animation(theme.interactionAnimation, value: state)
            .animation(theme.interactionAnimation, value: isHovering)
    }
}
