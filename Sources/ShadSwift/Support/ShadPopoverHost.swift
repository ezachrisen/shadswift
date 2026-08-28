import SwiftUI
import AppKit

/// Where a popover sits relative to its trigger.
public enum ShadPopoverAlignment: Sendable, Hashable {
    case bottomLeading
    case bottomTrailing
    case bottomCenter
    case topLeading
    case topTrailing
    case topCenter
    case trailingTop
    case leadingTop
    /// Beside the trigger, with the panel's bottom edge level with the
    /// trigger's — what a menu anchored to the foot of a sidebar wants.
    case trailingBottom
    case leadingBottom
    /// Overlays the trigger, so a chosen row inside the panel sits exactly on
    /// top of it. This is how a shadcn Select opens, and how a macOS pop-up
    /// button has always behaved.
    case overTrigger

    var prefersAbove: Bool {
        switch self {
        case .topLeading, .topTrailing, .topCenter: return true
        default: return false
        }
    }
}

/// Keys a popover intercepts while it is open.
public enum ShadPopoverKey: Sendable, Hashable {
    case escape
    case up
    case down
    case `return`
    case tab
    case home
    case end
}

/// Configuration for a popover panel.
public struct ShadPopoverConfiguration: Sendable {
    public var alignment: ShadPopoverAlignment
    /// Gap between trigger and panel, in points.
    public var gap: CGFloat
    /// When true the panel is at least as wide as its trigger.
    public var matchesTriggerWidth: Bool
    /// Hard cap on panel height before its content scrolls.
    public var maxHeight: CGFloat
    /// Dismiss when the pointer clicks outside the panel.
    public var dismissesOnOutsideClick: Bool
    /// Let the panel take key focus. Required when the panel contains a text
    /// field, as the combobox's popup-trigger mode does.
    public var becomesKey: Bool
    /// With ``ShadPopoverAlignment/overTrigger``, how far below the panel's top
    /// edge the row that should line up with the trigger begins.
    public var verticalAnchorOffset: CGFloat

    public init(
        alignment: ShadPopoverAlignment = .bottomLeading,
        gap: CGFloat = 4,
        matchesTriggerWidth: Bool = false,
        maxHeight: CGFloat = 384,
        dismissesOnOutsideClick: Bool = true,
        becomesKey: Bool = false,
        verticalAnchorOffset: CGFloat = 0
    ) {
        self.alignment = alignment
        self.gap = gap
        self.matchesTriggerWidth = matchesTriggerWidth
        self.maxHeight = maxHeight
        self.dismissesOnOutsideClick = dismissesOnOutsideClick
        self.becomesKey = becomesKey
        self.verticalAnchorOffset = verticalAnchorOffset
    }
}

// MARK: - Panel

/// A borderless, non-activating panel. Unlike `NSPopover` it has no arrow and
/// no system chrome, so the SwiftUI content defines the entire appearance.
final class ShadPanel: NSPanel {
    var acceptsKey = false
    override var canBecomeKey: Bool { acceptsKey }
    override var canBecomeMain: Bool { false }
}

/// Amount of transparent margin kept around the panel content so the SwiftUI
/// drop shadow has room to draw.
private let shadowPadding: CGFloat = 28

// MARK: - Host

@MainActor
final class ShadPopoverController {
    private var panel: ShadPanel?
    private var hostingController: NSHostingController<AnyView>?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var keyMonitor: Any?
    private weak var anchorView: NSView?
    private var configuration = ShadPopoverConfiguration()

    var onDismiss: () -> Void = {}
    var onKey: (ShadPopoverKey) -> Bool = { _ in false }

    var isOpen: Bool { panel != nil }

