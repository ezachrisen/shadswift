import SwiftUI
import ShadSwift

// MARK: - Sidebar

struct SidebarPage: View {
    @State private var variant: ShadSidebarVariant = .sidebar
    @State private var collapsible: ShadSidebarCollapsible = .icon
    @State private var side: ShadSidebarSide = .left
    @State private var active = "inbox"
    @State private var workspace = "Acme Inc."
    @State private var lastAction = "—"
    @State private var userMenuOpen = DemoLaunchOptions.opensMenu
    @StateObject private var demoState = ShadSidebarState(isOpen: true, width: 220)

    var body: some View {
        DemoPage(title: "Sidebar", subtitle: "A composable, themeable and customisable sidebar.") {
            DemoSection("Configuration", description: "The gallery's own navigation is a Sidebar with variant: .inset.") {
                DemoRow(spacing: 16) {
                    DemoLabeled(label: "variant", width: 180) {
                        ShadSelect(selection: Binding(
                            get: { Optional(variant) },
                            set: { variant = $0 ?? .sidebar }
                        ), options: [
                            ShadSelectOption("sidebar", value: ShadSidebarVariant.sidebar),
                            ShadSelectOption("floating", value: ShadSidebarVariant.floating),
                            ShadSelectOption("inset", value: ShadSidebarVariant.inset),
                        ])
                    }
                    DemoLabeled(label: "collapsible", width: 180) {
                        ShadSelect(selection: Binding(
                            get: { Optional(collapsible) },
                            set: { collapsible = $0 ?? .icon }
                        ), options: [
                            ShadSelectOption("offcanvas", value: ShadSidebarCollapsible.offcanvas),
                            ShadSelectOption("icon", value: ShadSidebarCollapsible.icon),
                            ShadSelectOption("none", value: ShadSidebarCollapsible.none),
                        ])
                    }
                    DemoLabeled(label: "side", width: 140) {
                        ShadSelect(selection: Binding(
                            get: { Optional(side) },
                            set: { side = $0 ?? .left }
                        ), options: [
                            ShadSelectOption("left", value: ShadSidebarSide.left),
                            ShadSelectOption("right", value: ShadSidebarSide.right),
                        ])
                    }
                }
            }

            DemoSection("Live example", description: "Header, groups, badges, sub-menus, footer, trigger and rail.") {
                ShadSidebarProvider(state: demoState) {
                    if side == .left { sidebar }
                    inset
                    if side == .right { sidebar }
                }
                .frame(height: 420)
                .clipShape(ShadRoundedRectangle(cornerRadius: 12))
                .overlay(
                    ShadRoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }

    private var sidebar: some View {
        ShadSidebar(side: side, variant: variant, collapsible: collapsible) {
            ShadSidebarHeader {
                ShadSidebarMenu {
                    ShadSidebarMenuItem {
                        ShadDropdownMenu(alignment: .trailingTop, minWidth: 200) { _ in
                            ShadSidebarMenuButtonLabel(title: workspace, icon: .zap, size: .lg, trailingIcon: .chevronsUpDown)
                        } content: {
                            ShadDropdownMenuLabel("Workspaces")
                            ShadDropdownMenuSeparator()
                            ShadDropdownMenuItem("Acme Inc.", icon: .zap) { workspace = "Acme Inc." }
                            ShadDropdownMenuItem("Evil Corp.", icon: .globe) { workspace = "Evil Corp." }
                            ShadDropdownMenuSeparator()
                            ShadDropdownMenuItem("Add workspace", icon: .plus) {}
                        }
                    }
                }
            }
            ShadSidebarContent {
                ShadSidebarGroup("Platform") {
                    ShadSidebarMenu {
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Inbox", icon: .mail, isActive: active == "inbox") {
                                active = "inbox"
                            } trailing: {
                                ShadSidebarMenuBadge("24")
                            }
                        }
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Calendar", icon: .calendar, isActive: active == "calendar") {
                                active = "calendar"
                            }
                        }
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Search", icon: .search, isActive: active == "search") {
                                active = "search"
                            }
                        }
                    }
                    ShadSidebarMenuSub {
                        ShadSidebarMenuSubButton("Drafts", isActive: active == "drafts") { active = "drafts" }
                        ShadSidebarMenuSubButton("Sent", isActive: active == "sent") { active = "sent" }
                    }
                }
                ShadSidebarGroup("Projects") {
                    ShadSidebarMenu {
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Design system", icon: .sparkles, isActive: active == "ds") {
                                active = "ds"
                            }
                            ShadDropdownMenu(alignment: .trailingTop, minWidth: 176) { _ in
                                ShadIconView(.moreHorizontal, size: 13)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, height: 24)
                                    .contentShape(Rectangle())
                            } content: {
                                ShadDropdownMenuItem("Rename", icon: .pencil) { lastAction = "Rename project" }
                                ShadDropdownMenuItem("Duplicate", icon: .copy) { lastAction = "Duplicate project" }
                                ShadDropdownMenuSeparator()
                                ShadDropdownMenuItem("Delete", icon: .trash, variant: .destructive) {
                                    lastAction = "Delete project"
                                }
                            }
                            .shadSidebarHiddenWhenCollapsed()
                        }
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Docs site", icon: .globe, isActive: active == "docs") {
                                active = "docs"
                            }
                        }
                    }
                } action: {
                    ShadDropdownMenu(alignment: .trailingTop, minWidth: 176) { _ in
                        ShadIconView(.plus, size: 12)
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                    } content: {
                        ShadDropdownMenuItem("New project", icon: .plus) { lastAction = "New project" }
                        ShadDropdownMenuItem("Import…", icon: .download) { lastAction = "Import project" }
                    }
                }
            }
            ShadSidebarFooter {
                ShadSidebarMenu {
                    ShadSidebarMenuItem {
                        ShadDropdownMenu(isOpen: $userMenuOpen, alignment: .trailingBottom, minWidth: 210) { _ in
                            ShadSidebarMenuButtonLabel(
                                title: "ez@example.com",
                                icon: .user,
                                size: .lg,
                                trailingIcon: .chevronsUpDown
                            )
                        } content: {
                            ShadDropdownMenuLabel("ez@example.com")
                            ShadDropdownMenuSeparator()
                            ShadDropdownMenuItem("Account", icon: .user) { lastAction = "Account" }
                            ShadDropdownMenuItem("Billing", icon: .creditCard) { lastAction = "Billing" }
                            ShadDropdownMenuItem("Notifications", icon: .bell) { lastAction = "Notifications" }
                            ShadDropdownMenuSeparator()
                            ShadDropdownMenuItem("Log out", icon: .logOut, variant: .destructive) {
                                lastAction = "Log out"
                            }
                        }
                    }
                }
            }
        }
    }

    private var inset: some View {
        ShadSidebarInset(variant: variant) {
            HStack(spacing: 10) {
                ShadSidebarTrigger()
                ShadSeparator(.vertical).frame(height: 16)
                Text(active.capitalized)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                ShadBadge("menu: \(lastAction)", variant: .secondary)
                ShadBadge(demoState.state, variant: .outline)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            ShadSeparator()
            VStack(alignment: .leading, spacing: 12) {
                Text("Main content")
                    .font(.system(size: 15, weight: .semibold))
                Text("The sidebar collapses to \(collapsible.rawValue). Click the rail on its edge, or the trigger above.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                DemoRow {
                    ShadButton("Primary", size: .sm) {}
                    ShadButton("Secondary", variant: .outline, size: .sm) {}
                }
            }
            .padding(16)
            Spacer()
        }
    }
}

