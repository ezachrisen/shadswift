import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var layout: [DocComponent] {
        [breadcrumb, sidebar, theming]
    }


    // MARK: - Breadcrumb

    static var breadcrumb: DocComponent {
        DocComponent(
            slug: "breadcrumb",
            title: "Breadcrumb",
            summary: "Displays the path to the current resource using a hierarchy of links.",
            group: "Layout",
            anatomy: #"""
            ShadBreadcrumb
            └── ShadBreadcrumbList
                ├── ShadBreadcrumbLink(_:icon:action:)      // a crumb you can go back to
                ├── ShadBreadcrumbSeparator                 // chevron by default
                ├── ShadBreadcrumbEllipsis                  // stands in for hidden crumbs
                └── ShadBreadcrumbPage(_:icon:)             // where you are now

            ShadBreadcrumb(path:maxVisible:onNavigate:)     // driven by a push/pop stack
            └── ShadBreadcrumbPath
                └── [ShadCrumb]
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "Crumbs are muted; the current page is not.",
                    code: #"""
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") { open(.home) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Components") { open(.components) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                    """#
                ) {
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Components") {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                },

                DocExample(
                    "Custom separator",
                    description: "The separator takes any content — an icon, a character, anything.",
                    code: #"""
                    ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }

                    ShadBreadcrumbSeparator { Text("/") }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadBreadcrumb {
                            ShadBreadcrumbList {
                                ShadBreadcrumbLink("Home") {}
                                ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }
                                ShadBreadcrumbLink("Components") {}
                                ShadBreadcrumbSeparator { ShadIconView(.slash, size: 14) }
                                ShadBreadcrumbPage("Breadcrumb")
                            }
                        }
                        ShadBreadcrumb {
                            ShadBreadcrumbList {
                                ShadBreadcrumbLink("Home") {}
                                ShadBreadcrumbSeparator { Text("›") }
                                ShadBreadcrumbLink("Docs") {}
                                ShadBreadcrumbSeparator { Text("›") }
                                ShadBreadcrumbPage("Breadcrumb")
                            }
                        }
                    }
                },

                DocExample(
                    "Collapsed",
                    description: "An ellipsis stands in for the middle of a long trail.",
                    code: #"""
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") { open(.home) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbEllipsis()
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Components") { open(.components) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                    """#
                ) {
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home") {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbEllipsis()
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Components") {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Breadcrumb")
                        }
                    }
                },

                DocExample(
                    "With icons",
                    description: "Links and pages both take a leading icon.",
                    code: #"""
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home", icon: .home) { open(.home) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Documents", icon: .folder) { open(.documents) }
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Invoice.pdf", icon: .file)
                        }
                    }
                    """#
                ) {
                    ShadBreadcrumb {
                        ShadBreadcrumbList {
                            ShadBreadcrumbLink("Home", icon: .home) {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbLink("Documents", icon: .folder) {}
                            ShadBreadcrumbSeparator()
                            ShadBreadcrumbPage("Invoice.pdf", icon: .file)
                        }
                    }
                },

                DocExample(
                    "A push/pop stack",
                    description: "ShadBreadcrumbPath keeps the trail. Push as you descend; clicking a crumb pops everything after it.",
                    code: #"""
                    @StateObject private var path = ShadBreadcrumbPath("Home")

                    var body: some View {
                        VStack(alignment: .leading) {
                            ShadBreadcrumb(path: path, maxVisible: 4) { crumb in
                                load(crumb)                 // where the user went back to
                            }

                            ShadButton("Open Invoices") {
                                path.push("Invoices", icon: .folder)
                            }
                            ShadButton("Back") { path.pop() }
                                .disabled(!path.canPop)
                        }
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 14) {
                        DocBreadcrumbPathPreview(
                            titles: ["Home", "Documents", "Invoices"],
                            maxVisible: nil
                        )
                        DocBreadcrumbPathPreview(
                            titles: ["Home", "Documents", "Invoices", "2026", "Q3", "March"],
                            maxVisible: 4
                        )
                    }
                },

                DocExample(
                    "Popping several levels",
                    description: "Every pop returns the crumbs it removed, deepest last.",
                    code: #"""
                    let path = ShadBreadcrumbPath("Home", "Documents", "Invoices", "2026")

                    path.pop()                    // -> 2026
                    path.pop(2)                   // -> [Documents, Invoices]
                    path.pop(to: someCrumb)       // pops until someCrumb is current
                    path.pop(toIndex: 0)          // pops to the level at that depth
                    path.popToRoot()              // all the way back

                    path.depth                    // 1 at the root
                    path.canPop                   // false at the root
                    path.current                  // the deepest crumb
                    """#
                ),
            ],
            notes: [
                "The list wraps: a trail too long for its width breaks onto another line rather than clipping.",
                "The root crumb is never popped, so the trail cannot empty out from under the view.",
                "ShadCrumb identity survives rename(_:to:), so a crumb captured before a rename still refers to the same level.",
                "maxVisible collapses only when it hides more than one crumb — swapping a single name for an ellipsis saves no room — so a trail may run one crumb longer than the number given.",
                "shadcn's dropdown-in-a-breadcrumb variant is not implemented; nor is RTL.",
            ],
            api: [
                DocAPI(
                    "ShadBreadcrumbPath",
                    summary: "An observable stack of crumbs. Hand it to ShadBreadcrumb(path:) and it draws itself.",
                    [
                        DocProperty("crumbs", "[ShadCrumb]", "the crumbs, root first"),
                        DocProperty("current", "ShadCrumb?", "the deepest crumb — where the user is now"),
                        DocProperty("root", "ShadCrumb?", "the crumb the trail starts from"),
                        DocProperty("depth", "Int", "how deep the trail runs; 1 at the root"),
                        DocProperty("canPop", "Bool", "whether there is anywhere left to go back to"),
                        DocProperty("push(_:icon:)", "(String, ShadIcon?) -> Void", "descends one level"),
                        DocProperty("pop()", "() -> ShadCrumb?", "goes back one level, returning what it removed"),
                        DocProperty("pop(_:)", "(Int) -> [ShadCrumb]", "goes back several levels, stopping at the root"),
                        DocProperty("pop(to:)", "(ShadCrumb) -> [ShadCrumb]", "goes back until that crumb is current"),
                        DocProperty("pop(toIndex:)", "(Int) -> [ShadCrumb]", "goes back to the level at that depth"),
                        DocProperty("popToRoot()", "() -> [ShadCrumb]", "goes all the way back"),
                        DocProperty("replaceCurrent(with:)", "(ShadCrumb) -> Void", "moves sideways rather than deeper"),
                        DocProperty("rename(_:to:)", "(ShadCrumb, String) -> Void", "renames in place, keeping identity"),
                        DocProperty("reset(to:)", "([ShadCrumb]) -> Void", "throws the trail away and starts again"),
                    ]
                ),
                DocAPI(
                    "ShadCrumb",
                    [
                        DocProperty("title", "String", "the crumb's label"),
                        DocProperty("icon", "ShadIcon?", default: "nil", "an optional leading icon"),
                        DocProperty("id", "UUID", "stable identity, kept across renames"),
                    ]
                ),
                DocAPI(
                    "ShadBreadcrumb(path:maxVisible:onNavigate:)",
                    [
                        DocProperty("path", "ShadBreadcrumbPath", "the stack to draw"),
                        DocProperty("maxVisible", "Int?", default: "nil", "collapse the middle past this many crumbs"),
                        DocProperty("onNavigate", "((ShadCrumb) -> Void)?", default: "nil", "called with the crumb the user moved back to, after the path has been popped"),
                    ]
                ),
                DocAPI(
                    "ShadBreadcrumbLink",
                    [
                        DocProperty("title", "String", "the crumb's label"),
                        DocProperty("icon", "ShadIcon?", default: "nil", "an optional leading icon"),
                        DocProperty("action", "() -> Void", "run when the crumb is clicked"),
                    ]
                ),
            ]
        )
    }

    // MARK: - Sidebar

    static var sidebar: DocComponent {
        DocComponent(
            slug: "sidebar",
            title: "Sidebar",
            summary: "A composable, themeable and customisable sidebar.",
            group: "Layout",
            anatomy: #"""
            ShadSidebarProvider(state:)
            ├── ShadSidebar(side:variant:collapsible:)
            │   ├── ShadSidebarHeader
            │   ├── ShadSidebarContent
            │   │   └── ShadSidebarGroup
            │   │       └── ShadSidebarMenu
            │   │           └── ShadSidebarMenuItem
            │   │               ├── ShadSidebarMenuButton
            │   │               │   └── ShadSidebarMenuBadge
            │   │               ├── ShadSidebarMenuAction
            │   │               └── ShadSidebarMenuSub
            │   │                   └── ShadSidebarMenuSubButton
            │   └── ShadSidebarFooter
            └── ShadSidebarInset
                └── ShadSidebarTrigger
            """#,
            examples: [
                DocExample(
                    "Complete sidebar",
                    description: "Header, groups, badges, a sub-menu, a footer and a trigger.",
                    width: 820,
                    height: 460,
                    padding: 0,
                    code: #"""
                    @StateObject private var sidebar = ShadSidebarState()

                    ShadSidebarProvider(state: sidebar) {
                        ShadSidebar(variant: .sidebar, collapsible: .icon) {
                            ShadSidebarHeader {
                                ShadSidebarMenu {
                                    ShadSidebarMenuButton("Acme Inc.", icon: .zap, size: .lg) {}
                                }
                            }
                            ShadSidebarContent {
                                ShadSidebarGroup("Platform") {
                                    ShadSidebarMenu {
                                        ShadSidebarMenuItem {
                                            ShadSidebarMenuButton("Inbox", icon: .mail,
                                                                  isActive: page == .inbox) {
                                                page = .inbox
                                            } trailing: {
                                                ShadSidebarMenuBadge("24")
                                            }
                                        }
                                        ShadSidebarMenuItem {
                                            ShadSidebarMenuButton("Calendar", icon: .calendar) {}
                                        }
                                    }
                                    ShadSidebarMenuSub {
                                        ShadSidebarMenuSubButton("Drafts") {}
                                        ShadSidebarMenuSubButton("Sent") {}
                                    }
                                }
                            }
                            ShadSidebarFooter {
                                ShadSidebarMenu {
                                    ShadSidebarMenuButton("ez@example.com", icon: .user) {}
                                }
                            }
                        }

                        ShadSidebarInset {
                            HStack { ShadSidebarTrigger(); Text("Inbox") }
                            …
                        }
                    }
                    """#
                ) {
                    DocSidebarPreview(variant: .sidebar, collapsible: .icon, isOpen: true)
                },

                DocExample(
                    "Variants",
                    description: "sidebar is flush, floating detaches the panel, inset turns the content beside it into a rounded card.",
                    width: 820,
                    height: 320,
                    padding: 0,
                    code: #"""
                    ShadSidebar(variant: .sidebar)   { … }   // flush, bordered edge
                    ShadSidebar(variant: .floating)  { … }   // detached, rounded, elevated
                    ShadSidebar(variant: .inset)     { … }   // transparent rail
                    """#
                ) {
                    HStack(spacing: 0) {
                        DocSidebarPreview(variant: .floating, collapsible: .icon, isOpen: true, compact: true)
                        DocSidebarPreview(variant: .inset, collapsible: .icon, isOpen: true, compact: true)
                    }
                },

                DocExample(
                    "Collapsed to icons",
                    description: "collapsible: .icon narrows the panel to a 52pt rail and hides every label. offcanvas slides it away entirely; none pins it open.",
                    width: 820,
                    height: 400,
                    padding: 0,
                    code: #"""
                    ShadSidebar(collapsible: .icon) { … }

                    // Anywhere below the provider:
                    @Environment(\.shadSidebar) private var sidebar
                    sidebar.toggle()          // or ShadSidebarTrigger()
                    sidebar.state             // "expanded" | "collapsed"
                    """#
                ) {
                    DocSidebarPreview(variant: .sidebar, collapsible: .icon, isOpen: false)
                },
            ],
            notes: [
                "Place ShadSidebar before ShadSidebarInset for a left sidebar and after it for a right one; the side prop controls the chrome.",
                "The gallery app's own navigation is a ShadSidebar with variant: .inset.",
            ],
            api: [
                DocAPI("ShadSidebar", [
                    DocProperty("side", "ShadSidebarSide", default: ".left", "left or right; controls the border and rail edge."),
                    DocProperty("variant", "ShadSidebarVariant", default: ".sidebar", "sidebar, floating or inset."),
                    DocProperty("collapsible", "ShadSidebarCollapsible", default: ".icon", "offcanvas, icon or none."),
                ]),
                DocAPI("ShadSidebarState", summary: "The observable object you pass to ShadSidebarProvider.", [
                    DocProperty("isOpen", "Bool", default: "true", "Expanded or collapsed."),
                    DocProperty("width", "CGFloat", default: "256", "Expanded width."),
                    DocProperty("iconWidth", "CGFloat", default: "52", "Collapsed rail width."),
                    DocProperty("state", "String", "\"expanded\" or \"collapsed\"."),
                    DocProperty("toggle() / setOpen(_:)", "Void", "Mutators."),
                ]),
                DocAPI("ShadSidebarMenuButton", [
                    DocProperty("title", "String", "Row label; used as a tooltip when collapsed."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon; the only thing shown when collapsed."),
                    DocProperty("isActive", "Bool", default: "false", "Highlights the row."),
                    DocProperty("size", "Size", default: ".default", "sm (28pt), default (32pt) or lg (48pt)."),
                    DocProperty("trailing", "() -> View", "Badge or other trailing content."),
                ]),
            ]
        )
    }

    // MARK: - Theming

    static var theming: DocComponent {
        DocComponent(
            slug: "theming",
            title: "Theming",
            summary: "One value carries every design decision: colour, radius, type, spacing, elevation and motion.",
            group: "Foundations",
            anatomy: #"""
            ShadThemeSet            // light palette + dark palette + shared decisions
            └── resolved(for:)  ->  ShadTheme
                ├── colors      ShadColors        (38 semantic tokens)
                ├── radius      ShadRadius        (xs · sm · md · lg · xl · full)
                ├── spacing     ShadSpacing       (4pt scale)
                ├── typography  ShadTypography    (xs · sm · base · lg · xl · xxl)
                ├── shadows     ShadShadows       (xs · sm · md · lg)
                ├── motion      ShadMotion
                └── focusRing   ShadFocusRing
            """#,
            examples: [
                DocExample(
                    "Base colors",
                    description: "Nine presets, each a full light/dark pair. neutral is shadcn's default.",
                    width: 800,
                    code: #"""
                    ContentView().shadTheme(.default)   // neutral
                    ContentView().shadTheme(.zinc)
                    ContentView().shadTheme(.slate)
                    ContentView().shadTheme(.stone)
                    ContentView().shadTheme(.blue)
                    ContentView().shadTheme(.green)
                    ContentView().shadTheme(.rose)
                    ContentView().shadTheme(.violet)
                    ContentView().shadTheme(.orange)
                    """#
                ) {
                    DocPresetStrip()
                },

                DocExample(
                    "Radius",
                    description: "sm, md, lg and xl all derive from one base, mirroring the calc() chain in shadcn's CSS.",
                    width: 800,
                    code: #"""
                    ContentView().shadTheme(ShadThemeSet.default.radius(0))
                    ContentView().shadTheme(ShadThemeSet.default.radius(10))   // default
                    ContentView().shadTheme(ShadThemeSet.default.radius(20))

                    // Or override one subtree only:
                    VStack { … }
                        .shadTheme { $0.radius = ShadRadius(base: 0) }
                    """#
                ) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach([0, 10, 20], id: \.self) { radius in
                            ShadCard(size: .sm) {
                                ShadCardHeader {
                                    ShadCardTitle("radius \(radius)")
                                    ShadCardDescription("ShadRadius(base: \(radius))")
                                }
                                ShadCardContent {
                                    HStack(spacing: 8) {
                                        ShadButton("Save", size: .sm) {}
                                        ShadBadge("New", variant: .secondary)
                                    }
                                }
                            }
                            .shadTheme { $0.radius = ShadRadius(base: CGFloat(radius)) }
                        }
                    }
                },

                DocExample(
                    "Authoring colours in OKLCH",
                    description: "The same notation shadcn uses in globals.css, converted to sRGB at build time.",
                    width: 800,
                    code: #"""
                    var colors = ShadColors.light
                    colors.primary = Color(oklch: 0.546, 0.215, 262.881)
                    colors.primaryForeground = Color(oklch: 0.985, 0, 0)

                    let theme = ShadThemeSet(light: colors, dark: .dark)

                    // Or tint an existing preset:
                    let brand = ShadThemeSet.slate
                        .radius(4)
                        .tinted(light: OKLCH(0.55, 0.20, 264),
                                dark:  OKLCH(0.65, 0.20, 264))

                    // OKLCH round-trips to hex, which is handy for exports:
                    OKLCH(0.546, 0.215, 262.881).hexString   // "#3B6FF0"
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            ShadButton("Primary") {}
                            ShadButton("Outline", variant: .outline) {}
                            ShadBadge("Badge", variant: .secondary)
                            ShadSwitch(isOn: .constant(true))
                            ShadCheckbox(isOn: .constant(true))
                        }
                        .shadTheme(
                            ShadThemeSet.slate
                                .radius(4)
                                .tinted(light: OKLCH(0.55, 0.20, 264), dark: OKLCH(0.65, 0.20, 264))
                                .resolved(for: .light)
                        )
                        Text("ShadThemeSet.slate.radius(4).tinted(light: OKLCH(0.55, 0.20, 264), …)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                },

                DocExample(
                    "Tokens",
                    description: "Every colour a component can reference. Component code never names a colour directly.",
                    width: 800,
                    code: #"""
                    theme.colors.background      theme.colors.foreground
                    theme.colors.card            theme.colors.popover
                    theme.colors.primary         theme.colors.primaryForeground
                    theme.colors.secondary       theme.colors.muted
                    theme.colors.accent          theme.colors.destructive
                    theme.colors.success         theme.colors.warning
                    theme.colors.info            theme.colors.border
                    theme.colors.input           theme.colors.ring
                    theme.colors.chart1 … chart5
                    theme.colors.sidebar         theme.colors.sidebarAccent
                    """#
                ) {
                    DocTokenGrid()
                },

                DocExample(
                    "Chat bubbles",
                    description: "Bubbles have their own tokens rather than borrowing primary, so a conversation keeps its palette whatever the brand colour is.",
                    width: 800,
                    code: #"""
                    ShadThemeSet.default.bubbles(
                        sent: Color(oklch: 0.60, 0.196, 258), sentForeground: .white,
                        received: Color(oklch: 0.955, 0, 0),
                        receivedForeground: Color(oklch: 0.145, 0, 0)
                    )

                    // Or a single token:
                    theme.colors.bubbleSent = .accentColor
                    """#
                ) {
                    VStack(spacing: 10) {
                        ShadBubble(variant: .received, align: .start) {
                            ShadBubbleContent("Received messages use bubbleReceived.")
                        }
                        ShadBubble(variant: .sent, align: .end) {
                            ShadBubbleContent("Sent messages use bubbleSent.")
                        }
                    }
                    .frame(width: 520)
                },

                DocExample(
                    "Type, elevation and motion",
                    width: 800,
                    code: #"""
                    ShadThemeSet.default
                        .typography(ShadTypography(fontName: "Geist",
                                                   sm: 13, base: 15))
                        .shadows(.none)                     // flat design
                        .motion(.none)                      // no animation at all
                        .borderWidth(0.5)                   // hairlines
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            ShadButton("Default") {}
                            ShadBadge("Badge", variant: .secondary)
                            ShadCard(size: .sm) { ShadCardContent { Text("Card") } }.frame(width: 110)
                        }
                        HStack(spacing: 12) {
                            ShadButton("Flat") {}
                            ShadBadge("Badge", variant: .secondary)
                            ShadCard(size: .sm) { ShadCardContent { Text("Card") } }.frame(width: 110)
                        }
                        .shadTheme(
                            ShadThemeSet.default.shadows(.none).borderWidth(0.5).resolved(for: .light)
                        )
                    }
                },
            ],
            api: [
                DocAPI("ShadThemeSet", summary: "A light/dark pair plus the decisions shared between them.", [
                    DocProperty("light / dark", "ShadColors", "The two palettes."),
                    DocProperty("radius(_:)", "ShadThemeSet", "New corner radius base, in points."),
                    DocProperty("typography(_:) / fontName(_:)", "ShadThemeSet", "Type scale and family."),
                    DocProperty("shadows(_:) / motion(_:) / borderWidth(_:)", "ShadThemeSet", "Elevation, animation, hairlines."),
                    DocProperty("tinted(light:dark:)", "ShadThemeSet", "Swaps the brand colour, keeping the neutrals."),
                    DocProperty("bubbles(sent:sentForeground:received:receivedForeground:)", "ShadThemeSet", "Recolours the conversation surfaces on their own."),
                    DocProperty("colors(_:)", "ShadThemeSet", "Mutates both palettes in one closure."),
                    DocProperty("presets", "[(String, ShadThemeSet)]", "All nine built-ins, for theme pickers."),
                ]),
                DocAPI("View.shadTheme", [
                    DocProperty("shadTheme(_ set:colorScheme:)", "some View", "Resolves against the ambient scheme and injects."),
                    DocProperty("shadTheme(_ theme:)", "some View", "Injects an already-resolved theme."),
                    DocProperty("shadTheme { theme in … }", "some View", "Mutates the inherited theme for one subtree."),
                ]),
                DocAPI("OKLCH", [
                    DocProperty("init(_:_:_:alpha:)", "OKLCH", "Lightness, chroma, hue in degrees."),
                    DocProperty("init(hex:)", "OKLCH", "Parses #rgb, #rrggbb or #rrggbbaa."),
                    DocProperty("color / hexString / sRGB", "Color / String / tuple", "Conversions."),
                    DocProperty("opacity(_:) / lightness(_:) / chroma(_:)", "OKLCH", "Derivations."),
                ]),
            ]
        )
    }
}

