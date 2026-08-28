import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var controls: [DocComponent] {
        [switchComponent, checkbox, radioGroup, slider, tabs]
    }

    // MARK: - Radio group

    static var radioGroup: DocComponent {
        DocComponent(
            slug: "radio-group",
            title: "Radio Group",
            summary: "A set of checkable buttons where no more than one may be checked at a time.",
            group: "Controls",
            anatomy: #"""
            ShadRadioGroup(selection:)
            ├── ShadRadio            // circle + label (+ optional description)
            ├── ShadRadioCard        // the bordered choice-card treatment
            └── ShadRadioGroupItem   // the bare circle, for custom rows
            """#,
            examples: [
                DocExample(
                    "Default",
                    code: #"""
                    @State private var density: Density = .comfortable

                    ShadRadioGroup(selection: $density) {
                        ShadRadio("Default", value: Density.default)
                        ShadRadio("Comfortable", value: Density.comfortable)
                        ShadRadio("Compact", value: Density.compact)
                    }
                    """#
                ) {
                    ShadRadioGroup(selection: .constant(DocDensity.comfortable)) {
                        ShadRadio("Default", value: DocDensity.default)
                        ShadRadio("Comfortable", value: DocDensity.comfortable)
                        ShadRadio("Compact", value: DocDensity.compact)
                    }
                    .frame(width: 320)
                },

                DocExample(
                    "With descriptions",
                    description: "The description sits beside the circle, aligned with the label.",
                    width: 620,
                    code: #"""
                    ShadRadio("Pro",
                              description: "For teams shipping to production.",
                              value: Plan.pro)
                    """#
                ) {
                    ShadRadioGroup(selection: .constant("pro")) {
                        ShadRadio("Starter", description: "For hobby projects and prototypes.", value: "starter")
                        ShadRadio("Pro", description: "For teams shipping to production.", value: "pro")
                        ShadRadio("Enterprise", description: "SSO, audit logs and a dedicated contact.", value: "enterprise")
                    }
                    .frame(width: 440)
                },

                DocExample(
                    "Choice cards",
                    description: "The whole card is the control; a selected card tints from primary.",
                    width: 620,
                    code: #"""
                    ShadFieldSet {
                        ShadFieldLegend("Compute Environment")
                        ShadFieldDescription("Select the compute environment for your cluster.")
                        ShadRadioGroup(selection: $compute) {
                            ShadRadioCard("Kubernetes",
                                          description: "Run GPU workloads on a K8s cluster.",
                                          value: Compute.kubernetes)
                            ShadRadioCard("Virtual Machine",
                                          description: "Access a cluster to run GPU workloads.",
                                          value: Compute.virtualMachine)
                        }
                    }
                    """#
                ) {
                    ShadFieldSet {
                        ShadFieldLegend("Compute Environment")
                        ShadFieldDescription("Select the compute environment for your cluster.")
                        ShadRadioGroup(selection: .constant("k8s")) {
                            ShadRadioCard("Kubernetes", description: "Run GPU workloads on a K8s cluster.", value: "k8s")
                            ShadRadioCard("Virtual Machine", description: "Access a cluster to run GPU workloads.", value: "vm")
                        }
                    }
                    .frame(width: 440)
                },

                DocExample(
                    "States",
                    code: #"""
                    ShadRadioGroup(selection: $value) { … }.disabled(true)
                    ShadRadio("Yes", value: "yes", isInvalid: true)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 48) {
                        labelled("disabled") {
                            ShadRadioGroup(selection: .constant(DocDensity.default)) {
                                ShadRadio("Default", value: DocDensity.default)
                                ShadRadio("Compact", value: DocDensity.compact)
                            }
                            .disabled(true)
                            .frame(width: 150)
                        }
                        labelled("invalid") {
                            ShadRadioGroup(selection: .constant("")) {
                                ShadRadio("Yes", value: "yes", isInvalid: true)
                                ShadRadio("No", value: "no", isInvalid: true)
                            }
                            .frame(width: 150)
                        }
                    }
                },
            ],
            notes: [
                "The circle is 16pt with an 8pt dot, matching shadcn's size-4 item and size-2 indicator.",
                "An invalid item keeps its destructive halo whether or not it has focus.",
            ],
            api: [
                DocAPI("ShadRadioGroup", [
                    DocProperty("selection", "Binding<Value?>", "Any Hashable value; a non-optional overload is also available."),
                    DocProperty("spacing", "CGFloat", default: "12", "Gap between rows."),
                ]),
                DocAPI("ShadRadio", [
                    DocProperty("title", "String", "Row label."),
                    DocProperty("description", "String?", default: "nil", "Sits beside the circle, under the label."),
                    DocProperty("value", "Value", "The value this row selects."),
                    DocProperty("isInvalid", "Bool", default: "false", "Destructive border and halo."),
                ]),
                DocAPI("ShadRadioCard", [
                    DocProperty("title / description / value", "…", "As above, in the bordered card treatment."),
                ]),
            ]
        )
    }

    enum DocDensity: Hashable { case `default`, comfortable, compact }

    // MARK: - Switch

    static var switchComponent: DocComponent {
        DocComponent(
            slug: "switch",
            title: "Switch",
            summary: "A control that allows the user to toggle between checked and not checked.",
            group: "Controls",
            examples: [
                DocExample(
                    "Sizes and states",
                    code: #"""
                    ShadSwitch(isOn: $isOn)
                    ShadSwitch(isOn: $isOn, size: .sm)
                    ShadSwitch(isOn: $isOn).disabled(true)
                    ShadSwitch(isOn: $isOn, isInvalid: true)
                    """#
                ) {
                    HStack(spacing: 34) {
                        labelled("default") { ShadSwitch(isOn: .constant(true)) }
                        labelled("sm") { ShadSwitch(isOn: .constant(true), size: .sm) }
                        labelled("off") { ShadSwitch(isOn: .constant(false)) }
                        labelled("disabled") { ShadSwitch(isOn: .constant(true)).disabled(true) }
                        labelled("invalid") { ShadSwitch(isOn: .constant(false), isInvalid: true) }
                    }
                },

                DocExample(
                    "With a label",
                    description: "Pass a title and the whole row becomes the hit target.",
                    code: #"""
                    ShadSwitch("Airplane mode", isOn: $airplane)
                    ShadSwitch("Marketing emails", isOn: $marketing)
                    ShadSwitch("Security alerts", isOn: $alerts, size: .sm)
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadSwitch("Airplane mode", isOn: .constant(true))
                        ShadSwitch("Marketing emails", isOn: .constant(false))
                        ShadSwitch("Security alerts", isOn: .constant(true), size: .sm)
                    }
                },

                DocExample(
                    "Choice card",
                    description: "The border, the copy and the switch are one hit target; a selected card tints from primary.",
                    width: 620,
                    code: #"""
                    ShadSwitchCard(
                        "Enable notifications",
                        description: "Receive a notification when someone mentions you.",
                        isOn: $notifications
                    )
                    """#
                ) {
                    VStack(spacing: 12) {
                        ShadSwitchCard(
                            "Enable notifications",
                            description: "Receive a notification when someone mentions you.",
                            isOn: .constant(true)
                        )
                        ShadSwitchCard(
                            "Weekly digest",
                            description: "A summary of everything that happened, every Monday.",
                            isOn: .constant(false)
                        )
                    }
                },

                DocExample(
                    "In a horizontal field",
                    description: "The usual settings pattern: copy on the left, control on the right.",
                    width: 620,
                    code: #"""
                    ShadField(orientation: .horizontal) {
                        ShadFieldContent {
                            ShadFieldTitle("Multi-factor authentication")
                            ShadFieldDescription("Require a second factor when signing in.")
                        }
                        ShadSwitch(isOn: $mfa)
                    }
                    """#
                ) {
                    ShadFieldGroup(spacing: 16) {
                        ShadField(orientation: .horizontal) {
                            ShadFieldContent {
                                ShadFieldTitle("Multi-factor authentication")
                                ShadFieldDescription("Require a second factor when signing in.")
                            }
                            ShadSwitch(isOn: .constant(true))
                        }
                        ShadField(orientation: .horizontal) {
                            ShadFieldContent {
                                ShadFieldTitle("Marketing emails")
                                ShadFieldDescription("Receive product news and offers.")
                            }
                            ShadSwitch(isOn: .constant(false))
                        }
                    }
                },
            ],
            notes: [
                "The track is 32×18 points (24×14 at .sm) with a 16pt thumb — measured from shadcn.",
                "An invalid switch keeps its 3pt destructive halo whether or not it has focus.",
            ],
            api: [
                DocAPI("ShadSwitch", [
                    DocProperty("label", "String?", default: "nil", "Optional trailing label."),
                    DocProperty("isOn", "Binding<Bool>", "The toggle state."),
                    DocProperty("size", "ShadSwitchSize", default: ".default", "default (32×18) or sm (28×16)."),
                    DocProperty("isInvalid", "Bool", default: "false", "Draws the destructive border and ring."),
                ]),
            ]
        )
    }

    // MARK: - Checkbox

    static var checkbox: DocComponent {
        DocComponent(
            slug: "checkbox",
            title: "Checkbox",
            summary: "A control that allows the user to toggle between checked and not checked.",
            group: "Controls",
            examples: [
                DocExample(
                    "States",
                    description: "Checked, unchecked, indeterminate, disabled and invalid.",
                    code: #"""
                    ShadCheckbox(isOn: $accepted)
                    ShadCheckbox(state: $selection)        // supports .indeterminate
                    ShadCheckbox(isOn: $accepted).disabled(true)
                    ShadCheckbox(isOn: $accepted, isInvalid: true)
                    """#
                ) {
                    HStack(spacing: 34) {
                        labelled("unchecked") { ShadCheckbox(isOn: .constant(false)) }
                        labelled("checked") { ShadCheckbox(isOn: .constant(true)) }
                        labelled("indeterminate") { ShadCheckbox(state: .constant(.indeterminate)) }
                        labelled("disabled") { ShadCheckbox(isOn: .constant(true)).disabled(true) }
                        labelled("invalid") { ShadCheckbox(isOn: .constant(false), isInvalid: true) }
                    }
                },

                DocExample(
                    "With a label and description",
                    description: "The description belongs beside the box, aligned with the label.",
                    code: #"""
                    ShadCheckbox("Accept terms and conditions", isOn: $accepted)

                    ShadField(orientation: .horizontal, alignment: .top) {
                        ShadCheckbox(isOn: $mobileSettings).padding(.top, 2)
                        ShadFieldContent {
                            ShadFieldTitle("Use different settings for my mobile devices")
                            ShadFieldDescription("You can manage your mobile notifications later.")
                        }
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        ShadCheckbox("Accept terms and conditions", isOn: .constant(true))
                        ShadField(orientation: .horizontal, alignment: .top) {
                            ShadCheckbox(isOn: .constant(true)).padding(.top, 2)
                            ShadFieldContent {
                                ShadFieldTitle("Use different settings for my mobile devices")
                                ShadFieldDescription("You can manage your mobile notifications in the mobile settings page.")
                            }
                        }
                    }
                },

                DocExample(
                    "Group",
                    description: "A legend, a description and a list of options — shadcn's Field Set pattern.",
                    width: 620,
                    code: #"""
                    ShadFieldSet {
                        ShadFieldLegend("Show these items on the desktop")
                        ShadFieldDescription("Select the items you want to show on the desktop.")
                        ShadFieldGroup(spacing: 12) {
                            ForEach(items, id: \.self) { item in
                                ShadCheckbox(item, isOn: binding(for: item))
                            }
                        }
                    }
                    """#
                ) {
                    ShadFieldSet {
                        ShadFieldLegend("Show these items on the desktop")
                        ShadFieldDescription("Select the items you want to show on the desktop.")
                        ShadFieldGroup(spacing: 12) {
                            ShadCheckbox("Hard disks", isOn: .constant(true))
                            ShadCheckbox("External disks", isOn: .constant(true))
                            ShadCheckbox("CDs, DVDs, and iPods", isOn: .constant(false))
                            ShadCheckbox("Connected servers", isOn: .constant(false))
                        }
                    }
                },

                DocExample(
                    "With a description",
                    description: "The description belongs beside the box, aligned with the label — not underneath the box.",
                    width: 620,
                    code: #"""
                    ShadField(orientation: .horizontal, alignment: .top) {
                        ShadCheckbox(isOn: $sync).padding(.top, 2)
                        ShadFieldContent {
                            ShadFieldTitle("Sync Desktop & Documents folders")
                            ShadFieldDescription("Your Desktop & Documents folders are being synced with iCloud Drive.")
                        }
                    }
                    """#
                ) {
                    ShadField(orientation: .horizontal, alignment: .top) {
                        ShadCheckbox(isOn: .constant(true)).padding(.top, 2)
                        ShadFieldContent {
                            ShadFieldTitle("Sync Desktop & Documents folders")
                            ShadFieldDescription("Your Desktop & Documents folders are being synced with iCloud Drive. You can access them from other devices.")
                        }
                    }
                },

                DocExample(
                    "Choice card",
                    description: "A bordered card that highlights when checked; the whole card is clickable.",
                    width: 620,
                    code: #"""
                    ShadCheckboxCard(
                        "Enable notifications",
                        description: "Receive a notification when someone mentions you.",
                        isOn: $notifications
                    )
                    """#
                ) {
                    VStack(spacing: 12) {
                        ShadCheckboxCard(
                            "Enable notifications",
                            description: "Receive a notification when someone mentions you.",
                            isOn: .constant(true)
                        )
                        ShadCheckboxCard("Remember this device", isOn: .constant(false))
                    }
                },

                DocExample(
                    "Tri-state group",
                    description: "The parent row reflects its children with .indeterminate.",
                    code: #"""
                    @State private var selection: ShadCheckboxState = .indeterminate
                    @State private var options: Set<String> = ["Recents"]

                    ShadCheckbox("Select all", state: $selection)
                    ForEach(list, id: \.self) { item in
                        ShadCheckbox(item, isOn: binding(for: item))
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        ShadCheckbox("Select all", state: .constant(.indeterminate))
                        ShadSeparator()
                        ShadCheckbox("Recents", isOn: .constant(true))
                        ShadCheckbox("Home", isOn: .constant(false))
                        ShadCheckbox("Applications", isOn: .constant(false))
                        ShadCheckbox("Desktop", isOn: .constant(false))
                    }
                },
            ],
            notes: [
                "An invalid checkbox keeps a 3pt destructive halo around its red border, focused or not.",
            ],
            api: [
                DocAPI("ShadCheckbox", [
                    DocProperty("label", "String?", default: "nil", "Optional trailing label."),
                    DocProperty("isOn", "Binding<Bool>", "Two-state binding."),
                    DocProperty("state", "Binding<ShadCheckboxState>", "Three-state binding: unchecked, checked or indeterminate."),
                    DocProperty("isInvalid", "Bool", default: "false", "Draws the destructive border and ring."),
                    DocProperty("size", "CGFloat", default: "16", "Box size in points."),
                ]),
            ]
        )
    }

    // MARK: - Slider

    static var slider: DocComponent {
        DocComponent(
            slug: "slider",
            title: "Slider",
            summary: "An input where the user selects a value from within a given range.",
            group: "Controls",
            examples: [
                DocExample(
                    "Single value",
                    width: 520,
                    code: #"""
                    ShadSlider(value: $volume, in: 0...100, step: 1)
                    """#
                ) {
                    ShadSlider(value: .constant(33), in: 0...100, step: 1)
                        .frame(width: 380)
                },

                DocExample(
                    "Range",
                    description: "One thumb per element of the binding, so two values give a range slider.",
                    width: 520,
                    code: #"""
                    @State private var range: [Double] = [20, 80]

                    ShadSlider(values: $range, in: 0...100, step: 1)
                    """#
                ) {
                    ShadSlider(values: .constant([20, 80]), in: 0...100, step: 1)
                        .frame(width: 380)
                },

                DocExample(
                    "Steps and disabled",
                    width: 520,
                    code: #"""
                    ShadSlider(value: $level, in: 0...100, step: 20)
                    ShadSlider(value: $level, in: 0...100).disabled(true)
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 20) {
                        ShadSlider(value: .constant(40), in: 0...100, step: 20)
                        ShadSlider(value: .constant(45), in: 0...100).disabled(true)
                    }
                    .frame(width: 380)
                },

                DocExample(
                    "Vertical",
                    height: 260,
                    code: #"""
                    ShadSlider(value: $level, in: 0...100, orientation: .vertical)
                        .frame(height: 160)

                    ShadSlider(values: $range, in: 0...100, orientation: .vertical)
                        .frame(height: 160)
                    """#
                ) {
                    HStack(alignment: .bottom, spacing: 40) {
                        ShadSlider(value: .constant(60), in: 0...100, orientation: .vertical)
                            .frame(height: 160)
                        ShadSlider(values: .constant([25, 70]), in: 0...100, orientation: .vertical)
                            .frame(height: 160)
                    }
                },
            ],
            notes: [
                "The track is 4pt and the thumb 12pt with a 1pt ring-coloured border — measured from shadcn, which is noticeably finer than a stock SwiftUI slider.",
                "Hovering or dragging a thumb grows a 3pt halo; the thumb itself never changes size.",
            ],
            api: [
                DocAPI("ShadSlider", [
                    DocProperty("value", "Binding<Double>", "Single-thumb binding."),
                    DocProperty("values", "Binding<[Double]>", "One thumb per element."),
                    DocProperty("in", "ClosedRange<Double>", default: "0...100", "The value range."),
                    DocProperty("step", "Double?", default: "nil", "Snapping increment."),
                    DocProperty("orientation", "Axis", default: ".horizontal", "horizontal or vertical."),
                    DocProperty("trackThickness", "CGFloat", default: "6", "Track thickness in points."),
                    DocProperty("thumbSize", "CGFloat", default: "16", "Thumb diameter in points."),
                    DocProperty("onEditingChanged", "((Bool) -> Void)?", default: "nil", "Called when a drag starts and ends."),
                ]),
            ]
        )
    }

    // MARK: - Tabs

    static var tabs: DocComponent {
        DocComponent(
            slug: "tabs",
            title: "Tabs",
            summary: "A set of layered sections of content, displayed one at a time.",
            group: "Controls",
            anatomy: #"""
            ShadTabs
            ├── ShadTabsList
            │   ├── ShadTabsTrigger
            │   └── ShadTabsTrigger
            ├── ShadTabsContent
            └── ShadTabsContent
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "A muted container with an indicator that slides between triggers.",
                    code: #"""
                    enum Tab { case account, password, team }
                    @State private var tab: Tab = .account

                    ShadTabs(selection: $tab) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: Tab.account)
                            ShadTabsTrigger("Password", value: Tab.password)
                            ShadTabsTrigger("Team", value: Tab.team)
                        }
                        ShadTabsContent(value: Tab.account) {
                            Text("Make changes to your account here.")
                        }
                        ShadTabsContent(value: Tab.password) { … }
                        ShadTabsContent(value: Tab.team) { … }
                    }
                    """#
                ) {
                    ShadTabs(selection: .constant(DocTab.account)) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: DocTab.account)
                            ShadTabsTrigger("Password", value: DocTab.password)
                            ShadTabsTrigger("Team", value: DocTab.team)
                        }
                        ShadTabsContent(value: DocTab.account) {
                            ShadCard(size: .sm) {
                                ShadCardContent { Text("Make changes to your account here.") }
                            }
                        }
                    }
                },

                DocExample(
                    "Line variant",
                    description: "variant: .line drops the container and underlines the active trigger.",
                    code: #"""
                    ShadTabs(selection: $tab, variant: .line) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: Tab.account, icon: .user)
                            ShadTabsTrigger("Password", value: Tab.password, icon: .lock)
                            ShadTabsTrigger("Team", value: Tab.team, icon: .users)
                        }
                        ShadTabsContent(value: Tab.account) { … }
                    }
                    """#
                ) {
                    ShadTabs(selection: .constant(DocTab.account), variant: .line) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: DocTab.account, icon: .user)
                            ShadTabsTrigger("Password", value: DocTab.password, icon: .lock)
                            ShadTabsTrigger("Team", value: DocTab.team, icon: .users)
                        }
                        ShadTabsContent(value: DocTab.account) {
                            ShadCard(size: .sm) {
                                ShadCardContent { Text("Account settings and profile.") }
                            }
                        }
                    }
                },

                DocExample(
                    "Vertical",
                    description: "orientation: .vertical puts the list beside the panel.",
                    code: #"""
                    ShadTabs(selection: $tab, orientation: .vertical) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: Tab.account)
                            ShadTabsTrigger("Password", value: Tab.password)
                            ShadTabsTrigger("Team", value: Tab.team)
                        }
                        ShadTabsContent(value: Tab.account) { … }
                    }
                    """#
                ) {
                    ShadTabs(selection: .constant(DocTab.account), orientation: .vertical) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: DocTab.account)
                            ShadTabsTrigger("Password", value: DocTab.password)
                            ShadTabsTrigger("Team", value: DocTab.team)
                        }
                        ShadTabsContent(value: DocTab.account) {
                            ShadCard(size: .sm) {
                                ShadCardContent { Text("Account panel.") }
                            }
                        }
                    }
                },

                DocExample(
                    "Disabled trigger",
                    code: #"""
                    ShadTabsTrigger("Password", value: Tab.password).disabled(true)
                    """#
                ) {
                    ShadTabs(selection: .constant(DocTab.account)) {
                        ShadTabsList {
                            ShadTabsTrigger("Account", value: DocTab.account)
                            ShadTabsTrigger("Password", value: DocTab.password).disabled(true)
                        }
                    }
                },
            ],
            notes: [
                "The line variant draws a 2pt rule under the active trigger only — there is no rule spanning the whole control.",
                "Switching tabs swaps the panel immediately. Crossfading it makes the empty container flash.",
                "The active indicator uses matchedGeometryEffect, so it slides between triggers.",
            ],
            api: [
                DocAPI("ShadTabs", [
                    DocProperty("selection", "Binding<Value>", "Any Hashable value identifying the active tab."),
                    DocProperty("variant", "ShadTabsVariant", default: ".default", "default (boxed) or line."),
                    DocProperty("orientation", "Axis", default: ".horizontal", "horizontal or vertical."),
                    DocProperty("spacing", "CGFloat", default: "12", "Gap between the list and the panel."),
                ]),
                DocAPI("ShadTabsTrigger", [
                    DocProperty("title", "String", "Trigger label."),
                    DocProperty("value", "Value", "The value this trigger selects."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Optional leading icon."),
                ]),
            ]
        )
    }

    // MARK: - Helpers

    enum DocTab: Hashable { case account, password, team }

    @ViewBuilder
    static func labelled(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            content()
        }
    }
}
