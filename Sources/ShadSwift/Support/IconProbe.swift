import SwiftUI

/// Test seam: lets a harness verify that every bundled glyph actually
/// produces geometry, rather than silently rendering nothing.
public enum ShadLucideDataProbe {
    static func commands(for name: String) -> [ShadVectorCommand]? {
        ShadLucideData.icons[name]
    }

    /// Every bundled Lucide name.
    public static var allNames: [String] { Array(ShadLucideData.icons.keys).sorted() }

    /// The bounding box a glyph draws into, in its 24×24 grid.
    public static func boundingBox(forName name: String) -> CGRect {
        guard let commands = ShadLucideData.icons[name] else { return .null }
        return ShadLucideShape(commands: commands)
            .path(in: CGRect(x: 0, y: 0, width: 24, height: 24))
            .boundingRect
    }
}

enum ShadLucideProbe {
    static func boundingBox(_ commands: [ShadVectorCommand]) -> CGRect {
        ShadLucideShape(commands: commands)
            .path(in: CGRect(x: 0, y: 0, width: 24, height: 24))
            .boundingRect
    }
}