// MARK: - Preview helpers

private struct DocSidebarPreview: View {
    let variant: ShadSidebarVariant
    let collapsible: ShadSidebarCollapsible
    let isOpen: Bool
    var compact: Bool = false

    @Environment(\.shadTheme) private var theme

    var body: some View {
        ShadSidebarProvider(state: ShadSidebarState(isOpen: isOpen, width: compact ? 190 : 230)) {
            ShadSidebar(variant: variant, collapsible: collapsible) {
                ShadSidebarHeader {
                    ShadSidebarMenu {
                        ShadSidebarMenuButton("Acme Inc.", icon: .zap, size: .lg) {}
                    }
                }
                ShadSidebarContent {
                    ShadSidebarGroup("Platform") {
                        ShadSidebarMenu {
                            ShadSidebarMenuItem {
                                ShadSidebarMenuButton("Inbox", icon: .mail, isActive: true) {} trailing: {
                                    ShadSidebarMenuBadge("24")
                                }
                            }
                            ShadSidebarMenuItem {
                                ShadSidebarMenuButton("Calendar", icon: .calendar) {}
                            }
                            ShadSidebarMenuItem {
                                ShadSidebarMenuButton("Search", icon: .search) {}
                            }
                        }
                        if !compact {
                            ShadSidebarMenuSub {
                                ShadSidebarMenuSubButton("Drafts") {}
                                ShadSidebarMenuSubButton("Sent", isActive: true) {}
                            }
                        }
                    }
                    if !compact {
                        ShadSidebarGroup("Projects") {
                            ShadSidebarMenu {
                                ShadSidebarMenuItem {
                                    ShadSidebarMenuButton("Design system", icon: .sparkles) {}
                                    ShadSidebarMenuAction(action: {}) {
                                        ShadIconView(.moreHorizontal, size: 13)
                                    }
                                }
                            }
                        }
                    }
                }
                ShadSidebarFooter {
                    ShadSidebarMenu {
                        ShadSidebarMenuButton("ez@example.com", icon: .user) {}
                    }
                }
            }

            ShadSidebarInset(variant: variant) {
                HStack(spacing: 10) {
                    ShadSidebarTrigger()
                    ShadSeparator(.vertical).frame(height: 16)
                    Text("Inbox").font(theme.font(theme.typography.sm, .medium))
                    Spacer()
                    ShadBadge(isOpen ? "expanded" : "collapsed", variant: .secondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                ShadSeparator()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Main content").font(theme.font(theme.typography.base, .semibold))
                    Text("variant: .\(variant.rawValue) · collapsible: .\(collapsible.rawValue)")
                        .font(theme.font(theme.typography.xs))
                        .foregroundStyle(theme.colors.mutedForeground)
                    HStack(spacing: 8) {
                        ShadButton("Primary", size: .sm) {}
                        ShadButton("Secondary", variant: .outline, size: .sm) {}
                    }
                }
                .padding(16)
                Spacer(minLength: 0)
            }
        }
        .background(theme.colors.sidebar)
    }
}

private struct DocPresetStrip: View {
    @Environment(\.shadTheme) private var theme

