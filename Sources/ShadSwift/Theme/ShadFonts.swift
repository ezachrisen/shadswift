import SwiftUI
import AppKit
import CoreText

/// Registers the type families the library ships with.
///
/// ShadSwift bundles Geist and Geist Mono — the same faces the shadcn/ui
/// documentation uses — under the SIL Open Font License. They are registered
/// with Core Text the first time a theme asks for them, so nothing needs to be
/// installed on the user's machine.
public enum ShadFonts {
    /// The bundled sans family.
    public static let sans = "Geist"
    /// The bundled monospaced family.
    public static let mono = "Geist Mono"

    private static var didRegister = false
    private static let lock = NSLock()

    /// Locates the package's resource bundle without trapping.
    ///
    /// `Bundle.module` calls `fatalError` when the bundle is missing, which is
    /// exactly what happens if an app copies the executable but forgets the
    /// resources. Looking it up by hand means a misconfigured host falls back
    /// to the system font instead of crashing.
    private static var resourceBundle: Bundle? = {
        let name = "ShadSwift_ShadSwift.bundle"
        var candidates: [URL] = []
        if let resources = Bundle.main.resourceURL {
            candidates.append(resources.appendingPathComponent(name))
        }
        candidates.append(Bundle.main.bundleURL.appendingPathComponent(name))
        candidates.append(
            URL(fileURLWithPath: CommandLine.arguments[0])
                .deletingLastPathComponent()
                .appendingPathComponent(name)
        )
        for url in candidates {
            if let bundle = Bundle(url: url) { return bundle }
        }
        // Fonts may also have been copied straight into the host bundle.
        if Bundle.main.url(forResource: "Geist-Regular", withExtension: "ttf") != nil
            || Bundle.main.url(forResource: "Geist-Regular", withExtension: "ttf", subdirectory: "Fonts") != nil {
            return Bundle.main
        }
        return nil
    }()

    /// Registers the bundled faces. Safe to call repeatedly.
    public static func registerBundledFonts() {
        lock.lock()
        defer { lock.unlock() }
        guard !didRegister else { return }
        didRegister = true

        let names = [
            "Geist-Regular", "Geist-Medium", "Geist-SemiBold", "Geist-Bold",
            "GeistMono-Regular", "GeistMono-Medium",
        ]
        guard let bundle = resourceBundle else { return }
        for name in names {
            guard let url = bundle.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? bundle.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    /// The PostScript name of the bundled face for a weight, when there is one.
    ///
    /// Geist ships Regular, Medium, SemiBold and Bold; anything lighter or
    /// heavier maps to the nearest of those.
    public static func faceName(family: String, weight: Font.Weight) -> String? {
        let suffix: String
        switch weight {
        case .ultraLight, .thin, .light, .regular: suffix = "Regular"
        case .medium: suffix = "Medium"
        case .semibold: suffix = "SemiBold"
        case .bold, .heavy, .black: suffix = "Bold"
        default: suffix = "Regular"
        }
        switch family {
        case sans: return "Geist-\(suffix)"
        case mono: return suffix == "SemiBold" || suffix == "Bold" ? "GeistMono-Medium" : "GeistMono-\(suffix)"
        default: return nil
        }
    }

    /// True once the family is resolvable — useful for tests and previews.
    public static func isAvailable(_ family: String) -> Bool {
        registerBundledFonts()
        return NSFontManager.shared.availableFontFamilies.contains(family)
    }
}
