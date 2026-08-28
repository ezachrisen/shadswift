import SwiftUI
import ShadSwift

private let frameworks: [ShadSelectOption<String>] = [
    ShadSelectOption("Next.js", value: "next"),
    ShadSelectOption("SvelteKit", value: "svelte"),
    ShadSelectOption("Nuxt.js", value: "nuxt"),
    ShadSelectOption("Remix", value: "remix"),
    ShadSelectOption("Astro", value: "astro"),
    ShadSelectOption("SolidStart", value: "solid"),
]

// MARK: - Select

struct SelectPage: View {
    @State private var theme: String? = nil
    @State private var fruit: String? = "apple"
    @State private var timezone: String? = nil
    @State private var invalid: String? = nil
    @State private var isOpen = DemoLaunchOptions.opensMenu

    private let grouped: [ShadSelectSection<String>] = [
        ShadSelectSection("North America", options: [
            ShadSelectOption("Eastern Standard Time (EST)", value: "est"),
            ShadSelectOption("Central Standard Time (CST)", value: "cst"),
            ShadSelectOption("Pacific Standard Time (PST)", value: "pst"),
        ]),
        ShadSelectSection("Europe", options: [
            ShadSelectOption("Greenwich Mean Time (GMT)", value: "gmt"),
            ShadSelectOption("Central European Time (CET)", value: "cet"),
            ShadSelectOption("Eastern European Time (EET)", value: "eet"),
        ]),
        ShadSelectSection("Asia", options: [
            ShadSelectOption("India Standard Time (IST)", value: "ist"),
            ShadSelectOption("Japan Standard Time (JST)", value: "jst"),
        ]),
    ]

    var body: some View {
        DemoPage(title: "Select", subtitle: "Displays a list of options for the user to pick from, triggered by a button.") {
            DemoSection("Default", description: "Opens in a borderless panel, so it is never clipped by a scroll view.") {
                ShadSelect(selection: $theme, options: [
                    ShadSelectOption("Light", value: "light", icon: .eye),
                    ShadSelectOption("Dark", value: "dark", icon: .eyeOff),
                    ShadSelectOption("System", value: "system", icon: .settings),
                ], placeholder: "Theme", width: 220, isOpen: $isOpen)
            }

            DemoSection("States", description: "Select is a single size, matching shadcn: 32pt with a 14pt label.") {
                DemoRow {
                    ShadSelect(selection: $fruit, options: fruitOptions, placeholder: "Default", width: 180)
                    ShadSelect(selection: $invalid, options: fruitOptions, placeholder: "Invalid", isInvalid: true, width: 180)
                    ShadSelect(selection: .constant(nil), options: fruitOptions, placeholder: "Disabled", width: 180)
                        .disabled(true)
                }
            }

            DemoSection("Grouped", description: "Sections get a heading and a separator; the list scrolls.") {
                ShadSelect(selection: $timezone, sections: grouped, placeholder: "Select a timezone", width: 280)
            }

            DemoSection("Disabled options") {
                ShadSelect(selection: .constant(nil), options: [
                    ShadSelectOption("Available", value: "a"),
                    ShadSelectOption("Sold out", value: "b", isDisabled: true),
                    ShadSelectOption("Available", value: "c"),
                ], placeholder: "Pick one", width: 220)
            }
        }
    }

    private var fruitOptions: [ShadSelectOption<String>] {
        [
            ShadSelectOption("Apple", value: "apple"),
            ShadSelectOption("Banana", value: "banana"),
            ShadSelectOption("Blueberry", value: "blueberry"),
            ShadSelectOption("Pineapple", value: "pineapple"),
        ]
    }
}

// MARK: - Combobox

struct ComboboxPage: View {
    @State private var single: String? = nil
    @State private var withClear: String? = nil
    @State private var popup: String? = nil
    @State private var multiple: Set<String> = ["next"]
    @State private var grouped: String? = nil

    private let groupedSections: [ShadSelectSection<String>] = [
        ShadSelectSection("Frontend", options: [
            ShadSelectOption("React", value: "react", keywords: ["meta", "jsx"]),
            ShadSelectOption("Vue", value: "vue"),
            ShadSelectOption("Svelte", value: "svelte"),
        ]),
        ShadSelectSection("Backend", options: [
            ShadSelectOption("Vapor", value: "vapor", keywords: ["swift"]),
            ShadSelectOption("Django", value: "django", keywords: ["python"]),
            ShadSelectOption("Rails", value: "rails", keywords: ["ruby"]),
        ]),
    ]

