import SwiftUI

private struct ShadMenuDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

/// Which submenu of a menu is open.
///
/// This is a plain environment *value* rather than an observable object on
/// purpose. A menu's rows live in a separate hosting controller inside the
/// panel window, and an `ObservableObject` handed through `environment(_:_:)`
/// publishes changes that nothing over there is subscribed to — the submenu
/// simply never appeared. A value plus a setter re-renders correctly.
private struct ShadMenuOpenSubmenuKey: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

private struct ShadMenuSetOpenSubmenuKey: EnvironmentKey {
    static let defaultValue: (UUID?) -> Void = { _ in }
}

extension EnvironmentValues {
    var shadMenuOpenSubmenu: UUID? {
        get { self[ShadMenuOpenSubmenuKey.self] }
        set { self[ShadMenuOpenSubmenuKey.self] = newValue }
    }

    var shadMenuSetOpenSubmenu: (UUID?) -> Void {
        get { self[ShadMenuSetOpenSubmenuKey.self] }
        set { self[ShadMenuSetOpenSubmenuKey.self] = newValue }
    }
}

extension EnvironmentValues {
    /// Closes the enclosing menu. Menu rows call it after running their action.
    public var shadMenuDismiss: () -> Void {
        get { self[ShadMenuDismissKey.self] }
        set { self[ShadMenuDismissKey.self] = newValue }
    }
}

/// Displays a menu to the user — such as a set of actions or functions —
/// triggered by a button.
///
/// ```swift
/// ShadDropdownMenu("Open") {
///     ShadDropdownMenuLabel("My Account")
///     ShadDropdownMenuSeparator()
///     ShadDropdownMenuItem("Profile", icon: .user, shortcut: "⇧⌘P") {}
///     ShadDropdownMenuItem("Log out", variant: .destructive) {}
/// }
/// ```
public struct ShadDropdownMenu<Trigger: View, Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @State private var internalIsOpen = false

    private let alignment: ShadPopoverAlignment
    private let minWidth: CGFloat
    private let externalIsOpen: Binding<Bool>?
    private let trigger: (Bool) -> Trigger
    private let content: () -> Content
    @State private var openSubmenu: UUID?

    public init(
        isOpen: Binding<Bool>? = nil,
        alignment: ShadPopoverAlignment = .bottomLeading,
        minWidth: CGFloat = 176,
        @ViewBuilder trigger: @escaping (Bool) -> Trigger,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.externalIsOpen = isOpen
        self.alignment = alignment
        self.minWidth = minWidth
        self.trigger = trigger
        self.content = content
    }

    /// Controlled when an `isOpen` binding was supplied, uncontrolled otherwise.
    private var isOpen: Binding<Bool> {
        externalIsOpen ?? $internalIsOpen
    }

    public var body: some View {
        Button {
            isOpen.wrappedValue.toggle()
        } label: {
            trigger(isOpen.wrappedValue)
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .onChange(of: isOpen.wrappedValue) { _, open in
            if !open { openSubmenu = nil }
        }
        .shadPopover(
            isPresented: isOpen,
            configuration: ShadPopoverConfiguration(alignment: alignment, gap: 4)
        ) {
            ShadPopoverSurface {
                ShadScrollContainer {
                    VStack(alignment: .leading, spacing: ShadMenuMetrics.rowSpacing) {
                        content()
                    }
                }
                .frame(minWidth: minWidth, alignment: .leading)
            }
            .environment(\.shadMenuDismiss) { isOpen.wrappedValue = false }
            .environment(\.shadMenuOpenSubmenu, openSubmenu)
            .environment(\.shadMenuSetOpenSubmenu) { openSubmenu = $0 }
        }
    }
}

extension ShadDropdownMenu where Trigger == ShadDropdownMenuButtonTrigger {
    /// A menu whose trigger is a standard shadcn button.
    public init(
        _ title: String,
        variant: ShadButtonVariant = .outline,
        size: ShadButtonSize = .default,
        icon: ShadIcon? = nil,
        showsChevron: Bool = false,
        isOpen: Binding<Bool>? = nil,
        alignment: ShadPopoverAlignment = .bottomLeading,
        minWidth: CGFloat = 176,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(isOpen: isOpen, alignment: alignment, minWidth: minWidth, trigger: { isOpen in
            ShadDropdownMenuButtonTrigger(
                title: title,
                variant: variant,
                size: size,
                icon: icon,
                showsChevron: showsChevron,
                isOpen: isOpen
            )
        }, content: content)
    }
}

