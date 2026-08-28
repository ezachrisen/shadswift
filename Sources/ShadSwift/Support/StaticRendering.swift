import SwiftUI

private struct ShadStaticRenderingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True when the view is being captured rather than displayed.
    ///
    /// `ImageRenderer` never lays out a `ScrollView`'s content or materialises
    /// a `LazyVStack`, so anything inside one comes out blank. Setting this
    /// makes the library's scrolling containers fall back to plain stacks,
    /// which renders the same content without the scrolling machinery.
    public var shadStaticRendering: Bool {
        get { self[ShadStaticRenderingKey.self] }
        set { self[ShadStaticRenderingKey.self] = newValue }
    }
}

extension View {
    /// Marks this subtree as being rendered to an image rather than displayed.
    ///
    /// ```swift
    /// let renderer = ImageRenderer(content: gallery.shadStaticRendering())
    /// ```
    public func shadStaticRendering(_ enabled: Bool = true) -> some View {
        environment(\.shadStaticRendering, enabled)
    }
}

/// A `ScrollView` that degrades to a plain container while being captured.
struct ShadScrollContainer<Content: View>: View {
    @Environment(\.shadStaticRendering) private var isStatic

    var axes: Axis.Set = .vertical
    var alignment: Alignment = .topLeading
    @ViewBuilder var content: () -> Content

    var body: some View {
        if isStatic {
            content()
                .frame(maxWidth: .infinity, alignment: alignment)
        } else {
            ScrollView(axes) {
                content()
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

/// A `LazyVStack` that degrades to a `VStack` while being captured, so every
/// row is materialised.
struct ShadLazyVStack<Content: View>: View {
    @Environment(\.shadStaticRendering) private var isStatic

    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        if isStatic {
            VStack(alignment: alignment, spacing: spacing) { content() }
        } else {
            LazyVStack(alignment: alignment, spacing: spacing) { content() }
        }
    }
}

/// Renders a text control's value as plain text while being captured.
///
/// `ImageRenderer` cannot snapshot an AppKit-backed `TextField`, `SecureField`
/// or `TextEditor` — they come out as flat accent-coloured rectangles — so the
/// library substitutes this while `shadStaticRendering` is set.
struct ShadStaticTextValue: View {
    @Environment(\.shadTheme) private var theme

    let text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var font: Font? = nil
    var lineLimit: Int? = 1
    var alignment: Alignment = .leading

    private var display: String {
        if text.isEmpty { return placeholder }
        return isSecure ? String(repeating: "•", count: text.count) : text
    }

    var body: some View {
        Text(display)
            .font(font ?? theme.font(theme.typography.sm))
            .foregroundStyle(text.isEmpty ? theme.colors.mutedForeground : theme.colors.foreground)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: lineLimit == nil)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