    var body: some View {
        DemoPage(title: "Combobox", subtitle: "An autocomplete input with a list of suggestions.") {
            DemoSection("Single selection", description: "Type to filter; ↑ ↓ move the highlight, ⏎ selects.") {
                ShadCombobox(
                    selection: $single,
                    options: frameworks,
                    placeholder: "Select framework…",
                    width: 280
                )
            }

            DemoSection("With clear and a leading icon", description: "showsClear reveals a clear button once there is text.") {
                ShadCombobox(
                    selection: $withClear,
                    options: frameworks,
                    placeholder: "Search frameworks…",
                    showsClear: true,
                    icon: .search,
                    width: 280
                )
            }

            DemoSection("Grouped with keywords", description: "Options can match on extra keywords — try \"swift\" or \"python\".") {
                ShadCombobox(
                    selection: $grouped,
                    sections: groupedSections,
                    placeholder: "Search stacks…",
                    width: 280
                )
            }

            DemoSection("Multiple selection", description: "Selections become chips that wrap inside the control.") {
                ShadComboboxMultiple(
                    selection: $multiple,
                    options: frameworks,
                    placeholder: "Add frameworks…",
                    width: 380
                )
            }

            DemoSection("Popup trigger", description: "A button opens a panel with the search field inside it.") {
                ShadComboboxButton(
                    selection: $popup,
                    options: frameworks,
                    placeholder: "Select framework…",
                    searchPlaceholder: "Search framework…",
                    width: 260
                )
            }

            DemoSection("States") {
                DemoRow {
                    ShadCombobox(selection: .constant(nil), options: frameworks, placeholder: "Invalid", isInvalid: true, width: 200)
                    ShadCombobox(selection: .constant(nil), options: frameworks, placeholder: "Disabled", width: 200)
                        .disabled(true)
                }
            }
        }
    }
}

// MARK: - Dropdown menu

struct DropdownPage: View {
    @State private var statusBar = true
    @State private var activityBar = false
    @State private var panel = false
    @State private var position = "bottom"
    @State private var isOpen = DemoLaunchOptions.opensMenu
    @EnvironmentObject private var toasts: ShadToastCenter

    var body: some View {
        DemoPage(title: "Dropdown Menu", subtitle: "Displays a menu to the user — a set of actions or functions — triggered by a button.") {
            DemoSection("Default", description: "Labels, separators, shortcuts and destructive rows.") {
                ShadDropdownMenu("Open", isOpen: $isOpen, minWidth: 200) {
                    ShadDropdownMenuLabel("My Account")
                    ShadDropdownMenuSeparator()
                    ShadDropdownMenuGroup {
                        ShadDropdownMenuItem("Profile", icon: .user, shortcut: "⇧⌘P") {}
                        ShadDropdownMenuItem("Billing", icon: .creditCard, shortcut: "⌘B") {}
                        ShadDropdownMenuItem("Settings", icon: .settings, shortcut: "⌘S") {}
                    }
                    ShadDropdownMenuSeparator()
                    ShadDropdownMenuSub("Invite users", icon: .users) {
                        ShadDropdownMenuItem("Email", icon: .mail) {}
                        ShadDropdownMenuItem("Message", icon: .send) {}
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuItem("More…") {}
                    }
                    ShadDropdownMenuSeparator()
                    ShadDropdownMenuItem("Log out", icon: .logOut, variant: .destructive, shortcut: "⇧⌘Q") {
                        toasts.info("Signed out")
                    }
                }
            }

            DemoSection("Checkbox items", description: "Rows that toggle without closing the menu.") {
                ShadDropdownMenu("Appearance", variant: .outline, minWidth: 200) {
                    ShadDropdownMenuLabel("Appearance")
                    ShadDropdownMenuSeparator()
                    ShadDropdownMenuCheckboxItem("Status Bar", isOn: $statusBar)
                    ShadDropdownMenuCheckboxItem("Activity Bar", isOn: $activityBar)
                    ShadDropdownMenuCheckboxItem("Panel", isOn: $panel)
                }
            }

            DemoSection("Radio group", description: "Mutually exclusive rows.") {
                ShadDropdownMenu("Panel position", variant: .secondary, minWidth: 180) {
                    ShadDropdownMenuLabel("Panel position")
                    ShadDropdownMenuSeparator()
                    ShadDropdownMenuRadioGroup(selection: $position) {
                        ShadDropdownMenuRadioItem("Top", value: "top")
                        ShadDropdownMenuRadioItem("Bottom", value: "bottom")
                        ShadDropdownMenuRadioItem("Right", value: "right")
                    }
                }
            }

            DemoSection("Custom triggers", description: "Any view can be the trigger.") {
                DemoRow {
                    ShadDropdownMenu(alignment: .bottomTrailing) { isOpen in
                        ShadAvatar(fallback: "CN", size: .lg)
                            .opacity(isOpen ? 0.8 : 1)
                    } content: {
                        ShadDropdownMenuLabel("shadcn")
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuItem("Profile", icon: .user) {}
                        ShadDropdownMenuItem("Log out", icon: .logOut, variant: .destructive) {}
                    }

                    ShadDropdownMenu(alignment: .bottomLeading) { _ in
                        ShadIconView(.moreHorizontal, size: 16)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    } content: {
                        ShadDropdownMenuItem("Copy", icon: .copy, shortcut: "⌘C") {}
                        ShadDropdownMenuItem("Duplicate", icon: .file, shortcut: "⌘D") {}
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuItem("Delete", icon: .trash, variant: .destructive, shortcut: "⌫") {}
                    }
                }
            }
        }
    }
}

