import SwiftUI
import ShadSwift

// MARK: - Switch

struct SwitchPage: View {
    @State private var airplane = true
    @State private var marketing = false
    @State private var security = true
    @State private var invalid = false

    var body: some View {
        DemoPage(title: "Switch", subtitle: "A control that allows the user to toggle between checked and not checked.") {
            DemoSection("Sizes and states") {
                DemoRow(spacing: 28) {
                    DemoLabeled(label: "default") { ShadSwitch(isOn: $airplane) }
                    DemoLabeled(label: "sm") { ShadSwitch(isOn: $airplane, size: .sm) }
                    DemoLabeled(label: "off") { ShadSwitch(isOn: .constant(false)) }
                    DemoLabeled(label: "disabled") { ShadSwitch(isOn: .constant(true)).disabled(true) }
                    DemoLabeled(label: "invalid") { ShadSwitch(isOn: $invalid, isInvalid: true) }
                }
            }

            DemoSection("With a label") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadSwitch("Airplane mode", isOn: $airplane)
                    ShadSwitch("Marketing emails", isOn: $marketing)
                    ShadSwitch("Security alerts", isOn: $security, size: .sm)
                }
            }

            DemoSection("Choice card", description: "The border, the copy and the switch are one hit target.") {
                VStack(spacing: 12) {
                    ShadSwitchCard(
                        "Enable notifications",
                        description: "Receive a notification when someone mentions you.",
                        isOn: $security
                    )
                    ShadSwitchCard(
                        "Weekly digest",
                        description: "A summary of everything that happened, every Monday.",
                        isOn: $marketing
                    )
                }
                .frame(width: 460)
            }

            DemoSection("In a field", description: "Horizontal fields put the control beside the copy.") {
                ShadFieldGroup(spacing: 16) {
                    ShadField(orientation: .horizontal) {
                        ShadFieldContent {
                            ShadFieldTitle("Multi-factor authentication")
                            ShadFieldDescription("Require a second factor when signing in.")
                        }
                        ShadSwitch(isOn: $security)
                    }
                    ShadField(orientation: .horizontal) {
                        ShadFieldContent {
                            ShadFieldTitle("Marketing emails")
                            ShadFieldDescription("Receive product news and offers.")
                        }
                        ShadSwitch(isOn: $marketing)
                    }
                }
            }
        }
    }
}

// MARK: - Checkbox

struct CheckboxPage: View {
    @State private var terms = true
    @State private var tri: ShadCheckboxState = .indeterminate
    @State private var options: Set<String> = ["Recents"]
    @State private var card2 = false

    private let list = ["Hard disks", "External disks", "CDs, DVDs, and iPods", "Connected servers"]

    private func binding(for item: String) -> Binding<Bool> {
        Binding(
            get: { options.contains(item) },
            set: { isOn in
                if isOn { options.insert(item) } else { options.remove(item) }
                tri = options.isEmpty ? .unchecked : (options.count == list.count ? .checked : .indeterminate)
            }
        )
    }