    func present(
        content: AnyView,
        from anchor: NSView,
        configuration: ShadPopoverConfiguration,
        remainingAttempts: Int = 20
    ) {
        anchorView = anchor
        guard let parentWindow = anchor.window else {
            // The anchor is not in a window yet — which happens when a popover
            // starts out open, before first layout. Try again next turn rather
            // than dropping the request on the floor.
            guard remainingAttempts > 0 else { return }
            DispatchQueue.main.async { [weak self] in
                self?.present(
                    content: content,
                    from: anchor,
                    configuration: configuration,
                    remainingAttempts: remainingAttempts - 1
                )
            }
            return
        }

        let wrapped = wrap(content, configuration: configuration, anchor: anchor)

        if let hostingController {
            hostingController.rootView = wrapped
            reposition(configuration: configuration)
            return
        }

        let controller = NSHostingController(rootView: wrapped)
        controller.sizingOptions = [.preferredContentSize]
        hostingController = controller

        let panel = ShadPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.acceptsKey = configuration.becomesKey
        panel.contentViewController = controller
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovable = false
        panel.level = .popUpMenu
        panel.hidesOnDeactivate = true
        panel.animationBehavior = .none
        panel.collectionBehavior = [.transient, .ignoresCycle, .fullScreenAuxiliary]
        self.panel = panel

        self.configuration = configuration
        parentWindow.addChildWindow(panel, ordered: .above)
        layoutAndReposition()
        panel.orderFront(nil)
        if configuration.becomesKey {
            panel.makeKey()
        }

        installMonitors(configuration: configuration)
    }

    func update(content: AnyView, configuration: ShadPopoverConfiguration) {
        guard let hostingController, let anchorView else { return }
        self.configuration = configuration
        hostingController.rootView = wrap(content, configuration: configuration, anchor: anchorView)
        layoutAndReposition()
    }

    /// Sizes the panel from its content, then places it.
    ///
    /// Placement depends on the panel's height — a Select lines a specific row
    /// up with its trigger — so measuring has to happen first. Laying out on
    /// the next turn as well catches content that settles a frame later.
    private func layoutAndReposition() {
        guard let panel, let controller = hostingController else { return }
        controller.view.layoutSubtreeIfNeeded()
        let fitting = controller.view.fittingSize
        if fitting.width > 0, fitting.height > 0 {
            panel.setContentSize(fitting)
        }
        reposition(configuration: configuration)

        DispatchQueue.main.async { [weak self] in
            guard let self, let panel = self.panel, let controller = self.hostingController else { return }
            controller.view.layoutSubtreeIfNeeded()
            let settled = controller.view.fittingSize
            if settled.width > 0, settled.height > 0, settled != panel.frame.size {
                panel.setContentSize(settled)
            }
            self.reposition(configuration: self.configuration)
        }
    }

    func dismiss() {
        removeMonitors()
        if let panel {
            panel.parent?.removeChildWindow(panel)
            panel.orderOut(nil)
            panel.contentViewController = nil
        }
        panel = nil
        hostingController = nil
        anchorView = nil
    }

    // MARK: Layout

    private func wrap(_ content: AnyView, configuration: ShadPopoverConfiguration, anchor: NSView) -> AnyView {
        if configuration.matchesTriggerWidth {
            // shadcn sizes a Select panel with `w-(--anchor-width)`: exactly the
            // trigger's width, floored at `min-w-36`. Asking for a minimum
            // instead leaves the hosting controller free to measure the content
            // and come back narrower than the field.
            let width = max(anchor.bounds.width, 144)
            return AnyView(
                content
                    .frame(width: width, alignment: .leading)
                    .frame(maxHeight: configuration.maxHeight)
                    .fixedSize(horizontal: false, vertical: false)
                    .padding(shadowPadding)
            )
        }
        return AnyView(
            content
                .frame(maxHeight: configuration.maxHeight)
                .fixedSize(horizontal: true, vertical: false)
                .padding(shadowPadding)
        )
    }

