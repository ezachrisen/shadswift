import SwiftUI
import AppKit

/// Tracks whether focus is currently being driven from the keyboard.
///
/// The web's `:focus-visible` only paints a ring when the user tabbed to a
/// control, never when they clicked it. AppKit gives focus on click too, so a
/// naive ring leaves a thick outline behind every button press. This watches
/// the input stream and lets components ask which kind of focus they have.
@MainActor
public final class ShadFocusVisibility: ObservableObject {
    public static let shared = ShadFocusVisibility()

    /// True when the last input that could move focus was a key press.
    @Published public private(set) var isKeyboardDriven = false

    private var monitor: Any?

    private init() { start() }

    private func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] event in
            guard let self else { return event }
            switch event.type {
            case .keyDown:
                // Tab, Escape and the arrows are the keys that move focus.
                let focusKeys: Set<UInt16> = [48, 53, 123, 124, 125, 126]
                if focusKeys.contains(event.keyCode) { self.isKeyboardDriven = true }
            default:
                self.isKeyboardDriven = false
            }
            return event
        }
    }
}

/// Draws shadcn's focus ring: a 3pt halo sitting entirely *outside* the
/// control's border, never overlapping it.
struct ShadFocusRingModifier: ViewModifier {
    @ObservedObject private var visibility = ShadFocusVisibility.shared

    let cornerRadius: CGFloat
    let isFocused: Bool
    /// Only paint the ring for keyboard focus — the `:focus-visible` rule.
    let keyboardOnly: Bool
    /// Paint the ring regardless of focus, which is what an invalid control does.
    let isPersistent: Bool
    let theme: ShadTheme
    let color: Color?

    private var isVisible: Bool {
        if isPersistent { return true }
        guard isFocused else { return false }
        return keyboardOnly ? visibility.isKeyboardDriven : true
    }

    func body(content: Content) -> some View {
        let ring = theme.focusRing
        let spread = ring.width + ring.offset
        return content.overlay {
            ShadRoundedRectangle(cornerRadius: cornerRadius + spread)
                .inset(by: -spread)
                .strokeBorder(
                    (color ?? theme.colors.ring).opacity(isVisible ? ring.opacity : 0),
                    lineWidth: ring.width
                )
                .allowsHitTesting(false)
                .animation(theme.interactionAnimation, value: isVisible)
        }
    }
}

extension View {
    /// Draws the focus ring outside `cornerRadius`.
    ///
    /// - Parameters:
    ///   - keyboardOnly: restrict the ring to keyboard focus, the way
    ///     `:focus-visible` does. Buttons and toggles want this; text fields
    ///     do not, since they legitimately show a ring when clicked.
    ///   - isPersistent: keep the ring on regardless of focus — an invalid
    ///     control's red halo.
    func shadFocusRing(
        _ cornerRadius: CGFloat,
        isFocused: Bool,
        keyboardOnly: Bool = false,
        isPersistent: Bool = false,
        theme: ShadTheme,
        color: Color? = nil
    ) -> some View {
        modifier(ShadFocusRingModifier(
            cornerRadius: cornerRadius,
            isFocused: isFocused,
            keyboardOnly: keyboardOnly,
            isPersistent: isPersistent,
            theme: theme,
            color: color
        ))
    }
}
