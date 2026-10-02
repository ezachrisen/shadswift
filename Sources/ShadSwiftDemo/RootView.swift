import SwiftUI
import ShadSwift

struct RootView: View {
    @State private var page: DemoPageID = DemoLaunchOptions.page
    @State private var presetName = DemoLaunchOptions.preset
    @State private var radius: Double = DemoLaunchOptions.radius
    @State private var isDark = DemoLaunchOptions.isDark
    @State private var font: DemoFont = .geist
    #if os(macOS)
    @State private var sidebarBackgroundStyle: ShadSidebarBackgroundStyle = .solid
    #endif
    @State private var showsThemePanel = DemoLaunchOptions.opensDialog

    @StateObject private var sidebar = ShadSidebarState()
    @StateObject private var toasts = ShadToastCenter()

    private var themeSet: ShadThemeSet {
        let base = ShadThemeSet.presets.first { $0.name == presetName }?.theme ?? .default
        return base
            .radius(CGFloat(radius))
            .typography(font.typography)
    }

    private var theme: ShadTheme {
        themeSet.resolved(for: isDark ? .dark : .light)
    }

    var body: some View {
        gallery
            .font(theme.font(theme.typography.sm))
            .shadTheme(themeSet, colorScheme: isDark ? .dark : .light)
            .shadToaster(toasts, position: .bottomTrailing)
            .environmentObject(toasts)
    }

    private var appearance: some View {
        #if os(macOS)
        ThemePanel(
            presetName: $presetName,
            radius: $radius,
            isDark: $isDark,
            font: $font,
            sidebarBackgroundStyle: $sidebarBackgroundStyle
        )
        #else
        ThemePanel(presetName: $presetName, radius: $radius, isDark: $isDark, font: $font)
        #endif
    }