/// The button-shaped trigger used by ``ShadDropdownMenu``'s convenience init.
public struct ShadDropdownMenuButtonTrigger: View {
    let title: String
    let variant: ShadButtonVariant
    let size: ShadButtonSize
    let icon: ShadIcon?
    let showsChevron: Bool
    let isOpen: Bool

    public var body: some View {
        ShadButtonSurface(
            variant: variant,
            size: size,
            shape: .rounded,
            isLoading: false,
            fillsWidth: false,
            isPressed: false,
            isExpanded: isOpen
        ) {
            HStack(spacing: size.gap) {
                if let icon { ShadIconView(icon, size: size.iconSize) }
                Text(title)
                if showsChevron {
                    ShadIconView(.chevronDown, size: size.iconSize - 2)
                }
            }
        }
    }
}

// MARK: - Rows

/// A selectable row in a dropdown menu.
public struct ShadDropdownMenuItem<Trailing: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadMenuDismiss) private var dismiss
    @Environment(\.shadMenuSetOpenSubmenu) private var setOpenSubmenu
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let title: String
    private let description: String?
    private let icon: ShadIcon?
    private let variant: ShadMenuItemVariant
    private let isInset: Bool
    private let dismissesMenu: Bool
    private let action: () -> Void
    private let trailing: Trailing

    public init(
        _ title: String,
        description: String? = nil,
        icon: ShadIcon? = nil,
        variant: ShadMenuItemVariant = .default,
        isInset: Bool = false,
        dismissesMenu: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.variant = variant
        self.isInset = isInset
        self.dismissesMenu = dismissesMenu
        self.action = action
        self.trailing = trailing()
    }

    public var body: some View {
        Button {
            action()
            if dismissesMenu { dismiss() }
        } label: {
            ShadMenuRow(
                title: title,
                description: description,
                variant: variant,
                isHighlighted: isHovering,
                isDisabled: !isEnabled,
                isInset: isInset || icon != nil
            ) {
                if let icon {
                    ShadIconView(icon, size: 16)
                } else if isInset {
                    Color.clear.frame(width: 16, height: 1)
                }
            } trailing: {
                trailing
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .onChange(of: isHovering) { _, hovering in
            if hovering { setOpenSubmenu(nil) }
        }
    }
}

extension ShadDropdownMenuItem where Trailing == ShadMenuShortcut {
    /// A row with a keyboard shortcut hint on the right.
    public init(
        _ title: String,
        description: String? = nil,
        icon: ShadIcon? = nil,
        variant: ShadMenuItemVariant = .default,
        isInset: Bool = false,
        shortcut: String,
        dismissesMenu: Bool = true,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            description: description,
            icon: icon,
            variant: variant,
            isInset: isInset,
            dismissesMenu: dismissesMenu,
            action: action
        ) {
            ShadMenuShortcut(shortcut)
        }
    }
}

extension ShadDropdownMenuItem where Trailing == EmptyView {
    public init(
        _ title: String,
        description: String? = nil,
        icon: ShadIcon? = nil,
        variant: ShadMenuItemVariant = .default,
        isInset: Bool = false,
        dismissesMenu: Bool = true,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            description: description,
            icon: icon,
            variant: variant,
            isInset: isInset,
            dismissesMenu: dismissesMenu,
            action: action
        ) {
            EmptyView()
        }
    }
}

/// A row with a checkmark that toggles.
public struct ShadDropdownMenuCheckboxItem: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadMenuSetOpenSubmenu) private var setOpenSubmenu
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    @Binding private var isOn: Bool
    private let title: String
    private let dismissesMenu: Bool

    public init(_ title: String, isOn: Binding<Bool>, dismissesMenu: Bool = false) {
        self.title = title
        self._isOn = isOn
        self.dismissesMenu = dismissesMenu
    }

    @Environment(\.shadMenuDismiss) private var dismiss

    public var body: some View {
        Button {
            isOn.toggle()
            if dismissesMenu { dismiss() }
        } label: {
            ShadMenuRow(
                title: title,
                isHighlighted: isHovering,
                isDisabled: !isEnabled,
                isInset: true
            ) {
                if isOn {
                    ShadIconView(.check, size: 14)
                } else {
                    Color.clear.frame(width: 14, height: 14)
                }
            } trailing: {
                EmptyView()
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .onChange(of: isHovering) { _, hovering in
            if hovering { setOpenSubmenu(nil) }
        }
    }
}

private struct ShadRadioGroupContext {
    var selection: AnyHashable? = nil
    var select: (AnyHashable) -> Void = { _ in }
}

private struct ShadRadioGroupKey: EnvironmentKey {
    static let defaultValue = ShadRadioGroupContext()
}

extension EnvironmentValues {
    fileprivate var shadRadioGroup: ShadRadioGroupContext {
        get { self[ShadRadioGroupKey.self] }
        set { self[ShadRadioGroupKey.self] = newValue }
    }
}

/// Groups mutually exclusive rows.
public struct ShadDropdownMenuRadioGroup<Value: Hashable, Content: View>: View {
    @Binding private var selection: Value
    private let content: Content

    public init(selection: Binding<Value>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ShadMenuMetrics.rowSpacing) { content }
            .environment(\.shadRadioGroup, ShadRadioGroupContext(
                selection: AnyHashable(selection),
                select: { newValue in
                    if let typed = newValue.base as? Value { selection = typed }
                }
            ))
    }
}

