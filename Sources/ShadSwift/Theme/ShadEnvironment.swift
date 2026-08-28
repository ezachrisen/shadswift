import SwiftUI

private struct ShadThemeKey: EnvironmentKey {
    static let defaultValue = ShadTheme()
}

extension EnvironmentValues {
    /// The resolved theme for the current subtree.
    public var shadTheme: ShadTheme {
        get { self[ShadThemeKey.self] }
        set { self[ShadThemeKey.self] = newValue }
    }
}

private struct ShadThemeSetModifier: ViewModifier {
    let set: ShadThemeSet
    let override: ColorScheme?
    @Environment(\.colorScheme) private var ambient

    func body(content: Content) -> some View {
        let scheme = override ?? ambient
        content
            .environment(\.shadTheme, set.resolved(for: scheme))
            .environment(\.colorScheme, scheme)
    }
}

extension View {
    /// Resolves `set` against the ambient color scheme and injects it.
    ///
    /// Apply this once, as high in the hierarchy as you can.
    public func shadTheme(_ set: ShadThemeSet, colorScheme: ColorScheme? = nil) -> some View {
        modifier(ShadThemeSetModifier(set: set, override: colorScheme))
    }

    /// Injects an already-resolved theme, bypassing light/dark resolution.
    public func shadTheme(_ theme: ShadTheme) -> some View {
        environment(\.shadTheme, theme)
            .environment(\.colorScheme, theme.colorScheme)
    }

    /// Mutates the inherited theme for this subtree — useful for one-off
    /// tweaks such as a larger radius inside a single card.
    public func shadTheme(_ transform: @escaping (inout ShadTheme) -> Void) -> some View {
        modifier(ShadThemeTransform(transform: transform))
    }
}

private struct ShadThemeTransform: ViewModifier {
    let transform: (inout ShadTheme) -> Void
    @Environment(\.shadTheme) private var theme

    func body(content: Content) -> some View {
        var copy = theme
        transform(&copy)
        return content.environment(\.shadTheme, copy)
    }
}

/// Paints the theme's `background` color and applies its base font, giving a
/// window or preview the same canvas the shadcn docs use.
public struct ShadSurface<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.foreground)
            .background(theme.colors.background)
    }
}