    private func reposition(configuration: ShadPopoverConfiguration) {
        guard let panel, let anchorView, let parentWindow = anchorView.window else { return }

        let localRect = anchorView.convert(anchorView.bounds, to: nil)
        let anchorRect = parentWindow.convertToScreen(localRect)

        var size = panel.frame.size
        // A panel that matches its trigger must never come out narrower than
        // it; the difference reads as a misaligned, floating list.
        if configuration.matchesTriggerWidth {
            let wanted = max(anchorRect.width, 144) + shadowPadding * 2
            if abs(size.width - wanted) > 0.5 {
                panel.setContentSize(NSSize(width: wanted, height: size.height))
                size = panel.frame.size
            }
        }
        let contentWidth = size.width - shadowPadding * 2
        let contentHeight = size.height - shadowPadding * 2

        var x: CGFloat
        switch configuration.alignment {
        case .bottomLeading, .topLeading, .leadingTop, .leadingBottom, .overTrigger:
            x = anchorRect.minX
        case .bottomTrailing, .topTrailing, .trailingTop, .trailingBottom:
            x = anchorRect.maxX - contentWidth
        case .bottomCenter, .topCenter:
            x = anchorRect.midX - contentWidth / 2
        }
        switch configuration.alignment {
        case .trailingTop, .trailingBottom:
            x = anchorRect.maxX + configuration.gap
        case .leadingTop, .leadingBottom:
            x = anchorRect.minX - contentWidth - configuration.gap
        default:
            break
        }

        var y: CGFloat
        var above = configuration.alignment.prefersAbove
        let screen = parentWindow.screen ?? NSScreen.main
        let visible = screen?.visibleFrame ?? .zero

        switch configuration.alignment {
        case .trailingTop, .leadingTop:
            y = anchorRect.maxY - contentHeight
        case .trailingBottom, .leadingBottom:
            y = anchorRect.minY
        case .overTrigger:
            // Line the requested row up with the trigger's top edge.
            y = anchorRect.maxY + configuration.verticalAnchorOffset - contentHeight
        default:
            if !above, anchorRect.minY - configuration.gap - contentHeight < visible.minY,
               anchorRect.maxY + configuration.gap + contentHeight <= visible.maxY {
                above = true
            } else if above, anchorRect.maxY + configuration.gap + contentHeight > visible.maxY {
                above = false
            }
            y = above
                ? anchorRect.maxY + configuration.gap
                : anchorRect.minY - configuration.gap - contentHeight
        }

        // Keep the panel on screen.
        x = min(max(x, visible.minX + 8), max(visible.minX + 8, visible.maxX - contentWidth - 8))
        y = min(max(y, visible.minY + 8), max(visible.minY + 8, visible.maxY - contentHeight - 8))

        panel.setFrameOrigin(NSPoint(x: x - shadowPadding, y: y - shadowPadding))

        // Set SHADSWIFT_POPOVER_DEBUG to trace placement. Panels are separate
        // windows, so when one lands in the wrong place there is nothing in the
        // view hierarchy to inspect.
        if ProcessInfo.processInfo.environment["SHADSWIFT_POPOVER_DEBUG"] != nil {
            let line = "popover align=\(configuration.alignment)"
                + " anchor=(\(Int(anchorRect.minX)),\(Int(anchorRect.minY)) \(Int(anchorRect.width))x\(Int(anchorRect.height)))"
                + " content=\(Int(contentWidth))x\(Int(contentHeight))"
                + " placed=(\(Int(x)),\(Int(y)))\n"
            FileHandle.standardError.write(Data(line.utf8))
        }
    }

    // MARK: Event monitors

    private func installMonitors(configuration: ShadPopoverConfiguration) {
        if configuration.dismissesOnOutsideClick {
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
                guard let self, let panel = self.panel else { return event }
                // Ignore clicks inside this panel or any panel it owns, so a
                // submenu does not tear down the menu that opened it.
                var window = event.window
                while let current = window {
                    if current === panel { return event }
                    window = current.parent
                }
                // A click on the trigger is the trigger's business: it toggles
                // the panel closed. Dismissing here too would reopen it.
                if let anchor = self.anchorView, let anchorWindow = anchor.window,
                   event.window === anchorWindow {
                    let point = anchor.convert(event.locationInWindow, from: nil)
                    if anchor.bounds.contains(point) { return event }
                }
                // A click on the trigger itself is handled by the trigger; it
                // toggles the popover shut on its own.
                DispatchQueue.main.async { self.onDismiss() }
                return event
            }
            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async { self.onDismiss() }
            }
        }

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self, self.panel != nil else { return event }
            let key: ShadPopoverKey?
            switch event.keyCode {
            case 53: key = .escape
            case 126: key = .up
            case 125: key = .down
            case 36, 76: key = .return
            case 48: key = .tab
            case 115: key = .home
            case 119: key = .end
            default: key = nil
            }
            guard let key else { return event }
            if key == .escape {
                self.onDismiss()
                return nil
            }
            return self.onKey(key) ? nil : event
        }
    }

    private func removeMonitors() {
        for monitor in [localMonitor, globalMonitor, keyMonitor].compactMap({ $0 }) {
            NSEvent.removeMonitor(monitor)
        }
        localMonitor = nil
        globalMonitor = nil
        keyMonitor = nil
    }

    deinit {
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
    }
}