/// One option inside a ``ShadDropdownMenuRadioGroup``.
public struct ShadDropdownMenuRadioItem<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadRadioGroup) private var group
    @Environment(\.shadMenuDismiss) private var dismiss
    @Environment(\.shadMenuSetOpenSubmenu) private var setOpenSubmenu
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let title: String
    private let value: Value
    private let dismissesMenu: Bool

    public init(_ title: String, value: Value, dismissesMenu: Bool = true) {
        self.title = title
        self.value = value
        self.dismissesMenu = dismissesMenu
    }

    private var isSelected: Bool { group.selection == AnyHashable(value) }

    public var body: some View {
        Button {
            group.select(AnyHashable(value))
            if dismissesMenu { dismiss() }
        } label: {
            // shadcn marks the chosen row with a check on the trailing edge,
            // the same as Select — not a bullet on the left.
            ShadMenuRow(
                title: title,
                isHighlighted: isHovering,
                isDisabled: !isEnabled
            ) {
                EmptyView()
            } trailing: {
                if isSelected {
                    ShadIconView(.check, size: 14)
                }
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .onChange(of: isHovering) { _, hovering in
            if hovering { setOpenSubmenu(nil) }
        }
    }
}

/// A hairline between menu sections.
public struct ShadDropdownMenuSeparator: View {
    public init() {}
    public var body: some View {
        ShadSeparator().padding(.vertical, 4)
    }
}

/// Groups related rows without a visible container.
public struct ShadDropdownMenuGroup<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: ShadMenuMetrics.rowSpacing) { content }
    }
}

/// A section heading.
public typealias ShadDropdownMenuLabel = ShadMenuLabel
/// A keyboard shortcut hint.
public typealias ShadDropdownMenuShortcut = ShadMenuShortcut

/// A nested submenu that opens to the side on hover or click.
public struct ShadDropdownMenuSub<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadMenuOpenSubmenu) private var openSubmenu
    @Environment(\.shadMenuSetOpenSubmenu) private var setOpenSubmenu
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    @State private var id = UUID()

    private let title: String
    private let icon: ShadIcon?
    private let minWidth: CGFloat
    private let content: () -> Content

    public init(
        _ title: String,
        icon: ShadIcon? = nil,
        minWidth: CGFloat = 176,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.minWidth = minWidth
        self.content = content
    }

    /// Open state lives with the menu so only one submenu can be open, and
    /// hovering any sibling row closes it.
    private var isOpen: Binding<Bool> {
        Binding(
            get: { openSubmenu == id },
            set: { setOpenSubmenu($0 ? id : nil) }
        )
    }

    public var body: some View {
        Button {
            isOpen.wrappedValue.toggle()
        } label: {
            ShadMenuRow(
                title: title,
                isHighlighted: isHovering || isOpen.wrappedValue,
                isDisabled: !isEnabled,
                isInset: icon != nil
            ) {
                if let icon { ShadIconView(icon, size: 16) }
            } trailing: {
                ShadIconView(.chevronRight, size: 14)
                    .foregroundStyle(theme.colors.mutedForeground)
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .onChange(of: isHovering) { _, hovering in
            if hovering { isOpen.wrappedValue = true }
        }
        .shadPopover(
            isPresented: isOpen,
            configuration: ShadPopoverConfiguration(alignment: .trailingTop, gap: 4)
        ) {
            ShadPopoverSurface {
                VStack(alignment: .leading, spacing: ShadMenuMetrics.rowSpacing) { content() }
                    .frame(minWidth: minWidth, alignment: .leading)
            }
        }
    }
}
