import SwiftUI
import ShadSwift

/// Everything the generator knows how to document.
@MainActor
enum DocCatalog {
    static var components: [DocComponent] {
        display + controls + forms + overlays + layout + data + conversation
    }
}

/// Shared sample data used across several pages.
@MainActor
enum DocSamples {
    static let frameworks: [ShadSelectOption<String>] = [
        ShadSelectOption("Next.js", value: "next"),
        ShadSelectOption("SvelteKit", value: "svelte"),
        ShadSelectOption("Nuxt.js", value: "nuxt"),
        ShadSelectOption("Remix", value: "remix"),
        ShadSelectOption("Astro", value: "astro"),
    ]

    static let timezones: [ShadSelectSection<String>] = [
        ShadSelectSection("North America", options: [
            ShadSelectOption("Eastern Standard Time (EST)", value: "est"),
            ShadSelectOption("Central Standard Time (CST)", value: "cst"),
            ShadSelectOption("Pacific Standard Time (PST)", value: "pst"),
        ]),
        ShadSelectSection("Europe", options: [
            ShadSelectOption("Greenwich Mean Time (GMT)", value: "gmt"),
            ShadSelectOption("Central European Time (CET)", value: "cet"),
        ]),
    ]
}

/// A frozen popup surface, so the docs can show what a menu looks like without
/// a live window to open a panel in.
struct DocMenuPreview<Content: View>: View {
    var width: CGFloat = 220
    @ViewBuilder var content: () -> Content

    var body: some View {
        ShadPopoverSurface {
            VStack(alignment: .leading, spacing: 2) { content() }
                .frame(width: width, alignment: .leading)
        }
        .fixedSize()
    }
}
