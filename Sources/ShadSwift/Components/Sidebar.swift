import SwiftUI

/// Which edge the sidebar lives on.
public enum ShadSidebarSide: String, CaseIterable, Sendable {
    case left
    case right
}

/// The three sidebar treatments.
public enum ShadSidebarVariant: String, CaseIterable, Sendable {
    /// A flush panel with a border on its inner edge.
    case sidebar
    /// A detached, rounded panel with a margin around it.
    case floating
    /// A transparent rail; the content beside it becomes a rounded card.
    case inset
}

/// What happens when the sidebar collapses.
public enum ShadSidebarCollapsible: String, CaseIterable, Sendable {
    /// Slides fully off-canvas.
    case offcanvas
    /// Narrows to an icon rail.
    case icon
    /// Never collapses.
    case none
}

/// Shared sidebar state. Reach it with `@Environment(\.shadSidebar)`.
public final class ShadSidebarState: ObservableObject {
    @Published public var isOpen: Bool
    /// Width of the expanded sidebar.
    public var width: CGFloat
    /// Width of the icon rail when `collapsible` is `.icon`.
    public var iconWidth: CGFloat

    public init(isOpen: Bool = true, width: CGFloat = 256, iconWidth: CGFloat = 48) {
        self.isOpen = isOpen
        self.width = width
        self.iconWidth = iconWidth
    }

    /// `"expanded"` or `"collapsed"`, mirroring shadcn's `state`.
    public var state: String { isOpen ? "expanded" : "collapsed" }

    public func toggle() { isOpen.toggle() }
    public func setOpen(_ open: Bool) { isOpen = open }
}

private struct ShadSidebarStateKey: EnvironmentKey {
    static let defaultValue = ShadSidebarState()
}

/// Which sidebar row the pointer is over.
///
/// SwiftUI delivers the new row's `onHover(true)` before the old row's
/// `onHover(false)`, so per-row state leaves two rows lit for a frame — the
/// flicker you see dragging down a list. A single shared value cannot do that.
private struct ShadSidebarHoveredRowKey: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

private struct ShadSidebarSetHoveredRowKey: EnvironmentKey {
    static let defaultValue: (UUID, Bool) -> Void = { _, _ in }
}

extension EnvironmentValues {
    var shadSidebarHoveredRow: UUID? {
        get { self[ShadSidebarHoveredRowKey.self] }
        set { self[ShadSidebarHoveredRowKey.self] = newValue }
    }

    var shadSidebarSetHoveredRow: (UUID, Bool) -> Void {
        get { self[ShadSidebarSetHoveredRowKey.self] }
        set { self[ShadSidebarSetHoveredRowKey.self] = newValue }
    }
}

extension EnvironmentValues {
    /// The enclosing sidebar's state.
    public var shadSidebar: ShadSidebarState {
        get { self[ShadSidebarStateKey.self] }
        set { self[ShadSidebarStateKey.self] = newValue }
    }
}

private struct ShadSidebarCollapsedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True when the sidebar is showing as an icon rail, so rows can hide
    /// their labels.
    public var shadSidebarIsIconOnly: Bool {
        get { self[ShadSidebarCollapsedKey.self] }
        set { self[ShadSidebarCollapsedKey.self] = newValue }
    }
}

/// The root layout: place a ``ShadSidebar`` and a ``ShadSidebarInset`` inside.
///
/// ```swift
/// ShadSidebarProvider(state: sidebarState) {
///     ShadSidebar(variant: .inset) {
///         ShadSidebarHeader { … }
///         ShadSidebarContent { … }
///         ShadSidebarFooter { … }
///     }
///     ShadSidebarInset {
///         ShadSidebarTrigger()
///         …
///     }
/// }
/// ```
public struct ShadSidebarProvider<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @ObservedObject private var state: ShadSidebarState
    @State private var hoveredRow: UUID?
    private let content: Content

    public init(state: ShadSidebarState, @ViewBuilder content: () -> Content) {
        self.state = state
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) {
            content
        }
        .environment(\.shadSidebar, state)
        .environment(\.shadSidebarHoveredRow, hoveredRow)
        .environment(\.shadSidebarSetHoveredRow) { id, inside in
            if inside {
                hoveredRow = id
            } else if hoveredRow == id {
                // Only clear if this row is still the tracked one — by the time
                // an exit arrives the pointer may already be on the next row.
                hoveredRow = nil
            }
        }
        .background(theme.colors.background)
    }
}