    var body: some View {
        DemoPage(title: "Checkbox", subtitle: "A control that allows the user to toggle between checked and not checked.") {
            DemoSection("States") {
                DemoRow(spacing: 28) {
                    DemoLabeled(label: "unchecked") { ShadCheckbox(isOn: .constant(false)) }
                    DemoLabeled(label: "checked") { ShadCheckbox(isOn: .constant(true)) }
                    DemoLabeled(label: "indeterminate") { ShadCheckbox(state: .constant(.indeterminate)) }
                    DemoLabeled(label: "disabled") { ShadCheckbox(isOn: .constant(true)).disabled(true) }
                    DemoLabeled(label: "invalid") { ShadCheckbox(isOn: .constant(false), isInvalid: true) }
                }
            }

            DemoSection("With a label and description") {
                VStack(alignment: .leading, spacing: 14) {
                    ShadCheckbox("Accept terms and conditions", isOn: $terms)
                    ShadField(orientation: .horizontal, alignment: .top) {
                        ShadCheckbox(isOn: $terms).padding(.top, 2)
                        ShadFieldContent {
                            ShadFieldTitle("Use different settings for my mobile devices")
                            ShadFieldDescription("You can manage your mobile notifications in the mobile settings page.")
                        }
                    }
                    .frame(width: 460)
                }
            }

            DemoSection("Group", description: "A legend, a description and a list of options — shadcn's Field Set pattern.") {
                ShadFieldSet {
                    ShadFieldLegend("Show these items on the desktop")
                    ShadFieldDescription("Select the items you want to show on the desktop.")
                    ShadFieldGroup(spacing: 12) {
                        ForEach(list, id: \.self) { item in
                            ShadCheckbox(item, isOn: binding(for: item))
                        }
                    }
                }
                .frame(width: 460)
            }

            DemoSection("With a description", description: "The description sits beside the box, aligned with the label — not underneath the box.") {
                ShadField(orientation: .horizontal, alignment: .top) {
                    ShadCheckbox(isOn: $terms)
                        .padding(.top, 2)
                    ShadFieldContent {
                        ShadFieldTitle("Sync Desktop & Documents folders")
                        ShadFieldDescription("Your Desktop & Documents folders are being synced with iCloud Drive. You can access them from other devices.")
                    }
                }
                .frame(width: 460)
            }

            DemoSection("Choice card", description: "A bordered card that highlights when checked.") {
                VStack(spacing: 12) {
                    ShadCheckboxCard(
                        "Enable notifications",
                        description: "Receive a notification when someone mentions you.",
                        isOn: $terms
                    )
                    ShadCheckboxCard("Remember this device", isOn: $card2)
                }
                .frame(width: 460)
            }

            DemoSection("Tri-state", description: "The parent row reflects the children with an indeterminate state.") {
                VStack(alignment: .leading, spacing: 10) {
                    ShadCheckbox("Select all", state: $tri)
                    ShadSeparator()
                    ForEach(list, id: \.self) { item in
                        ShadCheckbox(item, isOn: binding(for: item))
                    }
                }
            }
        }
    }
}

// MARK: - Slider

struct SliderPage: View {
    @State private var volume: Double = 33
    @State private var range: [Double] = [20, 80]
    @State private var vertical: Double = 60
    @State private var stepped: Double = 40

    var body: some View {
        DemoPage(title: "Slider", subtitle: "An input where the user selects a value from within a given range.") {
            DemoSection("Single value") {
                VStack(alignment: .leading, spacing: 8) {
                    ShadSlider(value: $volume, in: 0...100, step: 1)
                    DemoCaption("value: \(Int(volume))")
                }
                .frame(width: 380)
            }

            DemoSection("Range", description: "Two entries in the binding produce two thumbs.") {
                VStack(alignment: .leading, spacing: 8) {
                    ShadSlider(values: $range, in: 0...100, step: 1)
                    DemoCaption("values: \(Int(range[0])) – \(Int(range[1]))")
                }
                .frame(width: 380)
            }

            DemoSection("Steps and disabled") {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        ShadSlider(value: $stepped, in: 0...100, step: 20)
                        DemoCaption("step: 20 → \(Int(stepped))")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        ShadSlider(value: .constant(45), in: 0...100).disabled(true)
                        DemoCaption("disabled")
                    }
                }
                .frame(width: 380)
            }

            DemoSection("Vertical") {
                HStack(alignment: .bottom, spacing: 32) {
                    ShadSlider(value: $vertical, in: 0...100, orientation: .vertical)
                        .frame(height: 160)
                    ShadSlider(values: .constant([25, 70]), in: 0...100, orientation: .vertical)
                        .frame(height: 160)
                    DemoCaption("value: \(Int(vertical))")
                }
            }
        }
    }
}

// MARK: - Tabs

struct TabsPage: View {
    enum Tab: String, Hashable { case account, password, team }
    @State private var boxed: Tab = .account
    @State private var line: Tab = .account
    @State private var vertical: Tab = .account

