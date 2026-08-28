import SwiftUI
import ShadSwift

// MARK: - Card

struct CardPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var agreed = false

    static let terms: [(String, String)] = [
        ("1. Acceptance", "By accessing the service you agree to be bound by these terms and to comply with all applicable laws."),
        ("2. Your account", "You are responsible for safeguarding the credentials you use to access the service."),
        ("3. Content", "You retain ownership of anything you upload. You grant us a licence to host and display it."),
        ("4. Termination", "We may suspend access if these terms are breached. You may close your account at any time."),
        ("5. Changes", "We will give at least 30 days' notice before any material change takes effect."),
    ]

    var body: some View {
        DemoPage(title: "Card", subtitle: "Displays a card with header, content and footer.") {
            DemoSection("Login card", description: "Header with a CardAction, content and a footer.") {
                ShadCard {
                    ShadCardHeader {
                        ShadCardTitle("Login to your account")
                        ShadCardDescription("Enter your email below to login to your account.")
                    } action: {
                        ShadButton("Sign up", variant: .link, size: .sm) {}
                    }
                    ShadCardContent {
                        ShadFieldGroup(spacing: 14) {
                            ShadField {
                                ShadFieldLabel("Email")
                                ShadInput("m@example.com", text: $email)
                            }
                            ShadField {
                                ShadFieldLabel("Password")
                                ShadInput("", text: $password, isSecure: true)
                            }
                        }
                    }
                    ShadCardFooter {
                        VStack(spacing: 8) {
                            ShadButton("Login", fillsWidth: true) {}
                            ShadButton("Login with Google", variant: .outline, fillsWidth: true) {}
                        }
                    }
                }
                .frame(width: 380)
            }

            DemoSection("Sizes", description: "The size prop drives --card-spacing.") {
                HStack(alignment: .top, spacing: 16) {
                    ShadCard {
                        ShadCardHeader {
                            ShadCardTitle("Default")
                            ShadCardDescription("24pt of spacing.")
                        }
                        ShadCardContent { Text("Body content.") }
                    }
                    ShadCard(size: .sm) {
                        ShadCardHeader {
                            ShadCardTitle("Small")
                            ShadCardDescription("16pt of spacing.")
                        }
                        ShadCardContent { Text("Body content.") }
                    }
                }
            }

            DemoSection("Terms of Service", description: "A scrolling body between a fixed header and footer.") {
                ShadCard {
                    ShadCardHeader(showsSeparator: true) {
                        ShadCardTitle("Terms of Service")
                        ShadCardDescription("Last updated: 3 December 2025")
                    }
                    ShadCardContent {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {
                                ForEach(Self.terms, id: \.0) { title, body in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title).font(.system(size: 13, weight: .semibold))
                                        Text(body)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 180)
                    }
                    ShadCardFooter(showsSeparator: true) {
                        ShadCheckbox("I agree to the terms", isOn: $agreed)
                        Spacer()
                        ShadButton("Decline", variant: .outline, size: .sm) {}
                        ShadButton("Accept", size: .sm) {}
                    }
                }
                .frame(width: 460)
            }

            DemoSection("With an image", description: "Artwork above the header, bleeding to the card's edges.") {
                HStack(alignment: .top, spacing: 20) {
                    ShadCard(spacing: 16) {
                        LinearGradient(
                            colors: [Color(oklch: 0.72, 0.18, 250), Color(oklch: 0.62, 0.22, 300)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 140)
                        .overlay(alignment: .topTrailing) {
                            ShadBadge("New", variant: .secondary).padding(12)
                        }
                        .padding(.top, -16)
                        ShadCardHeader {
                            ShadCardTitle("Northern lights")
                            ShadCardDescription("Tromsø, Norway · 4 min read")
                        }
                        ShadCardFooter {
                            ShadAvatarGroup {
                                ShadAvatar(fallback: "CN", size: .sm)
                                ShadAvatar(fallback: "LR", size: .sm)
                            }
                            Spacer()
                            ShadButton("Read", variant: .outline, size: .sm, trailingIcon: .arrowRight) {}
                        }
                    }
                    .frame(width: 300)

                    ShadCard(size: .sm) {
                        ShadCardContent {
                            HStack(spacing: 14) {
                                ShadRoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(
                                        colors: [Color(oklch: 0.78, 0.16, 70), Color(oklch: 0.66, 0.20, 30)],
                                        startPoint: .top, endPoint: .bottom))
                                    .frame(width: 64, height: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sunset over Lofoten")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("A short photo essay")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .frame(width: 300)
                }
            }

            DemoSection("With separators", description: "Header and footer can carry a rule.") {
                ShadCard {
                    ShadCardHeader(showsSeparator: true) {
                        ShadCardTitle("Team members")
                        ShadCardDescription("Invite your team to collaborate.")
                    } action: {
                        ShadBadge("3 seats", variant: .secondary)
                    }
                    ShadCardContent {
                        ShadItemGroup {
                            ShadItem(size: .sm) {
                                ShadItemMedia { ShadAvatar(fallback: "CN") }
                                ShadItemContent {
                                    ShadItemTitle("Sofia Davis")
                                    ShadItemDescription("m@example.com")
                                }
                                ShadItemActions { ShadBadge("Owner", variant: .outline) }
                            }
                            ShadItemSeparator()
                            ShadItem(size: .sm) {
                                ShadItemMedia { ShadAvatar(fallback: "JL") }
                                ShadItemContent {
                                    ShadItemTitle("Jackson Lee")
                                    ShadItemDescription("p@example.com")
                                }
                                ShadItemActions { ShadBadge("Member", variant: .outline) }
                            }
                        }
                    }
                    ShadCardFooter(showsSeparator: true) {
                        ShadButton("Invite", size: .sm, icon: .plus) {}
                        Spacer()
                        ShadButton("Manage", variant: .ghost, size: .sm) {}
                    }
                }
                .frame(width: 460)
            }
        }
    }
}

// MARK: - Avatar

struct AvatarPage: View {
    @State private var avatar = ShadAvatarEditorState(image: DemoPhoto.landscape)
    @State private var emptyAvatar = ShadAvatarEditorState()

    var body: some View {
        DemoPage(title: "Avatar", subtitle: "An image element with a fallback for representing the user.") {
            DemoSection("Sizes", description: "sm, default and lg, or any custom point size.") {
                DemoRow(spacing: 16) {
                    ShadAvatar(fallback: "CN", size: .sm)
                    ShadAvatar(fallback: "CN")
                    ShadAvatar(fallback: "CN", size: .lg)
                    ShadAvatar(fallback: "CN", customSize: 64)
                }
            }

            DemoSection("Fallbacks", description: "Initials, an icon, or a symbol tile when no image loads.") {
                DemoRow(spacing: 16) {
                    ShadAvatar(fallback: "EV")
                    ShadAvatar()
                    ShadAvatar(image: .symbol(.bot), size: .lg)
                    ShadAvatar(fallback: "SQ", size: .lg, shape: .rounded)
                }
            }

            DemoSection("With a badge", description: "AvatarBadge shows presence or a tiny icon.") {
                DemoRow(spacing: 20) {
                    ShadAvatar(fallback: "CN", size: .lg)
                        .badge(color: Color(oklch: 0.7, 0.16, 150))
                    ShadAvatar(fallback: "LR", size: .lg)
                        .badge(color: Color(oklch: 0.75, 0.17, 70))
                    ShadAvatar(fallback: "AB", size: .lg)
                        .badge(icon: .check, alignment: .bottomTrailing)
                    ShadAvatar(fallback: "TP", size: .lg)
                        .badge(icon: .bell, alignment: .topTrailing)
                }
            }

            DemoSection("Group", description: "Overlapping avatars with a count.") {
                DemoRow(spacing: 24) {
                    ShadAvatarGroup {
                        ShadAvatar(fallback: "CN")
                        ShadAvatar(fallback: "LR")
                        ShadAvatar(fallback: "ER")
                    }
                    ShadAvatarGroup {
                        ShadAvatar(fallback: "CN")
                        ShadAvatar(fallback: "LR")
                        ShadAvatarGroupCount(3)
                    }
                    ShadAvatarGroup(overlap: 14) {
                        ShadAvatar(fallback: "A", size: .lg)
                        ShadAvatar(fallback: "B", size: .lg)
                        ShadAvatar(fallback: "C", size: .lg)
                        ShadAvatarGroupCount(12, size: .lg)
                    }
                }
            }

            DemoSection(
                "Editable",
                description: "Click the avatar to frame it in a dialog, or drop an image file straight onto it. The crop is stored as a zoom and an offset in fractions of the mask, so one setting reads the same at every size."
            ) {
                VStack(alignment: .leading, spacing: 28) {
                    profileRow
                    ShadSeparator()
                    sizesRow
                }
            }
        }
        .shadAvatarEditor($avatar, description: "Drag the picture to reposition it, zoom with the slider, or drop a new image file onto the mask.")
        .shadAvatarEditor($emptyAvatar, title: "Add a picture", description: "Drop an image file onto the circle to get started.")
    }

    /// The profile-page treatment: a big avatar beside a name.
    private var profileRow: some View {
        HStack(spacing: 20) {
            ShadEditableAvatar($avatar, fallback: "EV", customSize: 96)

            VStack(alignment: .leading, spacing: 4) {
                Text("Evil Rabbit")
                    .font(.system(size: 16, weight: .semibold))
                Text("m@example.com")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                DemoCaption("Click the picture to change it")
                    .padding(.top, 4)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                DemoCaption("Starting empty")
                ShadEditableAvatar($emptyAvatar, fallback: "SD", customSize: 64)
            }
        }
    }

    /// The same crop, drawn at every size the library offers.
    private var sizesRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            DemoCaption("The saved crop, at each avatar size")
            DemoRow(spacing: 16) {
                ShadAvatar(photo: avatar.photo, fallback: "EV", size: .sm)
                ShadAvatar(photo: avatar.photo, fallback: "EV")
                ShadAvatar(photo: avatar.photo, fallback: "EV", size: .lg)
                ShadAvatar(photo: avatar.photo, fallback: "EV", customSize: 56, shape: .rounded)
                ShadAvatar(photo: avatar.photo, fallback: "EV", customSize: 56)
                    .badge(color: Color(oklch: 0.7, 0.16, 150))
            }
        }
    }
}

// MARK: - Item

struct ItemPage: View {
    var body: some View {
        DemoPage(title: "Item", subtitle: "A flex container for a title, a description and some actions.") {
            DemoSection("Variants", description: "default, outline and muted.") {
                VStack(spacing: 10) {
                    ShadItem {
                        ShadItemMedia(icon: .bell)
                        ShadItemContent {
                            ShadItemTitle("Default")
                            ShadItemDescription("Transparent background with no border.")
                        }
                        ShadItemActions { ShadButton("Action", variant: .outline, size: .sm) {} }
                    }
                    ShadItem(variant: .outline) {
                        ShadItemMedia(icon: .folder)
                        ShadItemContent {
                            ShadItemTitle("Outline")
                            ShadItemDescription("A hairline border and rounded corners.")
                        }
                        ShadItemActions { ShadButton("Action", variant: .outline, size: .sm) {} }
                    }
                    ShadItem(variant: .muted) {
                        ShadItemMedia(icon: .cloud)
                        ShadItemContent {
                            ShadItemTitle("Muted")
                            ShadItemDescription("A muted background for secondary content.")
                        }
                        ShadItemActions { ShadButton("Action", variant: .outline, size: .sm) {} }
                    }
                }
            }

            DemoSection("Sizes", description: "default, sm and xs.") {
                VStack(spacing: 8) {
                    ShadItem(variant: .outline) {
                        ShadItemContent {
                            ShadItemTitle("Default size")
                            ShadItemDescription("16pt of padding.")
                        }
                    }
                    ShadItem(variant: .outline, size: .sm) {
                        ShadItemContent { ShadItemTitle("Small size") }
                    }
                    ShadItem(variant: .outline, size: .xs) {
                        ShadItemContent { ShadItemTitle("Extra small size") }
                    }
                }
            }

            DemoSection("Media variants", description: "Icons, avatars and images in the leading slot.") {
                VStack(spacing: 10) {
                    ShadItem(variant: .outline) {
                        ShadItemMedia(icon: .cloudUpload)
                        ShadItemContent {
                            ShadItemTitle("Upload files")
                            ShadItemDescription("Drag and drop, or browse from your machine.")
                        }
                        ShadItemActions { ShadButton("Browse", size: .sm) {} }
                    }
                    ShadItem(variant: .outline) {
                        ShadItemMedia { ShadAvatar(fallback: "SD", size: .lg) }
                        ShadItemContent {
                            ShadItemTitle("Sofia Davis")
                            ShadItemDescription("Last active 2 hours ago")
                        }
                        ShadItemActions {
                            ShadDropdownMenu(alignment: .bottomTrailing) { _ in
                                ShadIconView(.moreHorizontal, size: 16)
                                    .frame(width: 28, height: 28)
                                    .contentShape(Rectangle())
                            } content: {
                                ShadDropdownMenuItem("View profile", icon: .user) {}
                                ShadDropdownMenuItem("Message", icon: .mail) {}
                                ShadDropdownMenuSeparator()
                                ShadDropdownMenuItem("Remove", icon: .trash, variant: .destructive) {}
                            }
                        }
                    }
                }
            }

            DemoSection("Header and footer", description: "Optional slots above and below the row.") {
                ShadItem(variant: .outline) {
                    ShadItemMedia(icon: .gitPullRequest)
                    ShadItemContent {
                        ShadItemTitle("Add OKLCH theme tokens")
                        ShadItemDescription("Converts the shadcn palette at build time.")
                    }
                    ShadItemActions { ShadBadge("Open", variant: .secondary) }
                }
                .header { Text("PULL REQUEST #128") }
                .footer { Text("Opened 3 days ago by ez · 4 files changed") }
            }

            DemoSection("Grouped and clickable", description: "ItemGroup with separators; rows can take an action.") {
                ShadItemGroup(isBordered: true) {
                    ShadItem(size: .sm, action: {}) {
                        ShadItemMedia(icon: .settings, size: 32)
                        ShadItemContent {
                            ShadItemTitle("Preferences")
                            ShadItemDescription("Theme, shortcuts and defaults")
                        }
                        ShadItemActions { ShadIconView(.chevronRight, size: 14) }
                    }
                    ShadItemSeparator()
                    ShadItem(size: .sm, action: {}) {
                        ShadItemMedia(icon: .lock, size: 32)
                        ShadItemContent {
                            ShadItemTitle("Security")
                            ShadItemDescription("Two-factor authentication")
                        }
                        ShadItemActions { ShadIconView(.chevronRight, size: 14) }
                    }
                }
            }
        }
    }
}
