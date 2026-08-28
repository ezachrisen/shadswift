import AppKit
import SwiftUI

/// Tracks pointer hover without the boilerplate, and forces the state back to
/// `false` when the control becomes disabled.
struct ShadHoverModifier: ViewModifier {
    @Binding var isHovering: Bool
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                isHovering = isEnabled && hovering
            }
            .onChange(of: isEnabled) { _, _ in
                if !isEnabled { isHovering = false }
            }
    }
}

extension View {
    func shadHover(_ isHovering: Binding<Bool>, enabled: Bool = true) -> some View {
        modifier(ShadHoverModifier(isHovering: isHovering, isEnabled: enabled))
    }

    /// Switches the cursor to the pointing hand while hovering an interactive
    /// surface, the macOS equivalent of `cursor-pointer`.
    func shadPointerCursor(_ enabled: Bool = true) -> some View {
        onHover { inside in
            guard enabled else { return }
            if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}

/// Reports a view's size up the tree.
struct ShadSizeReader: ViewModifier {
    let onChange: (CGSize) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ShadSizeKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(ShadSizeKey.self, perform: onChange)
    }
}

struct ShadSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

extension View {
    func shadMeasure(_ onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(ShadSizeReader(onChange: onChange))
    }
}

/// A button style that adds nothing at all — no chrome, no focus ring, and no
/// AppKit-backed control behind it.
///
/// SwiftUI's own `.plain` style is backed by AppKit on macOS, which means it
/// cannot be captured by `ImageRenderer` and paints a system focus ring the
/// library does not want. Every component that draws its own visuals uses this
/// instead.
public struct ShadPlainButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == ShadPlainButtonStyle {
    /// A completely undecorated button.
    public static var shadPlain: ShadPlainButtonStyle { ShadPlainButtonStyle() }
}

/// A button style that strips every default SwiftUI decoration and reports the
/// pressed state, so components can render their own visuals.
struct ShadRawButtonStyle: ButtonStyle {
    let onPressChange: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed) { _, pressed in
                onPressChange(pressed)
            }
    }
}