/// The collapsible panel itself.
public struct ShadSidebar<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebar) private var state

    private let side: ShadSidebarSide
    private let variant: ShadSidebarVariant
    private let collapsible: ShadSidebarCollapsible
    private let content: Content

    public init(
        side: ShadSidebarSide = .left,
        variant: ShadSidebarVariant = .sidebar,
        collapsible: ShadSidebarCollapsible = .icon,
        @ViewBuilder content: () -> Content
    ) {
        self.side = side
        self.variant = variant
        self.collapsible = collapsible
        self.content = content()
    }

    private var isIconOnly: Bool {
        collapsible == .icon && !state.isOpen
    }

    private var width: CGFloat {
        switch collapsible {
        case .none: return state.width
        case .icon: return state.isOpen ? state.width : state.iconWidth
        case .offcanvas: return state.isOpen ? state.width : 0
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(width: max(0, width - (variant == .sidebar ? 0 : 16)), alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(variant == .inset ? Color.clear : theme.colors.sidebar)
        .overlay(alignment: side == .left ? .trailing : .leading) {
            if variant == .sidebar {
                ShadSeparator(.vertical, color: theme.colors.sidebarBorder)
            }
        }
        .shadIf(variant == .floating) { view in
            view
                .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
                .background(
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .fill(theme.colors.sidebar)
                        .shadShadow(theme.shadows.sm)
                )
                .overlay(
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .strokeBorder(theme.colors.sidebarBorder, lineWidth: theme.borderWidth)
                )
        }
        .padding(variant == .sidebar ? 0 : 8)
        .frame(width: width)
        .clipped()
        .foregroundStyle(theme.colors.sidebarForeground)
        .environment(\.shadSidebarIsIconOnly, isIconOnly)
        .animation(theme.presentationAnimation, value: state.isOpen)
        .accessibilityHidden(width == 0)
    }
}

/// Sticky area at the top of the sidebar — branding, workspace switchers.
public struct ShadSidebarHeader<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The scrollable region between header and footer.
public struct ShadSidebarContent<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        ShadScrollContainer {
            VStack(alignment: .leading, spacing: 4) { content }
                .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

/// Sticky area at the bottom — user menus, settings.
public struct ShadSidebarFooter<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A titled section of the sidebar.
public struct ShadSidebarGroup<Content: View, Action: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly

    private let label: String?
    private let content: Content
    private let action: Action

    public init(
        _ label: String? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action
    ) {
        self.label = label
        self.content = content()
        self.action = action()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label, !isIconOnly {
                HStack(spacing: 4) {
                    Text(label)
                        .font(theme.font(theme.typography.xs, theme.typography.medium))
                        .foregroundStyle(theme.colors.sidebarForeground.opacity(0.6))
                    Spacer(minLength: 0)
                    action
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            content
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

extension ShadSidebarGroup where Action == EmptyView {
    public init(_ label: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(label, content: content, action: { EmptyView() })
    }
}

/// The vertical list of menu items.
public struct ShadSidebarMenu<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) { content }
    }
}

private struct ShadSidebarRowKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// True for views inside a ``ShadSidebarMenuItem``, which owns the row's
    /// hover highlight so the button and its action never fight over it.
    var shadSidebarInRow: Bool {
        get { self[ShadSidebarRowKey.self] }
        set { self[ShadSidebarRowKey.self] = newValue }
    }
}

/// One row of a sidebar menu.
///
/// The row — not the button inside it — owns the hover highlight, so moving
/// the pointer between the label and a trailing action never flickers, and the
/// whole row lights up as one piece.
public struct ShadSidebarMenuItem<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebarHoveredRow) private var hoveredRow
    @Environment(\.shadSidebarSetHoveredRow) private var setHovered

    @State private var id = UUID()
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    private var isHovering: Bool { hoveredRow == id }

    public var body: some View {
        HStack(spacing: 2) { content }
            .padding(.horizontal, 2)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(isHovering ? theme.colors.sidebarAccent : .clear)
            )
            .contentShape(Rectangle())
            .environment(\.shadSidebarInRow, true)
            .onHover { setHovered(id, $0) }
    }
}

