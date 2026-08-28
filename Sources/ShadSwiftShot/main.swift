import AppKit
import SwiftUI
import ShadSwift

@MainActor
func shot<V: View>(_ name: String, width: CGFloat, height: CGFloat?, scheme: ColorScheme = .light, @ViewBuilder _ view: () -> V) {
    let themeSet = ShadThemeSet.default
    let theme = themeSet.resolved(for: scheme)
    let content = view()
        .padding(24)
        .frame(width: width, alignment: .leading)
        .frame(height: height)
        .background(theme.colors.background)
        .shadStaticRendering()
        .shadTheme(themeSet, colorScheme: scheme)
        .environment(\.colorScheme, scheme)
        .font(theme.font(theme.typography.sm))
        .foregroundStyle(theme.colors.foreground)

    let renderer = ImageRenderer(content: content)
    renderer.scale = 2
    renderer.isOpaque = true
    guard let image = renderer.cgImage,
          let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        print("FAILED \(name)")
        return
    }
    try? data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("\(name).png"))
    let rep = NSBitmapImageRep(cgImage: image)
    print("\(name): \(image.width)x\(image.height) corner=\(rep.colorAt(x: 50, y: 50)?.description ?? "nil")")
}

func sample() -> NSImage {
    NSImage(size: NSSize(width: 720, height: 480), flipped: false) { rect in
        NSGradient(colors: [
            NSColor(srgbRed: 0.16, green: 0.22, blue: 0.42, alpha: 1),
            NSColor(srgbRed: 0.43, green: 0.35, blue: 0.58, alpha: 1),
            NSColor(srgbRed: 0.94, green: 0.62, blue: 0.44, alpha: 1),
        ], atLocations: [0, 0.55, 1], colorSpace: .sRGB)?.draw(in: rect, angle: -90)
        NSColor(srgbRed: 1, green: 0.94, blue: 0.78, alpha: 0.95).setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.width * 0.62, y: rect.height * 0.46, width: 96, height: 96)).fill()
        // Edge markers, so a bad clamp shows up as a visible seam.
        NSColor.systemRed.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: 20, height: rect.height)).fill()
        NSColor.systemGreen.setFill()
        NSBezierPath(rect: NSRect(x: rect.width - 20, y: 0, width: 20, height: rect.height)).fill()
        return true
    }
}

MainActor.assumeIsolated {
    let image = sample()
    let photo = ShadAvatarPhoto(image: image)

    shot("cropper-fill", width: 340, height: nil) { ShadAvatarCropper(photo: .constant(photo)) }
    shot("cropper-empty", width: 340, height: nil) { ShadAvatarCropper(photo: .constant(.empty)) }

    var zoomed = photo
    zoomed.zoom(to: 2)
    zoomed.pan(to: CGSize(width: -0.4, height: 0.3))
    shot("cropper-zoomed", width: 340, height: nil) { ShadAvatarCropper(photo: .constant(zoomed)) }

    shot("sizes", width: 340, height: nil) {
        HStack(spacing: 16) {
            ShadAvatar(photo: zoomed, fallback: "EV", size: .sm)
            ShadAvatar(photo: zoomed, fallback: "EV")
            ShadAvatar(photo: zoomed, fallback: "EV", size: .lg)
            ShadAvatar(photo: zoomed, fallback: "EV", customSize: 56, shape: .rounded)
            ShadAvatar(photo: zoomed, fallback: "EV", customSize: 96)
        }
    }

    // Clamping: an extreme pan must never expose an edge, at any zoom.
    var pushed = photo
    pushed.pan(to: CGSize(width: 9, height: 9))
    print("pan(9,9) at 1x ->", pushed.crop.offset)
    var pushedZoom = photo
    pushedZoom.zoom(to: 3)
    pushedZoom.pan(to: CGSize(width: 9, height: -9))
    print("pan(9,-9) at 3x ->", pushedZoom.crop.offset)
    var shrunk = pushedZoom
    shrunk.zoom(to: 1)
    print("then zoom back to 1x ->", shrunk.crop.offset)
    shot("clamped", width: 340, height: nil) {
        HStack(spacing: 16) {
            ShadAvatar(photo: pushed, customSize: 96)
            ShadAvatar(photo: pushedZoom, customSize: 96)
            ShadAvatar(photo: shrunk, customSize: 96)
            ShadAvatar(photo: ShadAvatarPhoto(image: image), customSize: 96)
        }
    }

    shot("editor-light", width: 560, height: 640) { ShadAvatarEditor(.constant(ShadAvatarEditorState(image: image))) }
    shot("editor-dark", width: 560, height: 640, scheme: .dark) { ShadAvatarEditor(.constant(ShadAvatarEditorState(image: image))) }
    shot("editor-empty", width: 560, height: 640) { ShadAvatarEditor(.constant(ShadAvatarEditorState())) }
}
