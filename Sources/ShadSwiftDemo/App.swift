import SwiftUI
import AppKit
import ShadSwift

@main
struct ShadSwiftDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup("ShadSwift") {
            RootView()
                .frame(minWidth: 1040, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 860)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

/// Every page in the gallery.
enum DemoPageID: String, CaseIterable, Identifiable, Hashable {
    case overview
    case button, badge, card, avatar, item, spinner
    case toggleSwitch, checkbox, radio, slider, tabs
    case input, textarea, field, form, calendar, datePicker
    case select, combobox, dropdown, dialog, toast
    case sidebar, breadcrumb
    case table, pagination
    case message, bubble, marker, messageScroller
    case theming

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .button: return "Button"
        case .badge: return "Badge"
        case .card: return "Card"
        case .avatar: return "Avatar"
        case .item: return "Item"
        case .spinner: return "Spinner"
        case .toggleSwitch: return "Switch"
        case .checkbox: return "Checkbox"
        case .radio: return "Radio Group"
        case .slider: return "Slider"
        case .tabs: return "Tabs"
        case .input: return "Input"
        case .textarea: return "Textarea"
        case .field: return "Field"
        case .form: return "Form"
        case .calendar: return "Calendar"
        case .datePicker: return "Date Picker"
        case .select: return "Select"
        case .combobox: return "Combobox"
        case .dropdown: return "Dropdown Menu"
        case .dialog: return "Dialog"
        case .toast: return "Toast"
        case .sidebar: return "Sidebar"
        case .breadcrumb: return "Breadcrumb"
        case .table: return "Table"
        case .pagination: return "Pagination"
        case .message: return "Message"
        case .bubble: return "Bubble"
        case .marker: return "Marker"
        case .messageScroller: return "Message Scroller"
        case .theming: return "Theming"
        }
    }

    var icon: ShadIcon {
        switch self {
        case .overview: return .home
        case .button: return .zap
        case .badge: return .tag
        case .card: return .file
        case .avatar: return .user
        case .item: return .list
        case .spinner: return .refresh
        case .toggleSwitch: return .settings
        case .checkbox: return .check
        case .radio: return .circle
        case .slider: return .filter
        case .tabs: return .grid
        case .input: return .pencil
        case .textarea: return .terminal
        case .field: return .folder
        case .form: return .clipboardLike
        case .calendar: return .calendar
        case .datePicker: return .clock
        case .select: return .chevronsUpDown
        case .combobox: return .search
        case .dropdown: return .moreHorizontal
        case .dialog: return .image
        case .toast: return .bell
        case .sidebar: return .panelLeft
        case .breadcrumb: return .chevronRight
        case .table: return .list
        case .pagination: return .moreHorizontal
        case .message: return .mail
        case .bubble: return .sparkles
        case .marker: return .gitBranch
        case .messageScroller: return .bot
        case .theming: return .star
        }
    }

    var group: String {
        switch self {
        case .overview, .theming: return "Getting started"
        case .button, .badge, .card, .avatar, .item, .spinner: return "Display"
        case .toggleSwitch, .checkbox, .radio, .slider, .tabs: return "Controls"
        case .input, .textarea, .field, .form, .calendar, .datePicker: return "Forms"
        case .select, .combobox, .dropdown, .dialog, .toast: return "Overlays"
        case .sidebar, .breadcrumb: return "Layout"
        case .table, .pagination: return "Data"
        case .message, .bubble, .marker, .messageScroller: return "Conversation"
        }
    }

    static var groups: [(String, [DemoPageID])] {
        var seen: [String] = []
        var buckets: [String: [DemoPageID]] = [:]
        for page in DemoPageID.allCases {
            if !seen.contains(page.group) { seen.append(page.group) }
            buckets[page.group, default: []].append(page)
        }
        return seen.map { ($0, buckets[$0] ?? []) }
    }
}

extension ShadIcon {
    /// Lucide's `clipboard-list`.
    static var clipboardLike: ShadIcon { .clipboardList }
}