/// The clickable body of a sidebar menu row.
public struct ShadSidebarMenuButton<Trailing: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let title: String
    private let icon: ShadIcon?
    private let isActive: Bool
    private let size: Size
    private let action: () -> Void
    private let trailing: Trailing

    /// Row heights, matching shadcn's `size` prop.
    public enum Size: String, CaseIterable, Sendable {
        case sm, `default`, lg

        var height: CGFloat {
            switch self {
            case .sm: return 28
            case .default: return 32
            case .lg: return 48
            }
        }
    }

    public init(
        _ title: String,
        icon: ShadIcon? = nil,
        isActive: Bool = false,
        size: Size = .default,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.size = size
        self.action = action
        self.trailing = trailing()
    }

    @Environment(\.shadSidebarInRow) private var isInRow

    /// The active row is marked by weight and colour, not by a fill — a filled
    /// selection reads as a permanent hover and fights the real one.
    private var background: Color {
        guard !isInRow else { return .clear }
        return isHovering ? theme.colors.sidebarAccent : .clear
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    ShadIconView(icon, size: 16)
                        .frame(width: 16)
                }
                if !isIconOnly {
                    Text(title)
                        .font(theme.font(theme.typography.sm, isActive ? theme.typography.medium : theme.typography.regular))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    trailing
                }
            }
            .foregroundStyle(isActive ? theme.colors.sidebarAccentForeground : theme.colors.sidebarForeground.opacity(0.85))
            .padding(.horizontal, 8)
            .frame(height: size.height)
            .frame(maxWidth: .infinity, alignment: isIconOnly ? .center : .leading)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.md).fill(background)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .help(isIconOnly ? title : "")
        .animation(theme.interactionAnimation, value: isHovering)
    }
}

extension ShadSidebarMenuButton where Trailing == EmptyView {
    public init(
        _ title: String,
        icon: ShadIcon? = nil,
        isActive: Bool = false,
        size: Size = .default,
        action: @escaping () -> Void
    ) {
        self.init(title, icon: icon, isActive: isActive, size: size, action: action) { EmptyView() }
    }
}

/// A count or status chip on a menu row.
public struct ShadSidebarMenuBadge: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.xs, theme.typography.medium))
            .foregroundStyle(theme.colors.sidebarForeground.opacity(0.7))
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.sm)
                    .fill(theme.colors.sidebarAccent)
            )
    }
}

extension View {
    /// Hides this view while the sidebar is collapsed to its icon rail.
    ///
    /// Row actions — a "more" button, an add button — have no room in a 48pt
    /// rail and no label to explain them, so they come back with the labels.
    public func shadSidebarHiddenWhenCollapsed() -> some View {
        modifier(ShadSidebarCollapseHiding())
    }
}

private struct ShadSidebarCollapseHiding: ViewModifier {
    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly

    func body(content: Content) -> some View {
        if !isIconOnly { content }
    }
}

/// A trailing control on a menu row, such as a "more" button.
public struct ShadSidebarMenuAction<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @State private var isHovering = false
    private let content: Content
    private let action: () -> Void

    public init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    @Environment(\.shadSidebarInRow) private var isInRow

    public var body: some View {
        if !isIconOnly {
            button
        }
    }

    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly

    private var button: some View {
        Button(action: action) {
            content
                .foregroundStyle(theme.colors.sidebarForeground.opacity(isHovering ? 1 : 0.6))
                .frame(width: 24, height: 24)
                .background(
                    ShadRoundedRectangle(cornerRadius: theme.radius.sm)
                        .fill(isHovering && !isInRow ? theme.colors.sidebarAccent : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering)
        .shadPointerCursor()
    }
}

/// A nested list under a menu row.
public struct ShadSidebarMenuSub<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        if !isIconOnly {
            VStack(alignment: .leading, spacing: 2) { content }
                .padding(.leading, 16)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(theme.colors.sidebarBorder)
                        .frame(width: 1)
                        .padding(.leading, 8)
                }
        }
    }
}

