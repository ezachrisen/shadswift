import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var overlays: [DocComponent] {
        [select, combobox, dropdown, dialog, alertDialog, toast]
    }

    // MARK: - Alert dialog

    static var alertDialog: DocComponent {
        DocComponent(
            slug: "alert-dialog",
            title: "Alert Dialog",
            summary: "A modal dialog that interrupts the user with important content and expects a response.",
            group: "Overlays",
            anatomy: #"""
            .shadAlertDialog(isPresented:) {
                ShadAlertDialogContent
                ├── ShadAlertDialogTitle
                ├── ShadAlertDialogDescription
                └── actions:
                    ├── ShadAlertDialogCancel
                    └── ShadAlertDialogAction
            }
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "No close button and no backdrop dismissal — the only way out is one of the two actions.",
                    width: 640,
                    code: #"""
                    ContentView()
                        .shadAlertDialog(isPresented: $isConfirming) {
                            ShadAlertDialogContent {
                                ShadAlertDialogTitle("Are you absolutely sure?")
                                ShadAlertDialogDescription(
                                    "This action cannot be undone. This will permanently "
                                    + "delete your account and remove your data from our servers."
                                )
                            } actions: {
                                ShadAlertDialogCancel("Cancel")
                                ShadAlertDialogAction("Continue") { proceed() }
                            }
                        }
                    """#
                ) {
                    ShadAlertDialogContent {
                        ShadAlertDialogTitle("Are you absolutely sure?")
                        ShadAlertDialogDescription("This action cannot be undone. This will permanently delete your account and remove your data from our servers.")
                    } actions: {
                        ShadAlertDialogCancel("Cancel")
                        ShadAlertDialogAction("Continue") {}
                    }
                },

                DocExample(
                    "Destructive",
                    description: "Pass variant: .destructive to the action when the outcome is irreversible.",
                    width: 640,
                    code: #"""
                    ShadAlertDialogCancel("Keep account")
                    ShadAlertDialogAction("Delete", variant: .destructive) { delete() }
                    """#
                ) {
                    ShadAlertDialogContent {
                        ShadAlertDialogTitle("Delete this account?")
                        ShadAlertDialogDescription("Everything in the workspace goes with it. This cannot be undone.")
                    } actions: {
                        ShadAlertDialogCancel("Keep account")
                        ShadAlertDialogAction("Delete", variant: .destructive) {}
                    }
                },
            ],
            notes: [
                "Both actions close the alert by default; pass dismissesOnTap: false to keep it open while work is in flight.",
                "The scrim blurs and lightly darkens the app rather than blanking it out.",
            ],
            api: [
                DocAPI("View.shadAlertDialog(isPresented:content:)", [
                    DocProperty("isPresented", "Binding<Bool>", "Drives the presentation."),
                ]),
                DocAPI("ShadAlertDialogContent", [
                    DocProperty("maxWidth", "CGFloat", default: "448", "Panel width cap."),
                    DocProperty("actions", "() -> View", "The right-aligned action row."),
                ]),
                DocAPI("ShadAlertDialogAction", [
                    DocProperty("variant", "ShadButtonVariant", default: ".default", "Use .destructive for deletions."),
                    DocProperty("dismissesOnTap", "Bool", default: "true", "Close the alert after acting."),
                ]),
            ]
        )
    }

    // MARK: - Select

    static var select: DocComponent {
        DocComponent(
            slug: "select",
            title: "Select",
            summary: "Displays a list of options for the user to pick from, triggered by a button.",
            group: "Overlays",
            anatomy: #"""
            ShadSelect(selection:options:)          // flat list
            ShadSelect(selection:sections:)         // grouped list

            ShadSelectSection("North America", options: [
                ShadSelectOption("Eastern Standard Time (EST)", value: "est"),
            ])
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "The panel opens over the trigger with the selected row sitting on top of it — the way a shadcn Select, and a macOS pop-up button, has always behaved. The chevron does not flip.",
                    code: #"""
                    @State private var theme: String?

                    ShadSelect(selection: $theme, options: [
                        ShadSelectOption("Light", value: "light", icon: .eye),
                        ShadSelectOption("Dark", value: "dark", icon: .eyeOff),
                        ShadSelectOption("System", value: "system", icon: .settings),
                    ], placeholder: "Theme", width: 220)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadSelect(selection: .constant(nil), options: [
                            ShadSelectOption("Light", value: "light", icon: .eye),
                        ], placeholder: "Theme", width: 220)

                        DocMenuPreview(width: 200) {
                            ShadMenuRow(title: "Light", isHighlighted: true) {
                                ShadIconView(.eye, size: 16)
                            } trailing: {
                                EmptyView()
                            }
                            ShadMenuRow(title: "Dark") {
                                ShadIconView(.eyeOff, size: 16)
                            } trailing: {
                                EmptyView()
                            }
                            ShadMenuRow(title: "System") {
                                ShadIconView(.settings, size: 16)
                            } trailing: {
                                ShadIconView(.check, size: 14, weight: .bold)
                            }
                        }
                    }
                },

                DocExample(
                    "States",
                    description: "Select is a single size — 32pt with a 14pt label — as shadcn's is. A shorter trigger would drop below the type size the panel rows use, and the label would change size as the menu opened.",
                    code: #"""
                    ShadSelect(selection: $fruit, options: fruit, width: 180)
                    ShadSelect(selection: $fruit, options: fruit, isInvalid: true, width: 180)
                    ShadSelect(selection: $fruit, options: fruit, width: 180).disabled(true)
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadSelect(selection: .constant("apple"), options: fruitOptions, placeholder: "Default", width: 170)
                        ShadSelect(selection: .constant(nil), options: fruitOptions, placeholder: "Invalid", isInvalid: true, width: 170)
                        ShadSelect(selection: .constant(nil), options: fruitOptions, placeholder: "Disabled", width: 170).disabled(true)
                    }
                },

                DocExample(
                    "Grouped",
                    description: "Sections get a heading and a separator, and the panel scrolls past 384pt.",
                    code: #"""
                    ShadSelect(selection: $timezone, sections: [
                        ShadSelectSection("North America", options: [
                            ShadSelectOption("Eastern Standard Time (EST)", value: "est"),
                            ShadSelectOption("Central Standard Time (CST)", value: "cst"),
                        ]),
                        ShadSelectSection("Europe", options: [
                            ShadSelectOption("Greenwich Mean Time (GMT)", value: "gmt"),
                        ]),
                    ], placeholder: "Select a timezone", width: 280)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadSelect(selection: .constant(nil), sections: DocSamples.timezones, placeholder: "Select a timezone", width: 240)
                        DocMenuPreview(width: 240) {
                            ShadMenuLabel("North America")
                            ShadMenuRow(title: "Eastern Standard Time (EST)", isHighlighted: true)
                            ShadMenuRow(title: "Central Standard Time (CST)")
                            ShadSeparator().padding(.vertical, 4)
                            ShadMenuLabel("Europe")
                            ShadMenuRow(title: "Greenwich Mean Time (GMT)")
                        }
                    }
                },

                DocExample(
                    "Disabled options",
                    code: #"""
                    ShadSelectOption("Sold out", value: "b", isDisabled: true)
                    """#
                ) {
                    DocMenuPreview(width: 200) {
                        ShadMenuRow(title: "Available")
                        ShadMenuRow(title: "Sold out", isDisabled: true)
                        ShadMenuRow(title: "Available")
                    }
                },
            ],
            notes: [
                "There is one size. The trigger and the panel rows share the same 14pt type, and a row is centred on the trigger, so the label does not move as the menu opens.",
                "The panel overlays the trigger rather than dropping below it, and the chevron stays pointing down.",
                "↑ and ↓ move the highlight, Home and End jump to the ends, Return selects, Escape closes.",
                "Panels are NSPanel child windows, which is what lets them escape the app window's bounds.",
                "Menus are framed by a hairline and carry no shadow, matching shadcn's ring-1 ring-foreground/10.",
            ],
            api: [
                DocAPI("ShadSelect", [
                    DocProperty("selection", "Binding<Value?>", "Any Hashable value."),
                    DocProperty("options / sections", "[ShadSelectOption] / [ShadSelectSection]", "Flat or grouped."),
                    DocProperty("placeholder", "String", default: "\"Select…\"", "Shown when nothing is selected."),
                    DocProperty("isInvalid", "Bool", default: "false", "Destructive border and ring."),
                    DocProperty("width", "CGFloat?", default: "nil", "Trigger width; the panel matches it."),
                    DocProperty("isOpen", "Binding<Bool>?", default: "nil", "Controlled open state."),
                ]),
                DocAPI("ShadSelectOption", [
                    DocProperty("label", "String", "Row text."),
                    DocProperty("value", "Value", "The selected value."),
                    DocProperty("description", "String?", default: "nil", "Secondary line."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon."),
                    DocProperty("isDisabled", "Bool", default: "false", "Unselectable."),
                    DocProperty("keywords", "[String]", default: "[]", "Extra terms matched when filtering a combobox."),
                ]),
            ]
        )
    }

    // MARK: - Combobox

    static var combobox: DocComponent {
        DocComponent(
            slug: "combobox",
            title: "Combobox",
            summary: "An autocomplete input with a list of suggestions.",
            group: "Overlays",
            examples: [
                DocExample(
                    "Single selection",
                    description: "The text field is the trigger. Type to filter; ↑ ↓ move the highlight and ⏎ selects.",
                    code: #"""
                    @State private var framework: String?

                    ShadCombobox(selection: $framework,
                                 options: frameworks,
                                 placeholder: "Select framework…",
                                 width: 280)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadCombobox(selection: .constant(nil), options: DocSamples.frameworks, placeholder: "Select framework…", width: 250)
                        DocMenuPreview(width: 230) {
                            ShadMenuRow(title: "Next.js", isHighlighted: true)
                            ShadMenuRow(title: "SvelteKit")
                            ShadMenuRow(title: "Nuxt.js")
                            ShadMenuRow(title: "Remix")
                            ShadMenuRow(title: "Astro")
                        }
                    }
                },

                DocExample(
                    "Clear button and a leading icon",
                    code: #"""
                    ShadCombobox(selection: $framework,
                                 options: frameworks,
                                 placeholder: "Search frameworks…",
                                 showsClear: true,
                                 icon: .search,
                                 width: 280)
                    """#
                ) {
                    ShadCombobox(
                        selection: .constant(nil),
                        options: DocSamples.frameworks,
                        placeholder: "Search frameworks…",
                        showsClear: true,
                        icon: .search,
                        width: 280
                    )
                },

                DocExample(
                    "Grouped, with keywords",
                    description: "Options can match extra terms, which is how you filter objects by more than their label.",
                    code: #"""
                    ShadSelectSection("Backend", options: [
                        ShadSelectOption("Vapor", value: "vapor", keywords: ["swift"]),
                        ShadSelectOption("Django", value: "django", keywords: ["python"]),
                    ])
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadCombobox(selection: .constant(nil), sections: [
                            ShadSelectSection("Frontend", options: [ShadSelectOption("React", value: "react")]),
                        ], placeholder: "Search stacks…", width: 240)
                        DocMenuPreview(width: 220) {
                            ShadMenuLabel("Frontend")
                            ShadMenuRow(title: "React", isHighlighted: true)
                            ShadMenuRow(title: "Vue")
                            ShadSeparator().padding(.vertical, 4)
                            ShadMenuLabel("Backend")
                            ShadMenuRow(title: "Vapor")
                            ShadMenuRow(title: "Django")
                        }
                    }
                },

                DocExample(
                    "Multiple selection",
                    description: "Selections become chips that wrap inside the control.",
                    code: #"""
                    @State private var selected: Set<String> = ["next"]

                    ShadComboboxMultiple(selection: $selected,
                                         options: frameworks,
                                         placeholder: "Add frameworks…",
                                         width: 380)
                    """#
                ) {
                    ShadComboboxMultiple(
                        selection: .constant(["next", "astro"]),
                        options: DocSamples.frameworks,
                        placeholder: "Add frameworks…",
                        width: 380
                    )
                },

                DocExample(
                    "Popup trigger",
                    description: "A button opens a panel with the search field inside it — shadcn's render={<Button/>} example.",
                    code: #"""
                    ShadComboboxButton(selection: $framework,
                                       options: frameworks,
                                       placeholder: "Select framework…",
                                       searchPlaceholder: "Search framework…",
                                       width: 260)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadComboboxButton(selection: .constant(nil), options: DocSamples.frameworks, width: 240)
                        ShadPopoverSurface(padding: 0) {
                            VStack(spacing: 0) {
                                ShadComboboxSearchField(text: .constant(""), placeholder: "Search framework…")
                                ShadSeparator()
                                VStack(alignment: .leading, spacing: 2) {
                                    ShadMenuRow(title: "Next.js", isHighlighted: true)
                                    ShadMenuRow(title: "SvelteKit")
                                    ShadMenuRow(title: "Remix")
                                }
                                .padding(4)
                            }
                            .frame(width: 240)
                        }
                        .fixedSize()
                    }
                },
            ],
            notes: [
                "ShadComboboxButton's panel takes key focus so its search field can accept typing; the other flavours keep focus in the trigger.",
            ],
            api: [
                DocAPI("ShadCombobox", [
                    DocProperty("selection", "Binding<Value?>", "The chosen value."),
                    DocProperty("options / sections", "[ShadSelectOption] / [ShadSelectSection]", "Flat or grouped."),
                    DocProperty("showsClear", "Bool", default: "false", "Adds a clear button once there is text."),
                    DocProperty("autoHighlight", "Bool", default: "true", "Highlights the first match while typing."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon inside the input."),
                    DocProperty("emptyMessage", "String", default: "\"No results found.\"", "Shown when nothing matches."),
                ]),
                DocAPI("ShadComboboxMultiple", [
                    DocProperty("selection", "Binding<Set<Value>>", "The chosen values, rendered as chips."),
                ]),
                DocAPI("ShadComboboxButton", [
                    DocProperty("searchPlaceholder", "String", default: "\"Search…\"", "Prompt for the field inside the panel."),
                ]),
            ]
        )
    }

    // MARK: - Dropdown menu

    static var dropdown: DocComponent {
        DocComponent(
            slug: "dropdown-menu",
            title: "Dropdown Menu",
            summary: "Displays a menu to the user — a set of actions or functions — triggered by a button.",
            group: "Overlays",
            anatomy: #"""
            ShadDropdownMenu
            ├── ShadDropdownMenuLabel
            ├── ShadDropdownMenuSeparator
            ├── ShadDropdownMenuGroup
            │   └── ShadDropdownMenuItem
            ├── ShadDropdownMenuCheckboxItem
            ├── ShadDropdownMenuRadioGroup
            │   └── ShadDropdownMenuRadioItem
            └── ShadDropdownMenuSub
                └── ShadDropdownMenuItem
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "Labels, separators, keyboard-shortcut hints, a submenu and a destructive row.",
                    code: #"""
                    ShadDropdownMenu("Open", minWidth: 200) {
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
                        }
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuItem("Log out", icon: .logOut,
                                             variant: .destructive, shortcut: "⇧⌘Q") {}
                    }
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadDropdownMenu("Open") {
                            ShadDropdownMenuItem("Profile") {}
                        }
                        DocMenuPreview(width: 210) {
                            ShadMenuLabel("My Account")
                            ShadSeparator().padding(.vertical, 4)
                            ShadMenuRow(title: "Profile", isHighlighted: true, isInset: true) {
                                ShadIconView(.user, size: 16)
                            } trailing: {
                                ShadMenuShortcut("⇧⌘P")
                            }
                            ShadMenuRow(title: "Billing", isInset: true) {
                                ShadIconView(.creditCard, size: 16)
                            } trailing: {
                                ShadMenuShortcut("⌘B")
                            }
                            ShadMenuRow(title: "Settings", isInset: true) {
                                ShadIconView(.settings, size: 16)
                            } trailing: {
                                ShadMenuShortcut("⌘S")
                            }
                            ShadSeparator().padding(.vertical, 4)
                            ShadMenuRow(title: "Invite users", isInset: true) {
                                ShadIconView(.users, size: 16)
                            } trailing: {
                                ShadIconView(.chevronRight, size: 14)
                            }
                            ShadSeparator().padding(.vertical, 4)
                            ShadMenuRow(title: "Log out", variant: .destructive, isInset: true) {
                                ShadIconView(.logOut, size: 16)
                            } trailing: {
                                ShadMenuShortcut("⇧⌘Q")
                            }
                        }
                    }
                },

                DocExample(
                    "Checkbox items",
                    description: "Rows that toggle without closing the menu.",
                    code: #"""
                    ShadDropdownMenu("Appearance", variant: .outline) {
                        ShadDropdownMenuLabel("Appearance")
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuCheckboxItem("Status Bar", isOn: $statusBar)
                        ShadDropdownMenuCheckboxItem("Activity Bar", isOn: $activityBar)
                        ShadDropdownMenuCheckboxItem("Panel", isOn: $panel)
                    }
                    """#
                ) {
                    DocMenuPreview(width: 200) {
                        ShadMenuLabel("Appearance")
                        ShadSeparator().padding(.vertical, 4)
                        ShadMenuRow(title: "Status Bar", isInset: true) {
                            ShadIconView(.check, size: 14, weight: .bold)
                        } trailing: {
                            EmptyView()
                        }
                        ShadMenuRow(title: "Activity Bar", isInset: true) {
                            Color.clear.frame(width: 14, height: 14)
                        } trailing: {
                            EmptyView()
                        }
                        ShadMenuRow(title: "Panel", isInset: true) {
                            Color.clear.frame(width: 14, height: 14)
                        } trailing: {
                            EmptyView()
                        }
                    }
                },

                DocExample(
                    "Radio group",
                    description: "Mutually exclusive rows bound to one value.",
                    code: #"""
                    ShadDropdownMenu("Panel position", variant: .secondary) {
                        ShadDropdownMenuRadioGroup(selection: $position) {
                            ShadDropdownMenuRadioItem("Top", value: "top")
                            ShadDropdownMenuRadioItem("Bottom", value: "bottom")
                            ShadDropdownMenuRadioItem("Right", value: "right")
                        }
                    }
                    """#
                ) {
                    DocMenuPreview(width: 180) {
                        ShadMenuLabel("Panel position")
                        ShadSeparator().padding(.vertical, 4)
                        ShadMenuRow(title: "Top", isHighlighted: true) {
                            EmptyView()
                        } trailing: {
                            ShadIconView(.check, size: 14)
                        }
                        ShadMenuRow(title: "Bottom")
                        ShadMenuRow(title: "Right")
                    }
                },

                DocExample(
                    "Custom triggers",
                    description: "The trigger closure receives the open state, so it can react to it.",
                    code: #"""
                    ShadDropdownMenu(alignment: .bottomTrailing) { isOpen in
                        ShadAvatar(fallback: "CN", size: .lg)
                            .opacity(isOpen ? 0.8 : 1)
                    } content: {
                        ShadDropdownMenuLabel("shadcn")
                        ShadDropdownMenuSeparator()
                        ShadDropdownMenuItem("Profile", icon: .user) {}
                        ShadDropdownMenuItem("Log out", icon: .logOut,
                                             variant: .destructive) {}
                    }
                    """#
                ) {
                    HStack(spacing: 20) {
                        ShadDropdownMenu { _ in
                            ShadAvatar(fallback: "CN", size: .lg)
                        } content: {
                            ShadDropdownMenuItem("Profile") {}
                        }
                        ShadDropdownMenu { _ in
                            ShadIconView(.moreHorizontal, size: 16)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        } content: {
                            ShadDropdownMenuItem("Copy") {}
                        }
                        ShadDropdownMenu("Actions", variant: .secondary, icon: .zap) {
                            ShadDropdownMenuItem("Run") {}
                        }
                    }
                },
            ],
            notes: [
                "The trigger is a plain button with no chevron, and clicking it again closes the menu.",
                "A submenu opens on hover as well as on click, and hovering any sibling row closes it again — only one submenu is ever open.",
                "Clicks inside a submenu never dismiss the parent.",
            ],
            api: [
                DocAPI("ShadDropdownMenu", [
                    DocProperty("title", "String", "Convenience initialiser: renders a shadcn button as the trigger."),
                    DocProperty("trigger", "(Bool) -> View", "Custom trigger; the Bool is the open state."),
                    DocProperty("isOpen", "Binding<Bool>?", default: "nil", "Controlled open state."),
                    DocProperty("alignment", "ShadPopoverAlignment", default: ".bottomLeading", "Where the panel sits."),
                    DocProperty("minWidth", "CGFloat", default: "176", "Minimum panel width."),
                ]),
                DocAPI("ShadDropdownMenuItem", [
                    DocProperty("variant", "ShadMenuItemVariant", default: ".default", "default or destructive."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon."),
                    DocProperty("shortcut", "String", "Keyboard hint on the right."),
                    DocProperty("isInset", "Bool", default: "false", "Aligns with rows that have icons."),
                    DocProperty("dismissesMenu", "Bool", default: "true", "Close the menu after acting."),
                ]),
            ]
        )
    }

    // MARK: - Dialog

    static var dialog: DocComponent {
        DocComponent(
            slug: "dialog",
            title: "Dialog",
            summary: "A window overlaid on the primary window, rendering the content underneath inert.",
            group: "Overlays",
            anatomy: #"""
            .shadDialog(isPresented:) {
                ShadDialogContent
                ├── ShadDialogHeader
                │   ├── ShadDialogTitle
                │   └── ShadDialogDescription
                ├── ShadDialogBody          // optional, scrolls
                └── ShadDialogFooter
                    └── ShadDialogClose
            }
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "Attach the modifier to the root of your window so the scrim covers everything. Clicking the backdrop or pressing Escape dismisses.",
                    width: 640,
                    code: #"""
                    ContentView()
                        .shadDialog(isPresented: $isEditing) {
                            ShadDialogContent {
                                ShadDialogHeader {
                                    ShadDialogTitle("Edit profile")
                                    ShadDialogDescription("Make changes to your profile here.")
                                }
                                ShadFieldGroup(spacing: 14) {
                                    ShadField {
                                        ShadFieldLabel("Name")
                                        ShadInput("Name", text: $name)
                                    }
                                }
                                ShadDialogFooter {
                                    ShadDialogClose("Cancel")
                                    ShadButton("Save changes") { save() }
                                }
                            }
                        }
                    """#
                ) {
                    ShadDialogContent {
                        ShadDialogHeader {
                            ShadDialogTitle("Edit profile")
                            ShadDialogDescription("Make changes to your profile here. Click save when you're done.")
                        }
                        ShadFieldGroup(spacing: 14) {
                            ShadField {
                                ShadFieldLabel("Name")
                                ShadInput("Name", text: .constant("Evil Rabbit"))
                            }
                            ShadField {
                                ShadFieldLabel("Username")
                                ShadInput("Username", text: .constant("@evilrabbit"))
                            }
                        }
                        ShadDialogFooter {
                            ShadDialogClose("Cancel")
                            ShadButton("Save changes") {}
                        }
                    }
                },

                DocExample(
                    "Footer bar",
                    description: "Pass the footer: slot and it becomes a muted strip running the full width of the panel, separated by a rule. It stays put while the body scrolls.",
                    width: 640,
                    code: #"""
                    ShadDialogContent(maxWidth: 440) {
                        ShadDialogHeader {
                            ShadDialogTitle("Edit profile")
                            ShadDialogDescription("Make changes to your profile here.")
                        }
                        ShadFieldGroup(spacing: 16) { … }
                    } footer: {
                        ShadDialogClose("Cancel")
                        ShadButton("Save changes") { save() }
                    }
                    """#
                ) {
                    ShadDialogContent(maxWidth: 440) {
                        ShadDialogHeader {
                            ShadDialogTitle("Edit profile")
                            ShadDialogDescription("Make changes to your profile here. Click save when you're done.")
                        }
                        ShadFieldGroup(spacing: 16) {
                            ShadField {
                                ShadFieldLabel("Name")
                                ShadInput("Name", text: .constant("Evil Rabbit"))
                            }
                            ShadField {
                                ShadFieldLabel("Username")
                                ShadInput("Username", text: .constant("@evilrabbit"))
                            }
                        }
                    } footer: {
                        ShadDialogClose("Cancel")
                        ShadButton("Save changes") {}
                    }
                },

                DocExample(
                    "Scrollable body",
                    description: "ShadDialogBody scrolls while the header and footer stay put.",
                    width: 640,
                    code: #"""
                    ShadDialogContent(maxWidth: 560) {
                        ShadDialogHeader {
                            ShadDialogTitle("Terms of service")
                            ShadDialogDescription("Please read carefully.")
                        }
                        ShadDialogBody(maxHeight: 280) {
                            ForEach(sections) { section in … }
                        }
                        ShadDialogFooter {
                            ShadDialogClose("Decline")
                            ShadDialogClose("Accept", variant: .default)
                        }
                    }
                    """#
                ) {
                    ShadDialogContent(maxWidth: 520) {
                        ShadDialogHeader {
                            ShadDialogTitle("Terms of service")
                            ShadDialogDescription("Please read carefully.")
                        }
                        ShadDialogBody(maxHeight: 150) {
                            ForEach(0..<3, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Section \(index + 1)").font(.system(size: 13, weight: .semibold))
                                    Text("Nothing in these terms limits the rights you already have.")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        ShadDialogFooter {
                            ShadDialogClose("Decline")
                            ShadDialogClose("Accept", variant: .default)
                        }
                    }
                },

                DocExample(
                    "Without a close button",
                    description: "showsCloseButton: false, plus dismissOnBackdropTap: false, forces an explicit choice.",
                    width: 640,
                    code: #"""
                    .shadDialog(isPresented: $confirming, dismissOnBackdropTap: false) {
                        ShadDialogContent(maxWidth: 420, showsCloseButton: false) {
                            ShadDialogHeader {
                                ShadDialogTitle("Are you absolutely sure?")
                                ShadDialogDescription("This permanently deletes your account.")
                            }
                            ShadDialogFooter {
                                ShadDialogClose("Cancel")
                                ShadButton("Delete account", variant: .destructive) { delete() }
                            }
                        }
                    }
                    """#
                ) {
                    ShadDialogContent(maxWidth: 420, showsCloseButton: false) {
                        ShadDialogHeader {
                            ShadDialogTitle("Are you absolutely sure?")
                            ShadDialogDescription("This permanently deletes your account and removes your data from our servers.")
                        }
                        ShadDialogFooter {
                            ShadDialogClose("Cancel")
                            ShadButton("Delete account", variant: .destructive) {}
                        }
                    }
                },
            ],
            notes: [
                "The scrim blurs and darkens what is behind it, so the app reads as inert.",
                "Any view below the dialog can close it with @Environment(\\.shadDialogDismiss).",
            ],
            api: [
                DocAPI("View.shadDialog(isPresented:dismissOnBackdropTap:content:)", [
                    DocProperty("isPresented", "Binding<Bool>", "Drives the presentation."),
                    DocProperty("dismissOnBackdropTap", "Bool", default: "true", "Whether clicking the scrim closes it."),
                ]),
                DocAPI("ShadDialogContent", [
                    DocProperty("maxWidth", "CGFloat", default: "512", "Matches shadcn's max-w-lg."),
                    DocProperty("showsCloseButton", "Bool", default: "true", "The × in the top-right."),
                ]),
                DocAPI("ShadDialogClose", [
                    DocProperty("title", "String", "Renders a shadcn button that closes the dialog."),
                    DocProperty("action", "() -> Void", default: "{}", "Runs before dismissing."),
                ]),
            ]
        )
    }

    // MARK: - Toast

    static var toast: DocComponent {
        DocComponent(
            slug: "toast",
            title: "Toast",
            summary: "A succinct message that is displayed temporarily.",
            group: "Overlays",
            examples: [
                DocExample(
                    "Setup",
                    description: "Own a centre, attach the toaster once at the root, then post from anywhere.",
                    code: #"""
                    @StateObject private var toasts = ShadToastCenter()

                    var body: some View {
                        ContentView()
                            .shadToaster(toasts, position: .bottomTrailing)
                            .environmentObject(toasts)
                    }

                    // Later, anywhere below:
                    toasts.success("Event created",
                                   description: "Sunday, December 3 at 9:00 AM")
                    """#
                ),

                DocExample(
                    "Types",
                    description: "Each type renders its own icon and colour.",
                    width: 800,
                    code: #"""
                    toasts.add(title: "Event created",
                               description: "Sunday, December 3 at 9:00 AM")
                    toasts.success("Changes saved", description: "Your profile is up to date.")
                    toasts.error("Something went wrong", description: "Could not reach the server.")
                    toasts.warning("Storage almost full", description: "92% of 10 GB used.")
                    toasts.info("A new version is available")
                    toasts.loading("Uploading files…")
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        ShadToastView(toast: ShadToast(title: "Event created", description: "Sunday, December 3 at 9:00 AM"), onClose: {})
                        ShadToastView(toast: ShadToast(title: "Changes saved", description: "Your profile is up to date.", type: .success), onClose: {})
                        ShadToastView(toast: ShadToast(title: "Something went wrong", description: "Could not reach the server.", type: .error), onClose: {})
                        ShadToastView(toast: ShadToast(title: "Storage almost full", description: "92% of 10 GB used.", type: .warning), onClose: {})
                        ShadToastView(toast: ShadToast(title: "A new version is available", type: .info), onClose: {})
                        ShadToastView(toast: ShadToast(title: "Uploading files…", type: .loading), onClose: {})
                    }
                },

                DocExample(
                    "With an action",
                    description: "actionTitle adds a button; running it closes the toast.",
                    width: 480,
                    code: #"""
                    toasts.add(
                        title: "Event created",
                        description: "Sunday, December 3 at 9:00 AM",
                        actionTitle: "Undo"
                    ) {
                        undo()
                    }
                    """#
                ) {
                    ShadToastView(
                        toast: ShadToast(
                            title: "Event created",
                            description: "Sunday, December 3 at 9:00 AM",
                            actionTitle: "Undo",
                            actionHandler: {}
                        ),
                        onClose: {}
                    )
                },

                DocExample(
                    "Promise",
                    description: "One toast walks through loading, then success or failure.",
                    code: #"""
                    toasts.promise({
                        try await upload(file)
                    }, loading: "Uploading…",
                       success: { "Uploaded \($0)" },
                       failure: { _ in "Upload failed" })
                    """#
                ),
            ],
            notes: [
                "The close button is always present, next to any action — it does not wait for a hover.",
                "Hovering the stack pauses auto-dismissal; moving away resumes it.",
                "Toasts can be swiped away horizontally.",
            ],
            api: [
                DocAPI("ShadToastCenter", [
                    DocProperty("add(title:description:type:duration:actionTitle:action:)", "UUID", "Posts a toast and returns its id."),
                    DocProperty("success / error / warning / info / loading", "UUID", "Typed shorthands."),
                    DocProperty("update(_:title:description:type:duration:)", "Void", "Mutates a live toast."),
                    DocProperty("promise(_:loading:success:failure:)", "UUID", "Drives one toast through an async call."),
                    DocProperty("close(_:) / closeAll()", "Void", "Dismissal."),
                    DocProperty("limit", "Int", default: "3", "Most toasts on screen at once."),
                    DocProperty("defaultDuration", "TimeInterval", default: "4", "Seconds before auto-dismissal."),
                ]),
                DocAPI("View.shadToaster(_:position:expandsOnHover:)", [
                    DocProperty("position", "ShadToastPosition", default: ".bottomTrailing", "Six corners and edges."),
                    DocProperty("expandsOnHover", "Bool", default: "true", "Fans the stack out under the pointer."),
                ]),
            ]
        )
    }

    // MARK: - Helpers

    static var fruitOptions: [ShadSelectOption<String>] {
        [
            ShadSelectOption("Apple", value: "apple"),
            ShadSelectOption("Banana", value: "banana"),
            ShadSelectOption("Blueberry", value: "blueberry"),
        ]
    }
}
