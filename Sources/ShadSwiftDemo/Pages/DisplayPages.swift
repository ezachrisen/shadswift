import SwiftUI
import ShadSwift

// MARK: - Button

struct ButtonPage: View {
    @State private var isLoading = false

    var body: some View {
        DemoPage(title: "Button", subtitle: "Displays a button or a component that looks like a button.") {
            DemoSection("Variants", description: "default, secondary, destructive, outline, ghost and link.") {
                DemoRow {
                    ShadButton("Button") {}
                    ShadButton("Secondary", variant: .secondary) {}
                    ShadButton("Destructive", variant: .destructive) {}
                    ShadButton("Outline", variant: .outline) {}
                    ShadButton("Ghost", variant: .ghost) {}
                    ShadButton("Link", variant: .link) {}
                }
            }

            DemoSection("Sizes", description: "xs, sm, default and lg.") {
                DemoRow {
                    ShadButton("Extra small", size: .xs) {}
                    ShadButton("Small", size: .sm) {}
                    ShadButton("Default") {}
                    ShadButton("Large", size: .lg) {}
                }
            }

            DemoSection("Icon sizes", description: "icon-xs, icon-sm, icon and icon-lg.") {
                DemoRow {
                    ShadButton(icon: .plus, variant: .outline, size: .iconXS, accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .iconSM, accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .icon, accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .iconLG, accessibilityLabel: "Add") {}
                }
            }

            DemoSection("With icons", description: "Leading and trailing icons scale with the button size.") {
                DemoRow {
                    ShadButton("Send", icon: .send) {}
                    ShadButton("Continue", variant: .outline, trailingIcon: .arrowRight) {}
                    ShadButton("Delete", variant: .destructive, icon: .trash) {}
                }
            }

            DemoSection("Loading", description: "isLoading swaps the leading icon for a spinner and blocks the action.") {
                DemoRow {
                    ShadButton("Please wait", isLoading: true) {}
                    ShadButton("Saving", variant: .outline, isLoading: true) {}
                    ShadButton(isLoading ? "Working" : "Start task", variant: .secondary, isLoading: isLoading) {
                        isLoading = true
                        Task {
                            try? await Task.sleep(nanoseconds: 1_600_000_000)
                            isLoading = false
                        }
                    }
                }
            }

            DemoSection("Shapes and width", description: "Pill corners, square corners and a full-width button.") {
                VStack(alignment: .leading, spacing: 12) {
                    DemoRow {
                        ShadButton("Pill", shape: .pill) {}
                        ShadButton("Square", variant: .outline, shape: .square) {}
                        ShadButton(icon: .heart, variant: .secondary, size: .icon, shape: .pill, accessibilityLabel: "Like") {}
                    }
                    ShadButton("Full width", variant: .outline, fillsWidth: true) {}
                }
            }

            DemoSection("Disabled", description: "Disabled buttons drop to 50% opacity and stop responding.") {
                DemoRow {
                    ShadButton("Disabled") {}.disabled(true)
                    ShadButton("Outline", variant: .outline) {}.disabled(true)
                    ShadButton("Ghost", variant: .ghost) {}.disabled(true)
                }
            }

            DemoSection("As a SwiftUI ButtonStyle", description: "Any plain Button can adopt the styling.") {
                DemoRow {
                    Button("Styled Button") {}
                        .buttonStyle(.shad(.secondary, size: .sm))
                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            ShadIconView(.download, size: 16)
                            Text("Download")
                        }
                    }
                    .buttonStyle(.shad(.outline))
                }
            }
        }
    }
}

// MARK: - Badge

struct BadgePage: View {
    var body: some View {
        DemoPage(title: "Badge", subtitle: "Displays a badge or a component that looks like a badge.") {
            DemoSection("Variants") {
                DemoRow {
                    ShadBadge("Badge")
                    ShadBadge("Secondary", variant: .secondary)
                    ShadBadge("Destructive", variant: .destructive)
                    ShadBadge("Outline", variant: .outline)
                    ShadBadge("Ghost", variant: .ghost)
                    ShadBadge("Link", variant: .link)
                }
            }

            DemoSection("With icons", description: "Icons render inline at the start or the end.") {
                DemoRow {
                    ShadBadge("Verified", variant: .secondary, icon: .circleCheck)
                    ShadBadge("Failed", variant: .destructive, icon: .circleX)
                    ShadBadge("8 new", variant: .outline, trailingIcon: .arrowRight)
                }
            }

            DemoSection("With a spinner", description: "Any view can go inside a badge.") {
                DemoRow {
                    ShadBadge(variant: .secondary) {
                        ShadSpinner(size: 10)
                        Text("Syncing")
                    }
                    ShadBadge(variant: .outline) {
                        ShadBadgeDot(Color(oklch: 0.6, 0.15, 145))
                        Text("Operational")
                    }
                    ShadBadge(variant: .outline) {
                        ShadBadgeDot(Color(oklch: 0.75, 0.17, 70))
                        Text("Degraded")
                    }
                }
            }

            DemoSection("Counts", description: "Badges are pills by default; shape: .rounded squares them off.") {
                DemoRow {
                    ShadBadge("8")
                    ShadBadge("99", variant: .destructive)
                    ShadBadge("20+", variant: .secondary)
                    ShadBadge("Rounded", variant: .outline, shape: .rounded)
                }
            }

            DemoSection("Custom colors", description: "A tinted palette, matching the Custom Colors example on the shadcn page.") {
                DemoRow {
                    ForEach(ShadBadgeColor.all, id: \.name) { entry in
                        ShadBadge(entry.name.capitalized, color: entry.color)
                    }
                }
            }

            DemoSection("Link", description: "A badge that acts as a link: the solid treatment with a trailing arrow.") {
                DemoRow {
                    ShadBadgeLink("Read the changelog") {}
                    ShadBadgeLink("v1.0") {}
                }
            }
        }
    }
}

// MARK: - Spinner

struct SpinnerPage: View {
    var body: some View {
        DemoPage(title: "Spinner", subtitle: "An indeterminate loading indicator.") {
            DemoSection("Styles") {
                DemoRow(spacing: 32) {
                    DemoLabeled(label: "arc") { ShadSpinner(size: 24) }
                    DemoLabeled(label: "spokes") { ShadSpinner(size: 24, style: .spokes) }
                    DemoLabeled(label: "dots") { ShadSpinner(size: 24, style: .dots) }
                }
            }

            DemoSection("Sizes", description: "Any point size; the stroke scales with it.") {
                DemoRow(spacing: 24) {
                    ShadSpinner(size: 12)
                    ShadSpinner(size: 16)
                    ShadSpinner(size: 24)
                    ShadSpinner(size: 32)
                    ShadSpinner(size: 48)
                }
            }

            DemoSection("In other components") {
                DemoRow {
                    ShadButton("Please wait", isLoading: true) {}
                    ShadBadge(variant: .secondary) {
                        ShadSpinner(size: 10)
                        Text("Processing")
                    }
                    ShadItem(variant: .outline, size: .sm) {
                        ShadItemMedia { ShadSpinner(size: 18) }
                        ShadItemContent {
                            ShadItemTitle("Indexing repository")
                            ShadItemDescription("1,204 of 3,880 files")
                        }
                    }
                    .frame(width: 320)
                }
            }
        }
    }
}