    @ViewBuilder
    private var gallery: some View {
#if os(iOS)
        NavigationStack {
            pageContent
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu("Components", systemImage: "sidebar.left") {
                            ForEach(DemoPageID.groups, id: \.0) { group, pages in
                                Section(group) {
                                    ForEach(pages) { item in
                                        Button(item.title) { page = item }
                                    }
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Appearance", systemImage: "paintpalette") {
                            showsThemePanel = true
                        }
                    }
                }
        }
        .sheet(isPresented: $showsThemePanel) {
            ScrollView { appearance.padding(16) }
                .font(theme.font(theme.typography.sm))
                .environment(\.shadDialogDismiss, { showsThemePanel = false })
                .shadTheme(themeSet, colorScheme: isDark ? .dark : .light)
        }
#else
        GeometryReader { geometry in
            macGallery(titlebarHeight: geometry.safeAreaInsets.top)
                .ignoresSafeArea(.container, edges: .top)
        }
#endif
    }

#if os(macOS)
    private func macGallery(titlebarHeight: CGFloat) -> some View {
        ShadSidebarProvider(state: sidebar, backgroundStyle: sidebarBackgroundStyle) {
            ShadSidebar(variant: .sidebar, collapsible: .icon) {
                ShadSidebarHeader {
                    ShadSidebarMenu {
                        ShadSidebarMenuButton("ShadSwift", icon: .sparkles, size: .lg) {}
                    }
                }
                // The surface reaches the window edge; controls stay below
                // the traffic lights, including when the sidebar is collapsed.
                .padding(.top, titlebarHeight)
                ShadSidebarContent {
                    ForEach(DemoPageID.groups, id: \.0) { group, pages in
                        ShadSidebarGroup(group) {
                            ShadSidebarMenu {
                                ForEach(pages) { item in
                                    ShadSidebarMenuItem {
                                        ShadSidebarMenuButton(
                                            item.title,
                                            icon: item.icon,
                                            isActive: page == item
                                        ) {
                                            page = item
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                ShadSidebarFooter {
                    ShadSidebarMenu {
                        ShadSidebarMenuButton("Appearance", icon: .settings) {
                            showsThemePanel = true
                        }
                    }
                }
            }

            ShadSidebarInset(variant: .sidebar) {
                topBar
                    .padding(.top, titlebarHeight)
                ShadSeparator()
                pageContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadDialog(isPresented: $showsThemePanel) {
            appearance
        }
    }
#endif

    private var topBar: some View {
        HStack(spacing: 12) {
            ShadSidebarTrigger()
            ShadSeparator(.vertical).frame(height: 18)
            Text(page.title)
                .font(theme.font(theme.typography.sm, theme.typography.medium))
                .foregroundStyle(theme.colors.foreground)
            Spacer()
            ShadBadge(presetName, variant: .secondary, icon: .tag)
            ShadButton(
                icon: isDark ? .eye : .eyeOff,
                variant: .ghost,
                size: .iconSM,
                accessibilityLabel: "Toggle dark mode"
            ) {
                isDark.toggle()
            }
            ShadButton("Theme", variant: .outline, size: .sm, icon: .settings) {
                showsThemePanel = true
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .overview: OverviewPage(page: $page)
        case .button: ButtonPage()
        case .badge: BadgePage()
        case .card: CardPage()
        case .avatar: AvatarPage()
        case .item: ItemPage()
        case .spinner: SpinnerPage()
        case .toggleSwitch: SwitchPage()
        case .checkbox: CheckboxPage()
        case .radio: RadioPage()
        case .slider: SliderPage()
        case .tabs: TabsPage()
        case .input: InputPage()
        case .textarea: TextareaPage()
        case .field: FieldPage()
        case .form: FormPage()
        case .calendar: CalendarPage()
        case .datePicker: DatePickerPage()
        case .select: SelectPage()
        case .combobox: ComboboxPage()
        case .dropdown: DropdownPage()
        case .dialog: DialogPage()
        case .toast: ToastPage()
        case .sidebar:
            #if os(macOS)
            SidebarPage(backgroundStyle: $sidebarBackgroundStyle)
            #else
            SidebarPage()
            #endif
        case .breadcrumb: BreadcrumbPage()
        case .table: TablePage()
        case .pagination: PaginationPage()
        case .message: MessagePage()
        case .bubble: BubblePage()
        case .marker: MarkerPage()
        case .messageScroller: MessageScrollerPage()
        case .theming: ThemingPage(presetName: $presetName, radius: $radius, isDark: $isDark, font: $font)
        }
    }
}

/// The appearance dialog, which doubles as a Dialog demo.
struct ThemePanel: View {
    @Environment(\.shadTheme) private var theme
    @Binding var presetName: String
    @Binding var radius: Double
    @Binding var isDark: Bool
    @Binding var font: DemoFont
    #if os(macOS)
    @Binding var sidebarBackgroundStyle: ShadSidebarBackgroundStyle
    #endif

    private var presetOptions: [ShadSelectOption<String>] {
        ShadThemeSet.presets.map { ShadSelectOption($0.name.capitalized, value: $0.name) }
    }

    var body: some View {
        ShadDialogContent(maxWidth: 460) {
            ShadDialogHeader {
                ShadDialogTitle("Appearance")
                ShadDialogDescription("Every ShadSwift component reads these values from the theme in the environment.")
            }

            ShadFieldGroup(spacing: 18) {
                ShadField {
                    ShadFieldLabel("Base color")
                    ShadSelect(
                        selection: Binding(get: { Optional(presetName) }, set: { presetName = $0 ?? "neutral" }),
                        options: presetOptions,
                        placeholder: "Base color"
                    )
                    ShadFieldDescription("Presets mirror shadcn's base colors.")
                }

                ShadField {
                    ShadFieldLabel("Radius — \(Int(radius))pt")
                    ShadSlider(value: $radius, in: 0...20, step: 1)
                    ShadFieldDescription("Drives every corner in the library, like --radius.")
                }

                ShadField(orientation: .horizontal) {
                    ShadFieldContent {
                        ShadFieldTitle("Dark mode")
                        ShadFieldDescription("Resolves the dark palette.")
                    }
                    ShadSwitch(isOn: $isDark)
                }

                ShadField {
                    ShadFieldLabel("Default font")
                    DemoFontPicker(selection: $font)
                    ShadFieldDescription("Used throughout the gallery and component examples.")
                }

                #if os(macOS)
                ShadField {
                    ShadFieldLabel("Sidebar background")
                    ShadSelect(
                        selection: Binding(
                            get: { Optional(sidebarBackgroundStyle) },
                            set: { sidebarBackgroundStyle = $0 ?? .solid }
                        ),
                        options: ShadSidebarBackgroundStyle.allCases.map {
                            ShadSelectOption($0.rawValue.capitalized, value: $0)
                        }
                    )
                    ShadFieldDescription("Frosted and glass styles reveal the desktop and windows behind the sidebar.")
                }
                #endif
            }

            ShadDialogFooter {
                ShadDialogClose("Done", variant: .default)
            }
        }
    }
}


/// Launch arguments, so a screenshot run can open straight onto a page:
/// `ShadSwiftDemo --page combobox --dark --preset blue --radius 4`.
enum DemoLaunchOptions {
    private static let arguments = CommandLine.arguments

    private static func value(_ flag: String) -> String? {
        guard let index = arguments.firstIndex(of: "--\(flag)"), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static var page: DemoPageID {
        value("page").flatMap(DemoPageID.init(rawValue:)) ?? .overview
    }

    static var preset: String { value("preset") ?? "neutral" }
    static var radius: Double { value("radius").flatMap(Double.init) ?? 10 }
    static var isDark: Bool { arguments.contains("--dark") }

    /// Opens the first menu on the page at launch, so a screenshot can capture
    /// the popover panel without any clicking.
    static var opensMenu: Bool { arguments.contains("--open-menu") }

    /// Opens the appearance dialog at launch, so the scrim can be inspected.
    static var opensDialog: Bool { arguments.contains("--open-dialog") }

    /// Opens the date range picker at launch, so the two-month panel can be
    /// captured without clicking.
    static var opensRangePicker: Bool { arguments.contains("--open-range") }
}
