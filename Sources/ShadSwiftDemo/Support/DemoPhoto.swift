import AppKit

/// A stand-in photograph, drawn rather than shipped.
///
/// The avatar editor needs a real picture to show off zooming and panning, and
/// a wide one makes the point better than a square: at 1× it already overhangs
/// the mask, so there is something to drag straight away.
enum DemoPhoto {
    static let landscape: NSImage = render()

    private static func render() -> NSImage {
        NSImage(size: NSSize(width: 720, height: 480), flipped: false) { rect in
            NSGradient(
                colors: [
                    NSColor(srgbRed: 0.16, green: 0.22, blue: 0.42, alpha: 1),
                    NSColor(srgbRed: 0.43, green: 0.35, blue: 0.58, alpha: 1),
                    NSColor(srgbRed: 0.94, green: 0.62, blue: 0.44, alpha: 1),
                ],
                atLocations: [0, 0.55, 1],
                colorSpace: .sRGB
            )?.draw(in: rect, angle: -90)

            // Sun
            NSColor(srgbRed: 1, green: 0.94, blue: 0.78, alpha: 0.95).setFill()
            NSBezierPath(ovalIn: NSRect(x: rect.width * 0.62, y: rect.height * 0.46, width: 96, height: 96)).fill()

            // Two ridges, back to front
            NSColor(srgbRed: 0.24, green: 0.22, blue: 0.38, alpha: 0.85).setFill()
            ridge(in: rect, baseline: 0.16, peaks: [(0.05, 0.42), (0.32, 0.30), (0.6, 0.5), (0.9, 0.34)]).fill()

            NSColor(srgbRed: 0.12, green: 0.13, blue: 0.24, alpha: 1).setFill()
            ridge(in: rect, baseline: 0, peaks: [(0.0, 0.22), (0.25, 0.34), (0.55, 0.2), (0.82, 0.3), (1.0, 0.18)]).fill()

            return true
        }
    }

    /// A filled silhouette running the width of `rect`, through `peaks` given
    /// in unit coordinates.
    private static func ridge(
        in rect: NSRect,
        baseline: CGFloat,
        peaks: [(x: CGFloat, y: CGFloat)]
    ) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: rect.height * baseline))
        for peak in peaks {
            path.line(to: NSPoint(x: rect.width * peak.x, y: rect.height * peak.y))
        }
        path.line(to: NSPoint(x: rect.width, y: rect.height * baseline))
        path.line(to: NSPoint(x: rect.width, y: 0))
        path.line(to: NSPoint(x: 0, y: 0))
        path.close()
        return path
    }
}