// MARK: - SwiftUI bridge

private struct ShadPopoverBridge<PopoverContent: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    let configuration: ShadPopoverConfiguration
    let theme: ShadTheme
    let onKey: (ShadPopoverKey) -> Bool
    @ViewBuilder let content: () -> PopoverContent

    func makeNSView(context: Context) -> NSView {
        let view = ShadAnchorView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        let controller = context.coordinator.controller
        controller.onDismiss = { isPresented = false }
        controller.onKey = onKey

        let hosted = AnyView(content().shadTheme(theme))

        if isPresented {
            // The bridge sits in the trigger's `.background`, so it already has
            // exactly the trigger's bounds — no superview walking needed.
            let anchor = nsView
            if controller.isOpen {
                controller.update(content: hosted, configuration: configuration)
            } else {
                DispatchQueue.main.async {
                    controller.present(content: hosted, from: anchor, configuration: configuration)
                }
            }
        } else if controller.isOpen {
            controller.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    @MainActor
    final class Coordinator {
        let controller = ShadPopoverController()
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        MainActor.assumeIsolated { coordinator.controller.dismiss() }
    }
}

/// A zero-size, click-through view used purely to locate the trigger on screen.
private final class ShadAnchorView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
    override var isFlipped: Bool { true }
}

extension View {
    /// Presents `content` in a borderless panel anchored to this view.
    ///
    /// Unlike an overlay, the panel is a real window: it is never clipped by a
    /// `ScrollView` and it can extend past the edge of the app's window.
    public func shadPopover<Content: View>(
        isPresented: Binding<Bool>,
        configuration: ShadPopoverConfiguration = ShadPopoverConfiguration(),
        onKey: @escaping (ShadPopoverKey) -> Bool = { _ in false },
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ShadPopoverPresenter(
            isPresented: isPresented,
            configuration: configuration,
            onKey: onKey,
            popoverContent: content
        ))
    }
}

private struct ShadPopoverPresenter<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: ShadPopoverConfiguration
    let onKey: (ShadPopoverKey) -> Bool
    @ViewBuilder let popoverContent: () -> PopoverContent
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadStaticRendering) private var isStatic

    func body(content: Content) -> some View {
        if isStatic {
            // `ImageRenderer` draws any NSViewRepresentable as a placeholder
            // block, so the anchor is left out of snapshots entirely.
            content
        } else {
            content.background(
                ShadPopoverBridge(
                    isPresented: $isPresented,
                    configuration: configuration,
                    theme: theme,
                    onKey: onKey,
                    content: popoverContent
                )
                .allowsHitTesting(false)
            )
        }
    }
}

/// The standard popover surface: rounded, bordered, elevated. Every menu,
/// select and combobox panel in the library is built on it.
public struct ShadPopoverSurface<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let padding: CGFloat
    private let content: Content

    public init(padding: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                    .fill(theme.colors.popover)
            )
            // A hairline at 10% foreground plus a soft shadow, which is how a
            // shadcn menu separates itself from the page.
            .overlay(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                    .strokeBorder(theme.colors.foreground.opacity(0.10), lineWidth: theme.borderWidth)
            )
            .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
            .shadElevation(theme.shadows.md, cornerRadius: theme.radius.lg, fill: theme.colors.popover)
            .foregroundStyle(theme.colors.popoverForeground)
            .font(theme.font(theme.typography.sm))
    }
}
