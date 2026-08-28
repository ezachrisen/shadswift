import Foundation

/// Emits the static documentation site.
struct HTMLWriter {
    let components: [DocComponent]
    let root: URL

    private var groups: [(String, [DocComponent])] {
        var order: [String] = []
        var buckets: [String: [DocComponent]] = [:]
        for component in components {
            if !order.contains(component.group) { order.append(component.group) }
            buckets[component.group, default: []].append(component)
        }
        return order.map { ($0, buckets[$0] ?? []) }
    }

    // MARK: - Entry points

    func writeAll() throws {
        try writeAsset("shadswift-docs.css", css)
        try writeAsset("shadswift-docs.js", javascript)
        try writeIndex()
        for component in components {
            try writeComponent(component)
        }
    }

    private func writeAsset(_ name: String, _ contents: String) throws {
        let directory = root.appendingPathComponent("assets")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try contents.write(to: directory.appendingPathComponent(name), atomically: true, encoding: .utf8)
    }

    // MARK: - Pages

    private func writeIndex() throws {
        var body = """
        <header class="page-header">
          <p class="eyebrow">SwiftUI · macOS</p>
          <h1>ShadSwift</h1>
          <p class="lede">A SwiftUI component library for macOS modelled on <a href="https://ui.shadcn.com/docs/components">shadcn/ui</a>.
          Every component below, every variant its shadcn page documents, and one theme value that drives every colour,
          corner radius, type size, shadow and animation in the library.</p>
        </header>

        <section class="prose">
          <h2 id="install">Install</h2>
          <p>Add the package to your <code>Package.swift</code>:</p>
          \(codeBlock("""
          dependencies: [
              .package(url: "https://github.com/you/ShadSwift.git", from: "1.0.0")
          ]
          """))
          <p>Then inject a theme once, as high in your hierarchy as you can:</p>
          \(codeBlock("""
          import SwiftUI
          import ShadSwift

          @main
          struct MyApp: App {
              var body: some Scene {
                  WindowGroup {
                      ContentView()
                          .shadTheme(.default)
                  }
              }
          }
          """))
          <p>Every component below reads that theme from the environment. Nothing hard-codes a colour.</p>

          <h2 id="theming">Theming</h2>
          <p>Colours are authored in OKLCH — the same notation shadcn uses in <code>globals.css</code> — so a palette
          copied from the web translates almost verbatim.</p>
          \(codeBlock("""
          let brand = ShadThemeSet.slate
              .radius(4)                                   // --radius
              .fontName("Geist")                           // type family
              .tinted(light: OKLCH(0.55, 0.20, 264),       // --primary
                      dark:  OKLCH(0.65, 0.20, 264))

          ContentView().shadTheme(brand)
          """))
          <p>Or reach for a single token anywhere in the tree:</p>
          \(codeBlock("""
          VStack { … }
              .shadTheme { theme in
                  theme.radius = ShadRadius(base: 0)       // square corners here only
                  theme.colors.primary = .accentColor
              }
          """))
        </section>

        <section class="prose">
          <h2 id="components">Components</h2>
        """

        for (group, items) in groups {
            body += "<h3 class=\"group-heading\">\(escape(group))</h3>\n<div class=\"card-grid\">\n"
            for component in items {
                body += """
                <a class="component-card" href="components/\(component.slug).html">
                  <span class="component-card__title">\(escape(component.title))</span>
                  <span class="component-card__summary">\(escape(component.summary))</span>
                </a>
                """
            }
            body += "\n</div>\n"
        }
        body += "</section>"

        let html = page(title: "ShadSwift — SwiftUI components for macOS", body: body, prefix: "", active: nil)
        try html.write(to: root.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
    }

    private func writeComponent(_ component: DocComponent) throws {
        var body = """
        <header class="page-header">
          <p class="eyebrow">\(escape(component.group))</p>
          <h1>\(escape(component.title))</h1>
          <p class="lede">\(escape(component.summary))</p>
        </header>

        <section class="prose">
          <h2 id="import">Import</h2>
          \(codeBlock(component.importLine))
        """

        if let anatomy = component.anatomy {
            body += """
              <h2 id="anatomy">Anatomy</h2>
              \(codeBlock(anatomy))
            """
        }
        body += "</section>\n"

        for (index, example) in component.examples.enumerated() {
            let anchor = slugify(example.title)
            let preview = example.showsPreview ? """
              <figure class="preview">
                <img class="preview__img" loading="lazy" data-light="../images/\(component.slug)/\(index)-light.png" data-dark="../images/\(component.slug)/\(index)-dark.png" src="../images/\(component.slug)/\(index)-light.png" alt="\(escape(example.title))">
              </figure>
            """ : ""
            body += """
            <section class="example" id="\(anchor)">
              <div class="example__head">
                <h2><a class="anchor" href="#\(anchor)">\(escape(example.title))</a></h2>
                \(example.description.map { "<p>\(escape($0))</p>" } ?? "")
              </div>
            \(preview)
              \(codeBlock(example.code))
            </section>
            """
        }

        if !component.api.isEmpty {
            body += "<section class=\"prose\"><h2 id=\"api\">API</h2>\n"
            for api in component.api {
                body += "<h3><code>\(escape(api.name))</code></h3>\n"
                if let summary = api.summary {
                    body += "<p>\(escape(summary))</p>\n"
                }
                if !api.properties.isEmpty {
                    body += """
                    <div class="table-wrap"><table>
                      <thead><tr><th>Parameter</th><th>Type</th><th>Default</th><th>Description</th></tr></thead>
                      <tbody>
                    """
                    for property in api.properties {
                        body += """
                        <tr>
                          <td><code>\(escape(property.name))</code></td>
                          <td><code class="type">\(escape(property.type))</code></td>
                          <td>\(property.default.map { "<code>\(escape($0))</code>" } ?? "—")</td>
                          <td>\(escape(property.summary))</td>
                        </tr>
                        """
                    }
                    body += "</tbody></table></div>\n"
                }
            }
            body += "</section>\n"
        }

        if !component.notes.isEmpty {
            body += "<section class=\"prose\"><h2 id=\"notes\">Notes</h2><ul class=\"notes\">\n"
            for note in component.notes {
                body += "<li>\(escape(note))</li>\n"
            }
            body += "</ul></section>\n"
        }

        let html = page(
            title: "\(component.title) — ShadSwift",
            body: body,
            prefix: "../",
            active: component.slug
        )
        let directory = root.appendingPathComponent("components")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try html.write(to: directory.appendingPathComponent("\(component.slug).html"), atomically: true, encoding: .utf8)
    }

    // MARK: - Layout

    private func page(title: String, body: String, prefix: String, active: String?) -> String {
        var nav = ""
        for (group, items) in groups {
            nav += "<p class=\"nav__group\">\(escape(group))</p>\n<ul>\n"
            for component in items {
                let isActive = component.slug == active ? " class=\"is-active\"" : ""
                nav += "<li><a\(isActive) href=\"\(prefix)components/\(component.slug).html\">\(escape(component.title))</a></li>\n"
            }
            nav += "</ul>\n"
        }

        return """
        <!doctype html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(escape(title))</title>
        <link rel="stylesheet" href="\(prefix)assets/shadswift-docs.css">
        <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>◈</text></svg>">
        </head>
        <body>
        <a class="skip" href="#main">Skip to content</a>
        <div class="shell">
          <aside class="nav">
            <a class="nav__brand" href="\(prefix)index.html">◈ ShadSwift</a>
            <button class="theme-toggle" type="button" data-theme-toggle>
              <span class="theme-toggle__label">Dark</span>
            </button>
            <nav class="nav__list">
              <p class="nav__group">Getting started</p>
              <ul>
                <li><a href="\(prefix)index.html#install">Install</a></li>
                <li><a href="\(prefix)index.html#theming">Theming</a></li>
              </ul>
              \(nav)
            </nav>
          </aside>
          <main id="main" class="main">
            \(body)
            <footer class="footer">
              <p>Generated by <code>swift run ShadSwiftDocs</code>. Snapshots are rendered from the real SwiftUI views with <code>ImageRenderer</code>.</p>
            </footer>
          </main>
        </div>
        <script src="\(prefix)assets/shadswift-docs.js"></script>
        </body>
        </html>
        """
    }

    // MARK: - Helpers

    private func codeBlock(_ code: String) -> String {
        """
        <div class="code">
          <button class="code__copy" type="button" data-copy>Copy</button>
          <pre><code>\(highlight(code))</code></pre>
        </div>
        """
    }

    /// A deliberately small Swift highlighter: keywords, strings, comments,
    /// numbers and type names. Enough to make the samples readable without
    /// shipping a syntax-highlighting dependency.
    private func highlight(_ code: String) -> String {
        var result = ""
        var index = code.startIndex

        func isIdentifierCharacter(_ character: Character) -> Bool {
            character.isLetter || character.isNumber || character == "_"
        }

        while index < code.endIndex {
            let character = code[index]

            // Line comment
            if character == "/", code.index(after: index) < code.endIndex, code[code.index(after: index)] == "/" {
                let end = code[index...].firstIndex(of: "\n") ?? code.endIndex
                result += "<span class=\"c\">\(escape(String(code[index..<end])))</span>"
                index = end
                continue
            }

            // String literal
            if character == "\"" {
                var end = code.index(after: index)
                while end < code.endIndex {
                    if code[end] == "\\", code.index(after: end) < code.endIndex {
                        end = code.index(end, offsetBy: 2)
                        continue
                    }
                    if code[end] == "\"" { end = code.index(after: end); break }
                    end = code.index(after: end)
                }
                result += "<span class=\"s\">\(escape(String(code[index..<end])))</span>"
                index = end
                continue
            }

            // Leading dot member, e.g. .destructive
            if character == ".", code.index(after: index) < code.endIndex, code[code.index(after: index)].isLowercase {
                var end = code.index(after: index)
                while end < code.endIndex, isIdentifierCharacter(code[end]) { end = code.index(after: end) }
                result += "<span class=\"m\">\(escape(String(code[index..<end])))</span>"
                index = end
                continue
            }

            // Identifier or number
            if isIdentifierCharacter(character) {
                var end = index
                while end < code.endIndex, isIdentifierCharacter(code[end]) { end = code.index(after: end) }
                let word = String(code[index..<end])
                if Self.keywords.contains(word) {
                    result += "<span class=\"k\">\(escape(word))</span>"
                } else if word.first?.isNumber == true {
                    result += "<span class=\"n\">\(escape(word))</span>"
                } else if word.first?.isUppercase == true {
                    result += "<span class=\"t\">\(escape(word))</span>"
                } else {
                    result += escape(word)
                }
                index = end
                continue
            }

            result += escape(String(character))
            index = code.index(after: index)
        }
        return result
    }

    private static let keywords: Set<String> = [
        "import", "struct", "class", "enum", "func", "var", "let", "return", "if", "else",
        "for", "in", "while", "guard", "switch", "case", "default", "some", "any", "self",
        "init", "public", "private", "internal", "static", "extension", "protocol", "where",
        "true", "false", "nil", "async", "await", "try", "throws", "do", "catch", "@main",
        "@State", "@Binding", "@StateObject", "@Environment", "@ViewBuilder", "@ObservedObject",
    ]

    private func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func slugify(_ text: String) -> String {
        text.lowercased()
            .map { $0.isLetter || $0.isNumber ? String($0) : "-" }
            .joined()
            .replacingOccurrences(of: "--", with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
