import SwiftUI

/// The two `TabsList` treatments.
public enum ShadTabsVariant: String, CaseIterable, Sendable {
    /// A muted pill containing the triggers. The default.
    case `default`
    /// Underlined triggers with no container fill.
    case line
}

struct ShadTabsContext {
    var selection: AnyHashable = AnyHashable(0)
    var select: (AnyHashable) -> Void = { _ in }
    var variant: ShadTabsVariant = .default
    var orientation: Axis = .horizontal
    var namespace: Namespace.ID?
}

private struct ShadTabsContextKey: EnvironmentKey {
    static let defaultValue = ShadTabsContext()
}

extension EnvironmentValues {
    var shadTabsContext: ShadTabsContext {
        get { self[ShadTabsContextKey.self] }
        set { self[ShadTabsContextKey.self] = newValue }
    }
}

/// A set of layered sections of content, displayed one at a time.
///
/// ```swift
/// ShadTabs(selection: $tab) {
///     ShadTabsList {
///         ShadTabsTrigger("Account", value: Tab.account)
///         ShadTabsTrigger("Password", value: Tab.password)
///     }
///     ShadTabsContent(value: Tab.account) { … }
///     ShadTabsContent(value: Tab.password) { … }
/// }
/// ```
public struct ShadTabs<Value: Hashable, Content: View>: View {
    @Binding private var selection: Value
    private let variant: ShadTabsVariant
    private let orientation: Axis
    private let spacing: CGFloat
    private let content: Content
    @Namespace private var namespace

    public init(
        selection: Binding<Value>,
        variant: ShadTabsVariant = .default,
        orientation: Axis = .horizontal,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.variant = variant
        self.orientation = orientation
        self.spacing = spacing
        self.content = content()
    }

    private var context: ShadTabsContext {
        ShadTabsContext(
            selection: AnyHashable(selection),
            select: { newValue in
                if let typed = newValue.base as? Value { selection = typed }
            },
            variant: variant,
            orientation: orientation,
            namespace: namespace
        )
    }

    public var body: some View {
        Group {
            if orientation == .horizontal {
                VStack(alignment: .leading, spacing: spacing) { content }
            } else {
                HStack(alignment: .top, spacing: spacing) { content }
            }
        }
        .environment(\.shadTabsContext, context)
    }
}

/// The container that wraps the tab triggers.
public struct ShadTabsList<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadTabsContext) private var context

    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        Group {
            if context.orientation == .horizontal {
                HStack(spacing: context.variant == .line ? 4 : 0) { content }
            } else {
                VStack(alignment: .leading, spacing: context.variant == .line ? 4 : 0) { content }
            }
        }
        .padding(3)
        .background {
            if context.variant == .default {
                ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                    .fill(theme.colors.muted)
            }
        }
        .fixedSize()
        // Scoping the animation to the list lets the indicator slide without
        // the panel below ever taking part.
        .animation(theme.interactionAnimation, value: context.selection)
    }
}

/// A single tab button.
public struct ShadTabsTrigger<Value: Hashable, Label: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadTabsContext) private var context
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let value: Value
    private let label: Label

    public init(value: Value, @ViewBuilder label: () -> Label) {
        self.value = value
        self.label = label()
    }

    private var isSelected: Bool { context.selection == AnyHashable(value) }

    public var body: some View {
        Button {
            // No `withAnimation` here. An ambient animation reaches the panel
            // too, and animating the panel's insertion is the flicker. The
            // list animates itself instead — see ShadTabsList.
            context.select(AnyHashable(value))
        } label: {
            label
                .font(theme.font(theme.typography.sm, theme.typography.medium))
                .foregroundStyle(foreground)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .frame(height: context.orientation == .horizontal ? 25 : nil)
                .frame(maxWidth: context.orientation == .vertical ? .infinity : nil,
                       alignment: context.orientation == .vertical ? .leading : .center)
                .background { pill }
                .overlay(alignment: context.orientation == .horizontal ? .bottom : .trailing) { underline }
                .contentShape(Rectangle())
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(theme.interactionAnimation, value: isHovering)
    }

    private var foreground: Color {
        if isSelected { return theme.colors.foreground }
        return isHovering ? theme.colors.foreground : theme.colors.foreground.opacity(0.6)
    }

    /// The sliding background used by the default variant.
    @ViewBuilder
    private var pill: some View {
        if isSelected, context.variant == .default, let namespace = context.namespace {
            ShadRoundedRectangle(cornerRadius: theme.radius.md)
                .fill(theme.colors.background)
                .shadShadow(theme.shadows.xs)
                .matchedGeometryEffect(id: "shad.tabs.indicator", in: namespace)
        }
    }

    /// The 2pt rule the line variant draws under (or beside) the active
    /// trigger only — shadcn's `after:bottom-[-5px] h-0.5`.
    @ViewBuilder
    private var underline: some View {
        if isSelected, context.variant == .line, let namespace = context.namespace {
            Rectangle()
                .fill(theme.colors.foreground)
                .frame(
                    width: context.orientation == .vertical ? 2 : nil,
                    height: context.orientation == .horizontal ? 2 : nil
                )
                .offset(
                    x: context.orientation == .vertical ? 5 : 0,
                    y: context.orientation == .horizontal ? 5 : 0
                )
                .matchedGeometryEffect(id: "shad.tabs.indicator", in: namespace)
        }
    }
}

extension ShadTabsTrigger where Label == ShadTabsTriggerLabel {
    /// A trigger with a title and an optional leading icon.
    public init(_ title: String, value: Value, icon: ShadIcon? = nil) {
        self.init(value: value) { ShadTabsTriggerLabel(title: title, icon: icon) }
    }
}

/// The default trigger label.
public struct ShadTabsTriggerLabel: View {
    let title: String
    var icon: ShadIcon? = nil

    public var body: some View {
        HStack(spacing: 6) {
            if let icon { ShadIconView(icon, size: 14) }
            Text(title)
        }
    }
}

/// The panel shown when its `value` is selected.
public struct ShadTabsContent<Value: Hashable, Content: View>: View {
    @Environment(\.shadTabsContext) private var context

    private let value: Value
    private let content: Content

    public init(value: Value, @ViewBuilder content: () -> Content) {
        self.value = value
        self.content = content()
    }

    public var body: some View {
        if context.selection == AnyHashable(value) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                // Belt and braces: an `if` still picks up SwiftUI's default
                // fade on insertion and removal if any animation is in scope,
                // and that fade is the flash of empty container.
                .transition(.identity)
                .animation(nil, value: context.selection)
        }
    }
}