// MARK: - Dialog

struct DialogPage: View {
    @State private var basic = false
    @State private var scrollable = false
    @State private var stickyFooter = false
    @State private var noClose = false
    @State private var alert = false
    @State private var destructiveAlert = false
    @State private var lastChoice = "—"
    @State private var name = "Evil Rabbit"
    @State private var username = "@evilrabbit"

    var body: some View {
        DemoPage(title: "Dialog", subtitle: "A window overlaid on the primary window, rendering the content underneath inert.") {
            DemoSection("Default", description: "The scrim blurs and darkens the app behind it. Clicking the backdrop or pressing Escape dismisses.") {
                ShadButton("Edit profile", variant: .outline) { basic = true }
            }

            DemoSection("Sticky footer", description: "The footer bar sits outside the padded body, so it stays put while the body scrolls.") {
                ShadButton("Open settings", variant: .outline) { stickyFooter = true }
            }

            DemoSection("Scrollable content", description: "A long body scrolls between a fixed header and a fixed footer.") {
                ShadButton("Open terms", variant: .outline) { scrollable = true }
            }

            DemoSection("Without a close button", description: "showsCloseButton: false, with the backdrop tap disabled, forces an explicit choice.") {
                ShadButton("Delete account", variant: .destructive) { noClose = true }
            }

            DemoSection("Alert dialog", description: "No close button, no backdrop dismissal — the only way out is one of the two actions.") {
                DemoRow {
                    ShadButton("Show alert", variant: .outline) { alert = true }
                    ShadButton("Delete account", variant: .destructive) { destructiveAlert = true }
                    ShadBadge("last choice: \(lastChoice)", variant: .secondary)
                }
            }
        }
        .shadAlertDialog(isPresented: $alert) {
            ShadAlertDialogContent {
                ShadAlertDialogTitle("Are you absolutely sure?")
                ShadAlertDialogDescription("This action cannot be undone. This will permanently delete your account and remove your data from our servers.")
            } actions: {
                ShadAlertDialogCancel("Cancel") { lastChoice = "Cancel" }
                ShadAlertDialogAction("Continue") { lastChoice = "Continue" }
            }
        }
        .shadAlertDialog(isPresented: $destructiveAlert) {
            ShadAlertDialogContent {
                ShadAlertDialogTitle("Delete this account?")
                ShadAlertDialogDescription("Everything in the workspace goes with it. This cannot be undone.")
            } actions: {
                ShadAlertDialogCancel("Keep account") { lastChoice = "Keep account" }
                ShadAlertDialogAction("Delete", variant: .destructive) { lastChoice = "Delete" }
            }
        }
        .shadDialog(isPresented: $basic) {
            ShadDialogContent(maxWidth: 440) {
                ShadDialogHeader {
                    ShadDialogTitle("Edit profile")
                    ShadDialogDescription("Make changes to your profile here. Click save when you're done.")
                }
                ShadFieldGroup(spacing: 16) {
                    ShadField {
                        ShadFieldLabel("Name")
                        ShadInput("Name", text: $name)
                    }
                    ShadField {
                        ShadFieldLabel("Username")
                        ShadInput("Username", text: $username)
                    }
                }
            } footer: {
                ShadDialogClose("Cancel")
                ShadButton("Save changes") { basic = false }
            }
        }
        .shadDialog(isPresented: $stickyFooter) {
            ShadDialogContent(maxWidth: 480) {
                ShadDialogHeader {
                    ShadDialogTitle("Notification settings")
                    ShadDialogDescription("Choose what you want to hear about.")
                }
                ShadDialogBody(maxHeight: 240) {
                    ShadFieldGroup(spacing: 12) {
                        ForEach(Self.notificationSettings, id: \.0) { title, detail in
                            ShadField(orientation: .horizontal, alignment: .top) {
                                ShadFieldContent {
                                    ShadFieldTitle(title)
                                    ShadFieldDescription(detail)
                                }
                                ShadSwitch(isOn: .constant(true))
                            }
                        }
                    }
                }
            } footer: {
                ShadDialogClose("Cancel")
                ShadButton("Save preferences") { stickyFooter = false }
            }
        }
        .shadDialog(isPresented: $scrollable) {
            ShadDialogContent(maxWidth: 520) {
                ShadDialogHeader {
                    ShadDialogTitle("Terms of service")
                    ShadDialogDescription("Please read carefully.")
                }
                ShadDialogBody(maxHeight: 260) {
                    ForEach(0..<10, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Section \(index + 1)").font(.system(size: 13, weight: .semibold))
                            Text("Nothing in these terms limits the rights you already have. This paragraph exists so the dialog has something to scroll.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } footer: {
                ShadDialogClose("Decline")
                ShadDialogClose("Accept", variant: .default)
            }
        }
        .shadDialog(isPresented: $noClose, dismissOnBackdropTap: false) {
            ShadDialogContent(maxWidth: 420, showsCloseButton: false) {
                ShadDialogHeader {
                    ShadDialogTitle("Are you absolutely sure?")
                    ShadDialogDescription("This permanently deletes your account and removes your data from our servers.")
                }
                ShadDialogFooter {
                    ShadDialogClose("Cancel")
                    ShadButton("Delete account", variant: .destructive) { noClose = false }
                }
            }
        }
    }

    static let notificationSettings: [(String, String)] = [
        ("Responses", "Get notified when someone responds to a request that takes time."),
        ("Tasks", "Get notified when tasks you've created have updates."),
        ("Mentions", "Get notified when someone mentions you in a comment."),
        ("Weekly digest", "A summary of everything that happened, every Monday."),
        ("Product news", "Occasional notes about what shipped."),
    ]
}

// MARK: - Toast

struct ToastPage: View {
    @EnvironmentObject private var toasts: ShadToastCenter

    var body: some View {
        DemoPage(title: "Toast", subtitle: "A succinct message that is displayed temporarily.") {
            DemoSection("Types", description: "Each type renders its own icon and colour.") {
                DemoRow {
                    ShadButton("Default", variant: .outline) {
                        toasts.add(title: "Event created", description: "Sunday, December 3 at 9:00 AM")
                    }
                    ShadButton("Success", variant: .outline) {
                        toasts.success("Changes saved", description: "Your profile is up to date.")
                    }
                    ShadButton("Error", variant: .outline) {
                        toasts.error("Something went wrong", description: "Could not reach the server.")
                    }
                    ShadButton("Warning", variant: .outline) {
                        toasts.warning("Storage almost full", description: "92% of 10 GB used.")
                    }
                    ShadButton("Info", variant: .outline) {
                        toasts.info("A new version is available")
                    }
                    ShadButton("Loading", variant: .outline) {
                        toasts.loading("Uploading files…")
                    }
                }
            }

            DemoSection("With an action", description: "actionTitle adds a button; tapping it closes the toast.") {
                ShadButton("Show with undo", variant: .outline) {
                    toasts.add(
                        title: "Event created",
                        description: "Sunday, December 3 at 9:00 AM",
                        actionTitle: "Undo"
                    ) {}
                }
            }

            DemoSection("Promise", description: "One toast walks through loading, then success or failure.") {
                DemoRow {
                    ShadButton("Resolve", variant: .outline) {
                        toasts.promise({
                            try await Task.sleep(nanoseconds: 1_400_000_000)
                            return "sonner.zip"
                        }, loading: "Uploading…", success: { "Uploaded \($0)" }, failure: { _ in "Upload failed" })
                    }
                    ShadButton("Reject", variant: .outline) {
                        toasts.promise({
                            try await Task.sleep(nanoseconds: 1_200_000_000)
                            throw DemoError.failed
                        }, loading: "Deploying…", success: { (_: String) in "Deployed" }, failure: { _ in "Deploy failed" })
                    }
                }
            }

            DemoSection("Stacking", description: "Toasts stack, expand on hover, and can be swiped away.") {
                DemoRow {
                    ShadButton("Add three", variant: .outline) {
                        toasts.success("First")
                        toasts.info("Second")
                        toasts.warning("Third")
                    }
                    ShadButton("Dismiss all", variant: .ghost) { toasts.closeAll() }
                }
            }
        }
    }
}

enum DemoError: Error { case failed }