/// A row inside a ``ShadSidebarMenuSub``.
public struct ShadSidebarMenuSubButton: View {
    @Environment(\.shadTheme) private var theme
    @State private var isHovering = false

    private let title: String
    private let isActive: Bool
    private let action: () -> Void

    public init(_ title: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isActive = isActive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.font(theme.typography.sm, isActive ? theme.typography.medium : theme.typography.regular))
                .foregroundStyle(isActive ? theme.colors.sidebarAccentForeground : theme.colors.sidebarForeground.opacity(0.8))
                .padding(.horizontal, 8)
                .frame(height: 28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ShadRoundedRectangle(cornerRadius: theme.radius.md)
                        .fill(isHovering ? theme.colors.sidebarAccent : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering)
        .shadPointerCursor()
    }
}

/// The button that opens and closes the sidebar.
public struct ShadSidebarTrigger: View {
    @Environment(\.shadSidebar) private var state
    @Environment(\.shadTheme) private var theme

    public init() {}

    public var body: some View {
        ShadButton(icon: .panelLeft, variant: .ghost, size: .iconSM, accessibilityLabel: "Toggle sidebar") {
            withAnimation(theme.presentationAnimation) { state.toggle() }
        }
    }
}

/// The thin draggable strip along the sidebar's edge; clicking it toggles.
public struct ShadSidebarRail: View {
    @Environment(\.shadSidebar) private var state
    @Environment(\.shadTheme) private var theme
    @State private var isHovering = false

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(isHovering ? theme.colors.sidebarBorder : .clear)
            .frame(width: 4)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
                if hovering { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
            }
            .onTapGesture {
                withAnimation(theme.presentationAnimation) { state.toggle() }
            }
            .animation(theme.interactionAnimation, value: isHovering)
    }
}

/// Wraps the main content beside the sidebar. With the `inset` variant it
/// becomes a rounded card, matching shadcn.
public struct ShadSidebarInset<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let variant: ShadSidebarVariant
    private let content: Content

    public init(variant: ShadSidebarVariant = .sidebar, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(theme.colors.background)
            .shadIf(variant == .inset) { view in
                view
                    .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
                    .background(
                        ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                            .fill(theme.colors.background)
                            .shadShadow(theme.shadows.sm)
                    )
                    .overlay(
                        ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                            .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
                    )
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
            }
    }
}

/// The label a sidebar menu button draws, exposed on its own so a row can be
/// used as the trigger for a menu instead of running an action directly.
///
/// ```swift
/// ShadDropdownMenu { _ in
///     ShadSidebarMenuButtonLabel(title: "Acme Inc.", icon: .zap, size: .lg,
///                                trailingIcon: .chevronsUpDown)
/// } content: { … }
/// ```
public struct ShadSidebarMenuButtonLabel: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadSidebarIsIconOnly) private var isIconOnly

    private let title: String
    private let icon: ShadIcon?
    private let isActive: Bool
    private let size: ShadSidebarMenuButton<EmptyView>.Size
    private let trailingIcon: ShadIcon?

    public init(
        title: String,
        icon: ShadIcon? = nil,
        isActive: Bool = false,
        size: ShadSidebarMenuButton<EmptyView>.Size = .default,
        trailingIcon: ShadIcon? = nil
    ) {
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.size = size
        self.trailingIcon = trailingIcon
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let icon {
                ShadIconView(icon, size: 16).frame(width: 16)
            }
            if !isIconOnly {
                Text(title)
                    .font(theme.font(theme.typography.sm, isActive ? theme.typography.medium : theme.typography.regular))
                    .lineLimit(1)
                Spacer(minLength: 0)
                if let trailingIcon {
                    ShadIconView(trailingIcon, size: 12)
                        .foregroundStyle(theme.colors.sidebarForeground.opacity(0.5))
                }
            }
        }
        .foregroundStyle(theme.colors.sidebarForeground.opacity(0.85))
        .padding(.horizontal, 8)
        .frame(height: size.height)
        .frame(maxWidth: .infinity, alignment: isIconOnly ? .center : .leading)
        .contentShape(Rectangle())
    }
}
