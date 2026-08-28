import SwiftUI

private struct ShadDialogDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Closes the enclosing dialog.
    public var shadDialogDismiss: () -> Void {
        get { self[ShadDialogDismissKey.self] }
        set { self[ShadDialogDismissKey.self] = newValue }
    }
}

extension View {
    /// Presents a modal dialog over this view.
    ///
    /// Attach it to the root of a window so the scrim covers everything:
    ///
    /// ```swift
    /// ContentView()
    ///     .shadDialog(isPresented: $isEditing) {
    ///         ShadDialogContent {
    ///             ShadDialogHeader {
    ///                 ShadDialogTitle("Edit profile")
    ///                 ShadDialogDescription("Make changes to your profile here.")
    ///             }
    ///             ShadDialogFooter { ShadButton("Save changes") {} }
    ///         }
    ///     }
    /// ```
    public func shadDialog<Content: View>(
        isPresented: Binding<Bool>,
        dismissOnBackdropTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ShadDialogPresenter(
            isPresented: isPresented,
            dismissOnBackdropTap: dismissOnBackdropTap,
            dialogContent: content
        ))
    }
}

private struct ShadDialogPresenter<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dismissOnBackdropTap: Bool
    @ViewBuilder let dialogContent: () -> DialogContent
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadStaticRendering) private var isStatic

    func body(content: Content) -> some View {
        ZStack {
            // The app itself is blurred, so the scrim reads as frosted glass
            // rather than a flat grey sheet. A `Material` cannot do this in an
            // in-window overlay — it tints against the window, not the content.
            content
                .blur(radius: isPresented ? theme.motion.dialogBackdropBlur : 0)
                // A blur samples past the view's bounds; clipping keeps the
                // softened edge inside the window.
                .clipped()
                .allowsHitTesting(!isPresented)

            if isPresented {
                theme.colors.overlay
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnBackdropTap { close() }
                    }
                    .transition(.opacity)

                dialogContent()
                    .environment(\.shadDialogDismiss, close)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.96).combined(with: .opacity),
                            removal: .scale(scale: 0.98).combined(with: .opacity)
                        )
                    )
                    .zIndex(100)
            }
        }
        .animation(theme.presentationAnimation, value: isPresented)
        .background {
            // Escape closes the top-most dialog. Left out while rendering to an
            // image, where NSViewRepresentable draws a placeholder.
            if !isStatic {
                ShadKeyCatcher(isActive: isPresented, onEscape: close)
            }
        }
    }

    private func close() {
        withAnimation(theme.presentationAnimation) { isPresented = false }
    }
}

/// Invisible helper that watches for the Escape key while a dialog is open.
struct ShadKeyCatcher: NSViewRepresentable {
    let isActive: Bool
    let onEscape: () -> Void

    func makeNSView(context: Context) -> NSView { NSView(frame: .zero) }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onEscape = onEscape
        context.coordinator.setActive(isActive)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        MainActor.assumeIsolated { coordinator.setActive(false) }
    }

    @MainActor
    final class Coordinator {
        var onEscape: () -> Void = {}
        private var monitor: Any?

        func setActive(_ active: Bool) {
            if active, monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                    guard event.keyCode == 53 else { return event }
                    self?.onEscape()
                    return nil
                }
            } else if !active, let existing = monitor {
                NSEvent.removeMonitor(existing)
                monitor = nil
            }
        }

        deinit {
            if let monitor { NSEvent.removeMonitor(monitor) }
        }
    }
}