// MARK: - Overview

struct OverviewPage: View {
    @Binding var page: DemoPageID
    @Environment(\.shadTheme) private var theme

    var body: some View {
        DemoPage(
            title: "ShadSwift",
            subtitle: "A SwiftUI component library for macOS, modelled on shadcn/ui. Every visual decision — colour, radius, type, spacing, elevation, motion — comes from one theme value in the environment."
        ) {
            DemoSection("At a glance") {
                DemoRow {
                    ShadButton("Button") { page = .button }
                    ShadBadge("Badge", variant: .secondary)
                    ShadAvatar(fallback: "CN")
                    ShadSpinner()
                    ShadSwitch(isOn: .constant(true))
                    ShadCheckbox(isOn: .constant(true))
                    ShadBadge("v1.0", variant: .outline, icon: .tag)
                }
            }

            DemoSection("Everything is a token", description: "The same card under three radius values.") {
                HStack(alignment: .top, spacing: 12) {
                    ForEach([0, 10, 20], id: \.self) { radius in
                        ShadCard(size: .sm) {
                            ShadCardHeader {
                                ShadCardTitle("radius \(radius)")
                                ShadCardDescription("ShadRadius(base: \(radius))")
                            }
                            ShadCardContent {
                                DemoRow(spacing: 8) {
                                    ShadButton("Save", size: .sm) {}
                                    ShadBadge("New", variant: .secondary)
                                }
                            }
                        }
                        .shadTheme { $0.radius = ShadRadius(base: CGFloat(radius)) }
                    }
                }
            }

            DemoSection("Pages") {
                ShadWrapLayout(spacing: 8, lineSpacing: 8) {
                    ForEach(DemoPageID.allCases.filter { $0 != .overview }) { item in
                        ShadButton(item.title, variant: .outline, size: .sm, icon: item.icon) {
                            page = item
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Theming

struct ThemingPage: View {
    @Binding var presetName: String
    @Binding var radius: Double
    @Binding var isDark: Bool
    @Binding var usesRoundedFont: Bool
    @Environment(\.shadTheme) private var theme

    private let swatches: [(String, KeyPath<ShadColors, Color>)] = [
        ("background", \.background), ("foreground", \.foreground),
        ("card", \.card), ("popover", \.popover),
        ("primary", \.primary), ("primaryForeground", \.primaryForeground),
        ("secondary", \.secondary), ("muted", \.muted),
        ("mutedForeground", \.mutedForeground), ("accent", \.accent),
        ("destructive", \.destructive), ("success", \.success),
        ("warning", \.warning), ("info", \.info),
        ("border", \.border), ("input", \.input), ("ring", \.ring),
        ("chart1", \.chart1), ("chart2", \.chart2), ("chart3", \.chart3),
        ("chart4", \.chart4), ("chart5", \.chart5),
        ("sidebar", \.sidebar), ("sidebarAccent", \.sidebarAccent),
        ("bubbleSent", \.bubbleSent), ("bubbleReceived", \.bubbleReceived),
    ]

    var body: some View {
        DemoPage(title: "Theming", subtitle: "Colours are authored in OKLCH, exactly like shadcn's CSS variables, then converted to sRGB at build time.") {
            DemoSection("Base color") {
                ShadWrapLayout(spacing: 8, lineSpacing: 8) {
                    ForEach(ShadThemeSet.presets, id: \.name) { preset in
                        ShadButton(
                            preset.name.capitalized,
                            variant: presetName == preset.name ? .default : .outline,
                            size: .sm
                        ) {
                            presetName = preset.name
                        }
                    }
                }
            }

            DemoSection("Radius — \(Int(radius))pt", description: "sm, md, lg and xl all derive from this one number.") {
                VStack(alignment: .leading, spacing: 14) {
                    ShadSlider(value: $radius, in: 0...24, step: 1).frame(width: 320)
                    DemoRow {
                        ShadButton("Button") {}
                        ShadBadge("Badge", variant: .secondary)
                        ShadInput("Input", text: .constant("")).frame(width: 140)
                        ShadCard(size: .sm) { ShadCardContent { Text("Card") } }.frame(width: 120)
                    }
                }
            }

            DemoSection("Appearance") {
                DemoRow(spacing: 24) {
                    ShadSwitch("Dark mode", isOn: $isDark)
                    ShadSwitch("Rounded typeface", isOn: $usesRoundedFont)
                }
            }

            DemoSection("Tokens", description: "Every colour a component can reference.") {
                ShadWrapLayout(spacing: 10, lineSpacing: 10, alignment: .top) {
                    ForEach(swatches, id: \.0) { name, path in
                        VStack(alignment: .leading, spacing: 4) {
                            ShadRoundedRectangle(cornerRadius: theme.radius.md)
                                .fill(theme.colors[keyPath: path])
                                .frame(width: 96, height: 40)
                                .overlay(
                                    ShadRoundedRectangle(cornerRadius: theme.radius.md)
                                        .strokeBorder(theme.colors.border, lineWidth: 1)
                                )
                            Text(name)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(theme.colors.mutedForeground)
                        }
                    }
                }
            }

            DemoSection("Chat bubbles", description: "Bubbles have their own tokens, so a conversation keeps its palette whatever the brand colour is.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadBubble(variant: .received, align: .start) {
                        ShadBubbleContent("Received messages use bubbleReceived.")
                    }
                    ShadBubble(variant: .sent, align: .end) {
                        ShadBubbleContent("Sent messages use bubbleSent.")
                    }
                    Text("""
                    ShadThemeSet.default.bubbles(
                        sent: Color(oklch: 0.60, 0.196, 258), sentForeground: .white,
                        received: Color(oklch: 0.955, 0, 0), receivedForeground: Color(oklch: 0.145, 0, 0)
                    )
                    """)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(theme.colors.mutedForeground)
                }
                .frame(maxWidth: 520)
            }

            DemoSection("Custom theme in code") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("""
                    let brand = ShadThemeSet.slate
                        .radius(4)
                        .tinted(light: OKLCH(0.55, 0.20, 264),
                                dark:  OKLCH(0.65, 0.20, 264))

                    ContentView().shadTheme(brand)
                    """)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        ShadRoundedRectangle(cornerRadius: theme.radius.md)
                            .fill(theme.colors.muted)
                    )

                    DemoRow {
                        ShadButton("Preview") {}
                        ShadBadge("Preview", variant: .secondary)
                        ShadSwitch(isOn: .constant(true))
                    }
                    .shadTheme(
                        ShadThemeSet.slate
                            .radius(4)
                            .tinted(light: OKLCH(0.55, 0.20, 264), dark: OKLCH(0.65, 0.20, 264))
                            .resolved(for: isDark ? .dark : .light)
                    )
                }
            }
        }
    }
}

// MARK: - Breadcrumb

struct BreadcrumbPage: View {
    /// A small file tree the stack demo walks through.
    private struct Node: Identifiable {
        let id = UUID()
        let name: String
        var icon: ShadIcon = .folder
        var children: [Node] = []
    }

    private static let tree = Node(name: "Home", icon: .home, children: [
        Node(name: "Documents", children: [
            Node(name: "Invoices", children: [
                Node(name: "2026", children: [
                    Node(name: "Q3", children: [
                        Node(name: "March", children: []),
                    ]),
                ]),
            ]),
            Node(name: "Contracts", children: []),
        ]),
        Node(name: "Projects", children: [
            Node(name: "ShadSwift", children: [
                Node(name: "Sources", children: []),
            ]),
        ]),
        Node(name: "Pictures", icon: .image, children: []),
    ])

    @StateObject private var path = ShadBreadcrumbPath([ShadCrumb("Home", icon: .home)])
    @State private var collapses = true
    @State private var lastAction = "—"

    /// Walks the tree down the crumb titles currently on the path.
    private var currentNode: Node {
        var node = Self.tree
        for crumb in path.crumbs.dropFirst() {
            guard let next = node.children.first(where: { $0.name == crumb.title }) else { break }
            node = next
        }
        return node
    }

    var body: some View {
        DemoPage(title: "Breadcrumb", subtitle: "Displays the path to the current resource using a hierarchy of links.") {
            DemoSection("Default", description: "Links back up the hierarchy, with the current page in full contrast.") {
                ShadBreadcrumb {
                    ShadBreadcrumbList {
                        ShadBreadcrumbLink("Home") { lastAction = "Home" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbLink("Components") { lastAction = "Components" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbPage("Breadcrumb")
                    }
                }
            }

            DemoSection("Custom separator", description: "ShadBreadcrumbSeparator takes any content.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") { lastAction = "Home" }
                            ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }
                            ShadBreadcrumbLink("Components") { lastAction = "Components" }
                            ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") { lastAction = "Home" }
                            ShadBreadcrumbSeparator { Text("›") }
                            ShadBreadcrumbLink("Docs") { lastAction = "Docs" }
                            ShadBreadcrumbSeparator { Text("›") }
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                }
            }

            DemoSection("Collapsed", description: "An ellipsis stands in for the crumbs in the middle.") {
                ShadBreadcrumb {
                    ShadBreadcrumbList {
                        ShadBreadcrumbLink("Home") { lastAction = "Home" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbEllipsis()
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbLink("Components") { lastAction = "Components" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbPage("Breadcrumb")
                    }
                }
            }

            DemoSection("With icons", description: "Any crumb can carry a leading icon.") {
                ShadBreadcrumb {
                    ShadBreadcrumbList {
                        ShadBreadcrumbLink("Home", icon: .home) { lastAction = "Home" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbLink("Documents", icon: .folder) { lastAction = "Documents" }
                        ShadBreadcrumbSeparator()
                        ShadBreadcrumbPage("Invoice.pdf", icon: .file)
                    }
                }
            }

            DemoSection(
                "Push and pop",
                description: "ShadBreadcrumbPath is a stack: push as you go deeper, and clicking a crumb pops everything after it."
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    ShadBreadcrumb(path: path, maxVisible: collapses ? 4 : nil) { crumb in
                        lastAction = "Popped back to \(crumb.title)"
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        ShadRoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                    DemoRow(spacing: 8) {
                        ForEach(currentNode.children) { child in
                            ShadButton(child.name, variant: .outline, size: .sm) {
                                path.push(child.name, icon: child.icon)
                                lastAction = "Pushed \(child.name)"
                            }
                        }
                        if currentNode.children.isEmpty {
                            DemoCaption("Nothing deeper — pop back up.")
                        }
                    }

                    DemoRow(spacing: 8) {
                        ShadButton("Pop", variant: .secondary, size: .sm) {
                            if let popped = path.pop() { lastAction = "Popped \(popped.title)" }
                        }
                        .disabled(!path.canPop)
                        ShadButton("Pop 2", variant: .secondary, size: .sm) {
                            let popped = path.pop(2)
                            lastAction = popped.isEmpty
                                ? "Nothing to pop"
                                : "Popped \(popped.map(\.title).joined(separator: ", "))"
                        }
                        .disabled(!path.canPop)
                        ShadButton("Pop to root", variant: .ghost, size: .sm) {
                            path.popToRoot()
                            lastAction = "Popped to root"
                        }
                        .disabled(!path.canPop)
                        ShadCheckbox("Collapse past 4", isOn: $collapses)
                    }

                    DemoCaption("depth \(path.depth) · \(lastAction)")
                }
            }
        }
    }
}
