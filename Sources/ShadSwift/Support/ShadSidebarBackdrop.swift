#if os(macOS)
import AppKit
import SwiftUI

/// AppKit owns the backdrop capture. SwiftUI materials only sample this window.
struct ShadSidebarBackdrop: NSViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        // The gallery's theme can differ from the system appearance.
        view.appearance = NSAppearance(named: colorScheme == .dark ? .darkAqua : .aqua)
    }
}
#endif
