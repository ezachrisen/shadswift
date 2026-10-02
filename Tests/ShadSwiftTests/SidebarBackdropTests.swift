#if os(macOS)
import AppKit
import SwiftUI
import XCTest
import ShadSwift

final class SidebarBackdropTests: XCTestCase {
    /// Render the public component, not an isolated effect view, so an opaque
    /// SwiftUI fallback cannot silently replace the native backdrop again.
    @MainActor
    func testTranslucentStylesUseBehindWindowBlending() async {
        let host = makeHost()
        defer { host.window.close() }

        for style in [ShadSidebarBackgroundStyle.translucent, .glass] {
            host.view.rootView = Fixture(style: style)
            host.view.layoutSubtreeIfNeeded()

            let backdrops = sidebarBackdrops(in: host.view)
            XCTAssertEqual(backdrops.count, 1, "\(style) must render a native sidebar backdrop")
            XCTAssertEqual(backdrops.first?.blendingMode, .behindWindow)
            XCTAssertEqual(backdrops.first?.state, .followsWindowActiveState)
            XCTAssertGreaterThan(backdrops.first?.bounds.width ?? 0, 0)
            XCTAssertGreaterThan(backdrops.first?.bounds.height ?? 0, 0)
        }
    }

    @MainActor
    func testSolidRemovesNativeBackdrop() async {
        let host = makeHost()
        defer { host.window.close() }

        for style in [ShadSidebarBackgroundStyle.translucent, .glass] {
            host.view.rootView = Fixture(style: style)
            host.view.layoutSubtreeIfNeeded()
            XCTAssertEqual(sidebarBackdrops(in: host.view).count, 1)

            host.view.rootView = Fixture(style: .solid)
            host.view.layoutSubtreeIfNeeded()
            XCTAssertTrue(sidebarBackdrops(in: host.view).isEmpty)
        }
    }

    @MainActor
    func testBackdropTracksTheSelectedAppearance() async {
        let host = makeHost()
        defer { host.window.close() }

        for scheme in [ColorScheme.dark, .light] {
            host.view.rootView = Fixture(style: .translucent, scheme: scheme)
            host.view.layoutSubtreeIfNeeded()
            XCTAssertEqual(
                sidebarBackdrops(in: host.view).first?.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]),
                scheme == .dark ? .darkAqua : .aqua
            )
        }
    }

    @MainActor
    private func makeHost() -> (view: NSHostingView<Fixture>, window: NSWindow) {
        _ = NSApplication.shared
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false
        )
        window.isReleasedWhenClosed = false
        let view = NSHostingView(rootView: Fixture(style: .solid))
        window.contentView = view
        view.layoutSubtreeIfNeeded()
        return (view, window)
    }

    @MainActor
    private func sidebarBackdrops(in view: NSView) -> [NSVisualEffectView] {
        let current = (view as? NSVisualEffectView).flatMap { $0.material == .sidebar ? $0 : nil }
        return (current.map { [$0] } ?? []) + view.subviews.flatMap { sidebarBackdrops(in: $0) }
    }
}

private struct Fixture: View {
    let style: ShadSidebarBackgroundStyle
    var scheme: ColorScheme = .light
    @StateObject private var state = ShadSidebarState()

    var body: some View {
        ShadSidebarProvider(state: state, backgroundStyle: style) {
            ShadSidebar {
                Text("Sidebar")
            }
            ShadSidebarInset {
                Text("Opaque main content")
            }
        }
        .shadTheme(.default, colorScheme: scheme)
    }
}
#endif