/// The dialog panel itself.
///
/// Pass the optional `footer:` slot to get shadcn's bar footer: a muted strip
/// that runs the full width of the panel, separated by a rule. It stays put
/// while a ``ShadDialogBody`` scrolls above it.
public struct ShadDialogContent<Content: View, Footer: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadDialogDismiss) private var dismiss

    private let maxWidth: CGFloat
    private let showsCloseButton: Bool
    private let content: Content
    private let footer: Footer
    private let hasFooterBar: Bool

    public init(
        maxWidth: CGFloat = 512,
        showsCloseButton: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.maxWidth = maxWidth
        self.showsCloseButton = showsCloseButton
        self.content = content()
        self.footer = footer()
        self.hasFooterBar = true
    }

    fileprivate init(
        maxWidth: CGFloat,
        showsCloseButton: Bool,
        content: Content,
        footer: Footer,
        hasFooterBar: Bool
    ) {
        self.maxWidth = maxWidth
        self.showsCloseButton = showsCloseButton
        self.content = content
        self.footer = footer
        self.hasFooterBar = hasFooterBar
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasFooterBar {
                ShadSeparator()
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(theme.colors.muted.opacity(theme.colorScheme == .dark ? 0.4 : 0.6))
            }
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                .fill(theme.colors.background)
        )
        .overlay(
            ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
        )
        .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
        .shadElevation(theme.shadows.lg, cornerRadius: theme.radius.lg, fill: theme.colors.background)
        .overlay(alignment: .topTrailing) {
            if showsCloseButton {
                Button(action: dismiss) {
                    ShadIconView(.x, size: 14)
                        .foregroundStyle(theme.colors.mutedForeground)
                        .padding(6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadPointerCursor()
                .padding(12)
                .accessibilityLabel("Close")
            }
        }
        .padding(24)
    }
}

/// Title and description, stacked.
public struct ShadDialogHeader<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The dialog's heading.
public struct ShadDialogTitle: View {
    @Environment(\.shadTheme) private var theme
    private let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.lg, theme.typography.semibold))
            .foregroundStyle(theme.colors.foreground)
    }
}

/// The dialog's supporting copy.
public struct ShadDialogDescription: View {
    @Environment(\.shadTheme) private var theme
    private let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.mutedForeground)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A scrolling body, so a long dialog keeps its header and footer pinned.
public struct ShadDialogBody<Content: View>: View {
    private let maxHeight: CGFloat
    private let content: Content

    public init(maxHeight: CGFloat = 360, @ViewBuilder content: () -> Content) {
        self.maxHeight = maxHeight
        self.content = content()
    }

    public var body: some View {
        ShadScrollContainer {
            VStack(alignment: .leading, spacing: 16) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: maxHeight)
    }
}

/// The dialog's action row, right-aligned like shadcn's `DialogFooter`.
public struct ShadDialogFooter<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            content
        }
        .frame(maxWidth: .infinity)
    }
}

/// A button that closes the enclosing dialog, optionally running an action first.
public struct ShadDialogClose<Label: View>: View {
    @Environment(\.shadDialogDismiss) private var dismiss
    private let action: () -> Void
    private let label: () -> Label

    public init(action: @escaping () -> Void = {}, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button {
            action()
            dismiss()
        } label: {
            label()
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
    }
}

extension ShadDialogContent where Footer == EmptyView {
    /// A dialog with no footer bar; put a ``ShadDialogFooter`` in the content
    /// instead when you want the buttons inside the padded body.
    public init(
        maxWidth: CGFloat = 512,
        showsCloseButton: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            maxWidth: maxWidth,
            showsCloseButton: showsCloseButton,
            content: content(),
            footer: EmptyView(),
            hasFooterBar: false
        )
    }
}

extension ShadDialogClose where Label == ShadDialogCloseLabel {
    /// A close button rendered as a standard shadcn button.
    public init(
        _ title: String,
        variant: ShadButtonVariant = .outline,
        size: ShadButtonSize = .default,
        action: @escaping () -> Void = {}
    ) {
        self.init(action: action) {
            ShadDialogCloseLabel(title: title, variant: variant, size: size)
        }
    }
}

/// The button chrome used by ``ShadDialogClose``'s convenience initialiser.
public struct ShadDialogCloseLabel: View {
    let title: String
    let variant: ShadButtonVariant
    let size: ShadButtonSize

    public var body: some View {
        ShadButtonSurface(
            variant: variant,
            size: size,
            shape: .rounded,
            isLoading: false,
            fillsWidth: false,
            isPressed: false
        ) {
            Text(title)
        }
    }
}
