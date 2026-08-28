import SwiftUI
import AppKit
import ShadSwift

@main
@MainActor
struct ShadSwiftDocsMain {
    static func main() {
        // The generator renders real SwiftUI views, so it needs an app instance
        // even though it never shows a window.
        NSApplication.shared.setActivationPolicy(.prohibited)

        let arguments = CommandLine.arguments

        if arguments.contains("--check-icons") {
            checkIcons()
            return
        }
        let outputPath = arguments.count > 1
            ? arguments[1]
            : FileManager.default.currentDirectoryPath + "/Docs"
        let root = URL(fileURLWithPath: outputPath, isDirectory: true)

        // Snapshots are static, so animation is switched off for every render.
        let renderer = DocRenderer(themeSet: ShadThemeSet.default.motion(.none), scale: 2)
        let components = DocCatalog.components

        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        var rendered = 0
        var failed: [String] = []

        for component in components {
            let directory = root
                .appendingPathComponent("images")
                .appendingPathComponent(component.slug)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            for (index, example) in component.examples.enumerated() where example.showsPreview {
                for scheme in [ColorScheme.light, .dark] {
                    let suffix = scheme == .dark ? "dark" : "light"
                    let url = directory.appendingPathComponent("\(index)-\(suffix).png")
                    if renderer.write(example, colorScheme: scheme, to: url) != nil {
                        rendered += 1
                    } else {
                        failed.append("\(component.slug)/\(index)-\(suffix)")
                    }
                }
            }
        }

        do {
            try HTMLWriter(components: components, root: root).writeAll()
        } catch {
            FileHandle.standardError.write(Data("failed to write HTML: \(error)\n".utf8))
            exit(1)
        }

        print("ShadSwift docs")
        print("  components: \(components.count)")
        print("  examples:   \(components.reduce(0) { $0 + $1.examples.count })")
        print("  images:     \(rendered) rendered")
        if !failed.isEmpty {
            print("  FAILED:     \(failed.joined(separator: ", "))")
        }
        print("  output:     \(root.path)")
    }

    /// Every bundled Lucide glyph must parse into real geometry — a silent
    /// path-parser failure renders as nothing at all, which is easy to miss.
    private static func checkIcons() {
        var broken: [String] = []
        for name in ShadLucideDataProbe.allNames {
            let box = ShadLucideDataProbe.boundingBox(forName: name)
            // A straight rule legitimately has no extent on one axis.
            if box.isNull || (box.width < 1 && box.height < 1) {
                broken.append("\(name) → \(box)")
            }
        }
        print("Lucide glyphs: \(ShadLucideDataProbe.allNames.count) checked")
        if broken.isEmpty {
            print("  all render geometry")
        } else {
            print("  BROKEN:")
            for entry in broken { print("    \(entry)") }
            exit(1)
        }
    }
}