    var body: some View {
        ShadWrapLayout(spacing: 12, lineSpacing: 12, alignment: .top) {
            ForEach(ShadThemeSet.presets, id: \.name) { preset in
                VStack(alignment: .leading, spacing: 8) {
                    Text(preset.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.colors.mutedForeground)
                    HStack(spacing: 6) {
                        ShadButton("Button", size: .xs) {}
                        ShadBadge("Badge", variant: .secondary)
                    }
                    .shadTheme(preset.theme.resolved(for: theme.colorScheme))
                }
                .frame(width: 168, alignment: .leading)
            }
        }
    }
}

private struct DocTokenGrid: View {
    @Environment(\.shadTheme) private var theme

    private let swatches: [(String, KeyPath<ShadColors, Color>)] = [
        ("background", \.background), ("foreground", \.foreground),
        ("card", \.card), ("popover", \.popover),
        ("primary", \.primary), ("secondary", \.secondary),
        ("muted", \.muted), ("mutedForeground", \.mutedForeground),
        ("accent", \.accent), ("destructive", \.destructive),
        ("success", \.success), ("warning", \.warning),
        ("info", \.info), ("border", \.border),
        ("input", \.input), ("ring", \.ring),
        ("chart1", \.chart1), ("chart2", \.chart2),
        ("chart3", \.chart3), ("chart4", \.chart4),
        ("chart5", \.chart5), ("sidebar", \.sidebar),
        ("sidebarAccent", \.sidebarAccent), ("sidebarPrimary", \.sidebarPrimary),
        ("bubbleSent", \.bubbleSent), ("bubbleReceived", \.bubbleReceived),
    ]

    var body: some View {
        ShadWrapLayout(spacing: 10, lineSpacing: 10, alignment: .top) {
            ForEach(swatches, id: \.0) { name, path in
                VStack(alignment: .leading, spacing: 4) {
                    ShadRoundedRectangle(cornerRadius: theme.radius.md)
                        .fill(theme.colors[keyPath: path])
                        .frame(width: 108, height: 40)
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
}

/// Renders a breadcrumb path in the docs snapshots, where there is no run loop
/// to push or pop from.
@MainActor
struct DocBreadcrumbPathPreview: View {
    let titles: [String]
    let maxVisible: Int?

    var body: some View {
        let path = ShadBreadcrumbPath(titles.map { ShadCrumb($0) })
        ShadBreadcrumb(path: path, maxVisible: maxVisible)
    }
}
