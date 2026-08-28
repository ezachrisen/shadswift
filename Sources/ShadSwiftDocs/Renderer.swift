import SwiftUI
import AppKit
import ShadSwift

/// Renders documentation examples to PNG using `ImageRenderer`.
@MainActor
struct DocRenderer {
    let themeSet: ShadThemeSet
    let scale: CGFloat

    init(themeSet: ShadThemeSet = .default, scale: CGFloat = 2) {
        self.themeSet = themeSet
        self.scale = scale
    }

    /// Renders one example for one color scheme and writes it to `url`.
    @discardableResult
    func write(_ example: DocExample, colorScheme: ColorScheme, to url: URL) -> CGSize? {
        let theme = themeSet.resolved(for: colorScheme)

        let content = example.view
            .frame(width: example.width - example.padding * 2, alignment: .leading)
            .frame(height: example.height.map { $0 - example.padding * 2 })
            .padding(example.padding)
            .frame(width: example.width, alignment: .leading)
            .background(theme.colors.background)
            .shadStaticRendering()
            .focusEffectDisabled()
            .shadTheme(themeSet, colorScheme: colorScheme)
            .environment(\.colorScheme, colorScheme)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.foreground)

        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        renderer.isOpaque = true

        guard let image = renderer.cgImage else { return nil }
        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { return nil }
        try? data.write(to: url)
        return CGSize(width: image.width, height: image.height)
    }
}
