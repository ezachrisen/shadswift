import SwiftUI

/// Switch sizes.
public enum ShadSwitchSize: String, CaseIterable, Sendable {
    case sm
    case `default`

    var trackWidth: CGFloat { self == .sm ? 24 : 32 }
    var trackHeight: CGFloat { self == .sm ? 14 : 18 }
    var thumb: CGFloat { self == .sm ? 12 : 16 }
}

/// A control that allows the user to toggle between checked and not checked.
///
/// ```swift
/// ShadSwitch(isOn: $airplaneMode)
/// ShadSwitch("Marketing emails", isOn: $marketing, size: .sm)
/// ```
public struct ShadSwitch: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    @Binding private var isOn: Bool
    private let label: String?
    private let size: ShadSwitchSize
    private let isInvalid: Bool

    public init(
        _ label: String? = nil,
        isOn: Binding<Bool>,
        size: ShadSwitchSize = .default,
        isInvalid: Bool = false
    ) {
        self.label = label
        self._isOn = isOn
        self.size = size
        self.isInvalid = isInvalid
    }

    private var trackColor: Color {
        if isOn { return theme.colors.primary }
        return theme.colorScheme == .dark ? theme.colors.input.opacity(0.8) : theme.colors.input
    }

    private var thumbColor: Color {
        guard theme.colorScheme == .dark else { return theme.colors.background }
        return isOn ? theme.colors.primaryForeground : theme.colors.foreground
    }

    private var borderColor: Color {
        isInvalid ? theme.colors.destructive : .clear
    }

    /// The invalid halo stays on whether or not the control has focus.
    private var showsRing: Bool { isFocused || isInvalid }

    public var body: some View {
        Button {
            withAnimation(theme.interactionAnimation) { isOn.toggle() }
        } label: {
            HStack(spacing: 8) {
                track
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
        .shadPointerCursor(isEnabled)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private var track: some View {
        Capsule()
            .fill(trackColor)
            .overlay(Capsule().strokeBorder(borderColor, lineWidth: isInvalid ? theme.borderWidth : 0))
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(thumbColor)
                    .frame(width: size.thumb, height: size.thumb)
                    .shadShadow(theme.shadows.xs)
                    .padding(.horizontal, theme.borderWidth)
            }
            .frame(width: size.trackWidth, height: size.trackHeight)
            .shadFocusRing(
                size.trackHeight / 2,
                isFocused: isFocused,
                keyboardOnly: true,
                isPersistent: isInvalid,
                theme: theme,
                color: isInvalid ? theme.colors.destructive : theme.colors.ring
            )
            .animation(theme.interactionAnimation, value: isOn)
    }
}
