import SwiftUI
import ShadSwift

/// One rendered example inside a component page.
struct DocExample {
    let title: String
    var description: String? = nil
    /// The Swift shown in the code block.
    let code: String
    /// Width the snapshot is rendered at.
    var width: CGFloat = 720
    /// Fixed height, for examples that would otherwise be unbounded.
    var height: CGFloat? = nil
    /// Padding around the example inside its snapshot.
    var padding: CGFloat = 24
    /// False for code-only examples, which get no snapshot at all.
    var showsPreview: Bool = true
    let view: AnyView

    init(
        _ title: String,
        description: String? = nil,
        width: CGFloat = 720,
        height: CGFloat? = nil,
        padding: CGFloat = 24,
        code: String,
        @ViewBuilder view: () -> some View
    ) {
        self.title = title
        self.description = description
        self.code = code
        self.width = width
        self.height = height
        self.padding = padding
        self.view = AnyView(view())
    }

    /// A code-only example: no snapshot, just the Swift.
    init(_ title: String, description: String? = nil, code: String) {
        self.title = title
        self.description = description
        self.code = code
        self.showsPreview = false
        self.view = AnyView(EmptyView())
    }
}

/// A row in a component's API table.
struct DocProperty {
    let name: String
    let type: String
    var `default`: String? = nil
    let summary: String

    init(_ name: String, _ type: String, default defaultValue: String? = nil, _ summary: String) {
        self.name = name
        self.type = type
        self.default = defaultValue
        self.summary = summary
    }
}

/// A documented type and its properties.
struct DocAPI {
    let name: String
    var summary: String? = nil
    let properties: [DocProperty]

    init(_ name: String, summary: String? = nil, _ properties: [DocProperty]) {
        self.name = name
        self.summary = summary
        self.properties = properties
    }
}

/// One page of the generated documentation.
struct DocComponent {
    let slug: String
    let title: String
    let summary: String
    var group: String = "Components"
    var anatomy: String? = nil
    var importLine: String = "import ShadSwift"
    let examples: [DocExample]
    var notes: [String] = []
    var api: [DocAPI] = []
}