    var body: some View {
        DemoPage(title: "Tabs", subtitle: "A set of layered sections of content, displayed one at a time.") {
            DemoSection("Default", description: "A muted container with a sliding indicator.") {
                ShadTabs(selection: $boxed) {
                    ShadTabsList {
                        ShadTabsTrigger("Account", value: Tab.account)
                        ShadTabsTrigger("Password", value: Tab.password)
                        ShadTabsTrigger("Team", value: Tab.team)
                    }
                    ShadTabsContent(value: Tab.account) { panel("Make changes to your account here.") }
                    ShadTabsContent(value: Tab.password) { panel("Change your password here.") }
                    ShadTabsContent(value: Tab.team) { panel("Invite and manage your team.") }
                }
            }

            DemoSection("Line variant", description: "variant: .line underlines the active trigger.") {
                ShadTabs(selection: $line, variant: .line) {
                    ShadTabsList {
                        ShadTabsTrigger("Account", value: Tab.account, icon: .user)
                        ShadTabsTrigger("Password", value: Tab.password, icon: .lock)
                        ShadTabsTrigger("Team", value: Tab.team, icon: .users)
                    }
                    ShadTabsContent(value: Tab.account) { panel("Account settings and profile.") }
                    ShadTabsContent(value: Tab.password) { panel("Update your password.") }
                    ShadTabsContent(value: Tab.team) { panel("Team members and roles.") }
                }
            }

            DemoSection("Vertical", description: "orientation: .vertical stacks the list beside the panel.") {
                ShadTabs(selection: $vertical, orientation: .vertical) {
                    ShadTabsList {
                        ShadTabsTrigger("Account", value: Tab.account)
                        ShadTabsTrigger("Password", value: Tab.password)
                        ShadTabsTrigger("Team", value: Tab.team)
                    }
                    ShadTabsContent(value: Tab.account) { panel("Account panel.") }
                    ShadTabsContent(value: Tab.password) { panel("Password panel.") }
                    ShadTabsContent(value: Tab.team) { panel("Team panel.") }
                }
            }

            DemoSection("Disabled trigger") {
                ShadTabs(selection: .constant(Tab.account)) {
                    ShadTabsList {
                        ShadTabsTrigger("Account", value: Tab.account)
                        ShadTabsTrigger("Password", value: Tab.password).disabled(true)
                    }
                }
            }
        }
    }

    private func panel(_ text: String) -> some View {
        ShadCard(size: .sm) {
            ShadCardContent { Text(text) }
        }
    }
}

// MARK: - Radio group

struct RadioPage: View {
    enum Density: String, Hashable { case `default`, comfortable, compact }
    enum Compute: String, Hashable { case kubernetes, virtualMachine, bareMetal }

    @State private var density: Density = .comfortable
    @State private var compute: Compute = .kubernetes
    @State private var plan: String? = nil
    @State private var invalid: String? = nil

    var body: some View {
        DemoPage(title: "Radio Group", subtitle: "A set of checkable buttons where no more than one may be checked at a time.") {
            DemoSection("Default") {
                ShadRadioGroup(selection: $density) {
                    ShadRadio("Default", value: Density.default)
                    ShadRadio("Comfortable", value: Density.comfortable)
                    ShadRadio("Compact", value: Density.compact)
                }
                .frame(width: 360)
            }

            DemoSection("With descriptions", description: "The description sits beside the circle, aligned with the label.") {
                ShadRadioGroup(selection: $plan) {
                    ShadRadio("Starter", description: "For hobby projects and prototypes.", value: "starter")
                    ShadRadio("Pro", description: "For teams shipping to production.", value: "pro")
                    ShadRadio("Enterprise", description: "SSO, audit logs and a dedicated contact.", value: "enterprise")
                }
                .frame(width: 460)
            }

            DemoSection("Choice cards", description: "The whole card is the control; a selected card tints from primary.") {
                ShadFieldSet {
                    ShadFieldLegend("Compute Environment")
                    ShadFieldDescription("Select the compute environment for your cluster.")
                    ShadRadioGroup(selection: $compute) {
                        ShadRadioCard("Kubernetes", description: "Run GPU workloads on a K8s cluster.", value: Compute.kubernetes)
                        ShadRadioCard("Virtual Machine", description: "Access a cluster to run GPU workloads.", value: Compute.virtualMachine)
                        ShadRadioCard("Bare Metal", description: "Dedicated hardware, no hypervisor.", value: Compute.bareMetal)
                    }
                }
                .frame(width: 460)
            }

            DemoSection("States") {
                HStack(alignment: .top, spacing: 48) {
                    DemoLabeled(label: "disabled") {
                        ShadRadioGroup(selection: .constant(Density.default)) {
                            ShadRadio("Default", value: Density.default)
                            ShadRadio("Compact", value: Density.compact)
                        }
                        .disabled(true)
                        .frame(width: 160)
                    }
                    DemoLabeled(label: "invalid") {
                        ShadRadioGroup(selection: $invalid) {
                            ShadRadio("Yes", value: "yes", isInvalid: true)
                            ShadRadio("No", value: "no", isInvalid: true)
                        }
                        .frame(width: 160)
                    }
                }
            }
        }
    }
}
