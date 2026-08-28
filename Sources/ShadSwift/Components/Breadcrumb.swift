import SwiftUI

// MARK: - Metrics

/// The measurements shadcn/ui's breadcrumb uses, kept in one place so the
/// composable parts and the path-driven convenience view stay in step.
enum ShadBreadcrumbMetrics {
    /// `gap-1.5` between the entries of the list.
    static let listGap: CGFloat = 6
    /// `gap-1` between an item's icon and its label.
    static let itemGap: CGFloat = 4
    /// `[&>svg]:size-3.5` — the separator chevron.
    static let separatorSize: CGFloat = 14
    /// `[&>svg]:size-4` inside a `size-5` box — the ellipsis.
    static let ellipsisIconSize: CGFloat = 16
    static let ellipsisBoxSize: CGFloat = 20
}

// MARK: - Container

/// A breadcrumb trail: the path back up through a hierarchy.
///
/// Compose the parts yourself when the trail is static:
///
/// ```swift
/// ShadBreadcrumb {
///     ShadBreadcrumbList {
///         ShadBreadcrumbLink("Home") { open(.home) }
///         ShadBreadcrumbSeparator()
///         ShadBreadcrumbLink("Components") { open(.components) }
///         ShadBreadcrumbSeparator()
///         ShadBreadcrumbPage("Breadcrumb")
///     }
/// }
/// ```
///
/// or hand it a ``ShadBreadcrumbPath`` and let it track a stack you push to and
/// pop from — see ``ShadBreadcrumb/init(path:maxVisible:onNavigate:)``.
public struct ShadBreadcrumb<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Breadcrumb")
    }
}

/// The row of crumbs and separators.
///
/// Wrapping this in ``ShadBreadcrumb`` is optional — the list is what draws the
/// trail, and it applies the muted `text-sm` styling every part inherits.
public struct ShadBreadcrumbList<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ShadWrapLayout(
            spacing: ShadBreadcrumbMetrics.listGap,
            lineSpacing: ShadBreadcrumbMetrics.listGap
        ) {
            content
        }
        .font(theme.font(theme.typography.sm))
        .foregroundStyle(theme.colors.mutedForeground)
    }
}

/// One entry in the trail, for content that is neither a plain link nor the
/// current page — an icon beside a label, say.
///
/// ``ShadBreadcrumbLink`` and ``ShadBreadcrumbPage`` are already items; reach
/// for this only when composing something custom.
public struct ShadBreadcrumbItem<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: ShadBreadcrumbMetrics.itemGap) {
            content
        }
    }
}

// MARK: - Crumbs

/// A crumb you can click to go back to.
public struct ShadBreadcrumbLink<Label: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    private let label: Label
    private let action: () -> Void

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) {
            ShadBreadcrumbItem { label }
                // hover:text-foreground
                .foregroundStyle(
                    isHovering && isEnabled
                        ? theme.colors.foreground
                        : theme.colors.mutedForeground
                )
                .animation(theme.interactionAnimation, value: isHovering)
        }
        .buttonStyle(.shadPlain)
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .accessibilityAddTraits(.isLink)
    }
}

extension ShadBreadcrumbLink where Label == ShadBreadcrumbCrumbLabel {
    /// A text crumb, optionally with a leading icon.
    public init(_ title: String, icon: ShadIcon? = nil, action: @escaping () -> Void) {
        self.init(action: action) {
            ShadBreadcrumbCrumbLabel(title: title, icon: icon)
        }
    }
}

/// The crumb for where you are now: the last one, and not clickable.
public struct ShadBreadcrumbPage<Label: View>: View {
    @Environment(\.shadTheme) private var theme
    private let label: Label

    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        ShadBreadcrumbItem { label }
            .foregroundStyle(theme.colors.foreground)
            .accessibilityAddTraits(.isHeader)
            .accessibilityValue("Current page")
    }
}

extension ShadBreadcrumbPage where Label == ShadBreadcrumbCrumbLabel {
    public init(_ title: String, icon: ShadIcon? = nil) {
        self.init { ShadBreadcrumbCrumbLabel(title: title, icon: icon) }
    }
}

/// The icon-and-text pairing shared by links and pages.
public struct ShadBreadcrumbCrumbLabel: View {
    @Environment(\.shadTheme) private var theme
    let title: String
    var icon: ShadIcon?

    public init(title: String, icon: ShadIcon? = nil) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        if let icon {
            ShadIconView(icon, size: ShadBreadcrumbMetrics.ellipsisIconSize)
        }
        Text(title)
    }
}

// MARK: - Separator

/// The mark between two crumbs — a chevron by default.
///
/// Pass your own content for anything else:
///
/// ```swift
/// ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }
/// ```
public struct ShadBreadcrumbSeparator<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .foregroundStyle(theme.colors.mutedForeground)
            .accessibilityHidden(true)
    }
}

extension ShadBreadcrumbSeparator where Content == ShadIconView {
    public init() {
        self.init {
            ShadIconView(.chevronRight, size: ShadBreadcrumbMetrics.separatorSize)
        }
    }
}

/// Stands in for the crumbs hidden in the middle of a long trail.
public struct ShadBreadcrumbEllipsis: View {
    @Environment(\.shadTheme) private var theme

    public init() {}

    public var body: some View {
        ShadIconView(.moreHorizontal, size: ShadBreadcrumbMetrics.ellipsisIconSize)
            .frame(
                width: ShadBreadcrumbMetrics.ellipsisBoxSize,
                height: ShadBreadcrumbMetrics.ellipsisBoxSize
            )
            .foregroundStyle(theme.colors.mutedForeground)
            .accessibilityLabel("More")
    }
}
