import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var display: [DocComponent] {
        [button, badge, card, avatar, item, spinner]
    }

    static let terms: [(String, String)] = [
        ("1. Acceptance", "By accessing the service you agree to be bound by these terms and to comply with all applicable laws."),
        ("2. Your account", "You are responsible for safeguarding the credentials you use to access the service."),
        ("3. Content", "You retain ownership of anything you upload. You grant us a licence to host and display it."),
    ]

    // MARK: - Button

    static var button: DocComponent {
        DocComponent(
            slug: "button",
            title: "Button",
            summary: "Displays a button, or a component that looks like a button.",
            group: "Display",
            examples: [
                DocExample(
                    "Variants",
                    description: "Six treatments, matching shadcn's buttonVariants. Destructive is a soft wash with red text.",
                    code: #"""
                    ShadButton("Button") { save() }
                    ShadButton("Secondary", variant: .secondary) {}
                    ShadButton("Destructive", variant: .destructive) {}
                    ShadButton("Outline", variant: .outline) {}
                    ShadButton("Ghost", variant: .ghost) {}
                    ShadButton("Link", variant: .link) {}
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton("Button") {}
                        ShadButton("Secondary", variant: .secondary) {}
                        ShadButton("Destructive", variant: .destructive) {}
                        ShadButton("Outline", variant: .outline) {}
                        ShadButton("Ghost", variant: .ghost) {}
                        ShadButton("Link", variant: .link) {}
                    }
                },

                DocExample(
                    "Sizes",
                    description: "xs, sm, default and lg. Heights are 28, 32, 36 and 40 points.",
                    code: #"""
                    ShadButton("Extra small", size: .xs) {}
                    ShadButton("Small", size: .sm) {}
                    ShadButton("Default") {}
                    ShadButton("Large", size: .lg) {}
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton("Extra small", size: .xs) {}
                        ShadButton("Small", size: .sm) {}
                        ShadButton("Default") {}
                        ShadButton("Large", size: .lg) {}
                    }
                },

                DocExample(
                    "Icon buttons",
                    description: "Square, label-less buttons in four sizes. Always pass an accessibility label.",
                    code: #"""
                    ShadButton(icon: .plus, variant: .outline, size: .iconXS,
                               accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .iconSM,
                               accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .icon,
                               accessibilityLabel: "Add") {}
                    ShadButton(icon: .plus, variant: .outline, size: .iconLG,
                               accessibilityLabel: "Add") {}
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton(icon: .plus, variant: .outline, size: .iconXS, accessibilityLabel: "Add") {}
                        ShadButton(icon: .plus, variant: .outline, size: .iconSM, accessibilityLabel: "Add") {}
                        ShadButton(icon: .plus, variant: .outline, size: .icon, accessibilityLabel: "Add") {}
                        ShadButton(icon: .plus, variant: .outline, size: .iconLG, accessibilityLabel: "Add") {}
                    }
                },

                DocExample(
                    "With icons",
                    description: "Leading and trailing icons scale with the button size.",
                    code: #"""
                    ShadButton("Send", icon: .send) {}
                    ShadButton("Continue", variant: .outline, trailingIcon: .arrowRight) {}
                    ShadButton("Delete", variant: .destructive, icon: .trash) {}
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton("Send", icon: .send) {}
                        ShadButton("Continue", variant: .outline, trailingIcon: .arrowRight) {}
                        ShadButton("Delete", variant: .destructive, icon: .trash) {}
                    }
                },

                DocExample(
                    "Loading",
                    description: "isLoading swaps the leading icon for a spinner and stops the action from firing.",
                    code: #"""
                    ShadButton("Please wait", isLoading: true) {}
                    ShadButton("Saving", variant: .outline, isLoading: true) {}
                    ShadButton("Deleting", variant: .destructive, isLoading: true) {}
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton("Please wait", isLoading: true) {}
                        ShadButton("Saving", variant: .outline, isLoading: true) {}
                        ShadButton("Deleting", variant: .destructive, isLoading: true) {}
                    }
                },

                DocExample(
                    "Shape and width",
                    description: "Pill corners, square corners, and a button that fills its container.",
                    code: #"""
                    ShadButton("Pill", shape: .pill) {}
                    ShadButton("Square", variant: .outline, shape: .square) {}
                    ShadButton("Full width", variant: .outline, fillsWidth: true) {}
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            ShadButton("Pill", shape: .pill) {}
                            ShadButton("Square", variant: .outline, shape: .square) {}
                            ShadButton(icon: .heart, variant: .secondary, size: .icon, shape: .pill, accessibilityLabel: "Like") {}
                        }
                        ShadButton("Full width", variant: .outline, fillsWidth: true) {}
                    }
                },

                DocExample(
                    "Disabled",
                    description: "Disabled buttons drop to 50% opacity and stop responding to the pointer.",
                    code: #"""
                    ShadButton("Disabled") {}.disabled(true)
                    ShadButton("Outline", variant: .outline) {}.disabled(true)
                    ShadButton("Ghost", variant: .ghost) {}.disabled(true)
                    """#
                ) {
                    ShadWrapLayout(spacing: 12, lineSpacing: 12) {
                        ShadButton("Disabled") {}.disabled(true)
                        ShadButton("Outline", variant: .outline) {}.disabled(true)
                        ShadButton("Ghost", variant: .ghost) {}.disabled(true)
                    }
                },

                DocExample(
                    "As a ButtonStyle",
                    description: "Any plain SwiftUI Button can adopt the styling, which is handy for Link and Menu labels.",
                    code: #"""
                    Button("Styled Button") { save() }
                        .buttonStyle(.shad(.secondary, size: .sm))

                    Button {
                        download()
                    } label: {
                        HStack(spacing: 6) {
                            ShadIconView(.download, size: 16)
                            Text("Download")
                        }
                    }
                    .buttonStyle(.shad(.outline))
                    """#
                ) {
                    HStack(spacing: 12) {
                        Button("Styled Button") {}
                            .buttonStyle(.shad(.secondary, size: .sm))
                        Button {} label: {
                            HStack(spacing: 6) {
                                ShadIconView(.download, size: 16)
                                Text("Download")
                            }
                        }
                        .buttonStyle(.shad(.outline))
                    }
                },
            ],
            notes: [
                "Heights are 24, 28, 32 and 36 points for xs, sm, default and lg — measured from the live shadcn button.",
                "Buttons carry no shadow at all, in any variant.",
                "Pressing a button sinks it one point, which is shadcn's active:translate-y-px.",
                "The destructive variant is a soft wash: a 10% destructive background with destructive text, not a solid red fill.",
                "Corner radius comes from the theme: xs and sm use radius.md, default and lg use radius.lg.",
            ],
            api: [
                DocAPI("ShadButton", [
                    DocProperty("variant", "ShadButtonVariant", default: ".default", "default, secondary, destructive, outline, ghost or link."),
                    DocProperty("size", "ShadButtonSize", default: ".default", "xs, sm, default, lg, icon, iconXS, iconSM or iconLG."),
                    DocProperty("shape", "ShadButtonShape", default: ".rounded", "rounded, pill or square."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon."),
                    DocProperty("trailingIcon", "ShadIcon?", default: "nil", "Trailing icon."),
                    DocProperty("isLoading", "Bool", default: "false", "Shows a spinner and blocks the action."),
                    DocProperty("fillsWidth", "Bool", default: "false", "Stretches to the container's width."),
                    DocProperty("action", "() -> Void", "Run when the button is pressed."),
                ]),
                DocAPI("ShadButtonStyle", summary: "The same chrome as a SwiftUI ButtonStyle: .buttonStyle(.shad(…)).", [
                    DocProperty("variant", "ShadButtonVariant", default: ".default", "As above."),
                    DocProperty("size", "ShadButtonSize", default: ".default", "As above."),
                    DocProperty("isLoading", "Bool", default: "false", "As above."),
                ]),
            ]
        )
    }

    // MARK: - Badge

    static var badge: DocComponent {
        DocComponent(
            slug: "badge",
            title: "Badge",
            summary: "Displays a badge, or a component that looks like a badge.",
            group: "Display",
            examples: [
                DocExample(
                    "Variants",
                    code: #"""
                    ShadBadge("Badge")
                    ShadBadge("Secondary", variant: .secondary)
                    ShadBadge("Destructive", variant: .destructive)
                    ShadBadge("Outline", variant: .outline)
                    ShadBadge("Ghost", variant: .ghost)
                    ShadBadge("Link", variant: .link)
                    """#
                ) {
                    ShadWrapLayout(spacing: 10, lineSpacing: 10) {
                        ShadBadge("Badge")
                        ShadBadge("Secondary", variant: .secondary)
                        ShadBadge("Destructive", variant: .destructive)
                        ShadBadge("Outline", variant: .outline)
                        ShadBadge("Ghost", variant: .ghost)
                        ShadBadge("Link", variant: .link)
                    }
                },

                DocExample(
                    "With icons",
                    description: "An icon can lead or trail the label.",
                    code: #"""
                    ShadBadge("Verified", variant: .secondary, icon: .circleCheck)
                    ShadBadge("Failed", variant: .destructive, icon: .circleX)
                    ShadBadge("8 new", variant: .outline, trailingIcon: .arrowRight)
                    """#
                ) {
                    ShadWrapLayout(spacing: 10, lineSpacing: 10) {
                        ShadBadge("Verified", variant: .secondary, icon: .circleCheck)
                        ShadBadge("Failed", variant: .destructive, icon: .circleX)
                        ShadBadge("8 new", variant: .outline, trailingIcon: .arrowRight)
                    }
                },

                DocExample(
                    "Custom content",
                    description: "The trailing-closure initialiser accepts any view — a spinner, a status dot, anything.",
                    code: #"""
                    ShadBadge(variant: .secondary) {
                        ShadSpinner(size: 10)
                        Text("Syncing")
                    }

                    ShadBadge(variant: .outline) {
                        ShadBadgeDot(Color(oklch: 0.6, 0.15, 145))
                        Text("Operational")
                    }
                    """#
                ) {
                    ShadWrapLayout(spacing: 10, lineSpacing: 10) {
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
                },


            ],
            api: [
                DocAPI("ShadBadge", [
                    DocProperty("variant", "ShadBadgeVariant", default: ".default", "default, secondary, destructive, outline, ghost or link."),
                    DocProperty("shape", "ShadButtonShape", default: ".pill", "pill (the default), rounded or square."),
                    DocProperty("color", "ShadBadgeColor?", default: "nil", "A tint that overrides the variant's colours."),
                    DocProperty("icon", "ShadIcon?", default: "nil", "Leading icon."),
                    DocProperty("trailingIcon", "ShadIcon?", default: "nil", "Trailing icon."),
                ]),
                DocAPI("ShadBadgeDot", summary: "A small solid dot for status badges.", [
                    DocProperty("color", "Color", "Dot colour."),
                    DocProperty("size", "CGFloat", default: "6", "Diameter in points."),
                ]),
            ]
        )
    }

    // MARK: - Card

    static var card: DocComponent {
        DocComponent(
            slug: "card",
            title: "Card",
            summary: "Displays a card with a header, content and footer.",
            group: "Display",
            anatomy: #"""
            ShadCard
            ├── ShadCardHeader
            │   ├── ShadCardTitle
            │   ├── ShadCardDescription
            │   └── action:  (shadcn's CardAction slot)
            ├── ShadCardContent
            └── ShadCardFooter
            """#,
            examples: [
                DocExample(
                    "Login card",
                    description: "The header's action slot holds the top-right control.",
                    width: 520,
                    code: #"""
                    ShadCard {
                        ShadCardHeader {
                            ShadCardTitle("Login to your account")
                            ShadCardDescription("Enter your email below to login.")
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
                            ShadButton("Login", fillsWidth: true) {}
                        }
                    }
                    """#
                ) {
                    ShadCard {
                        ShadCardHeader {
                            ShadCardTitle("Login to your account")
                            ShadCardDescription("Enter your email below to login.")
                        } action: {
                            ShadButton("Sign up", variant: .link, size: .sm) {}
                        }
                        ShadCardContent {
                            ShadFieldGroup(spacing: 14) {
                                ShadField {
                                    ShadFieldLabel("Email")
                                    ShadInput("m@example.com", text: .constant(""))
                                }
                                ShadField {
                                    ShadFieldLabel("Password")
                                    ShadInput("", text: .constant(""), isSecure: true)
                                }
                            }
                        }
                        ShadCardFooter {
                            ShadButton("Login", fillsWidth: true) {}
                        }
                    }
                },

                DocExample(
                    "Sizes",
                    description: "The size prop drives --card-spacing: 24pt for default, 16pt for sm.",
                    code: #"""
                    ShadCard { … }             // --card-spacing: 24
                    ShadCard(size: .sm) { … }  // --card-spacing: 16
                    ShadCard(spacing: 32) { … }
                    """#
                ) {
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
                },

                DocExample(
                    "Terms of Service",
                    description: "A scrolling body between a fixed header and a footer that carries the agreement control.",
                    width: 600,
                    code: #"""
                    ShadCard {
                        ShadCardHeader(showsSeparator: true) {
                            ShadCardTitle("Terms of Service")
                            ShadCardDescription("Last updated: 3 December 2025")
                        }
                        ShadCardContent {
                            ScrollView { … }.frame(height: 180)
                        }
                        ShadCardFooter(showsSeparator: true) {
                            ShadCheckbox("I agree to the terms", isOn: $agreed)
                            Spacer()
                            ShadButton("Decline", variant: .outline, size: .sm) {}
                            ShadButton("Accept", size: .sm) {}
                        }
                    }
                    """#
                ) {
                    ShadCard {
                        ShadCardHeader(showsSeparator: true) {
                            ShadCardTitle("Terms of Service")
                            ShadCardDescription("Last updated: 3 December 2025")
                        }
                        ShadCardContent {
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
                        }
                        ShadCardFooter(showsSeparator: true) {
                            ShadCheckbox("I agree to the terms", isOn: .constant(true))
                            Spacer()
                            ShadButton("Decline", variant: .outline, size: .sm) {}
                            ShadButton("Accept", size: .sm) {}
                        }
                    }
                },

                DocExample(
                    "With an image",
                    description: "Artwork above the header, bleeding to the card's edges.",
                    width: 460,
                    code: #"""
                    ShadCard(spacing: 16) {
                        Image("aurora")
                            .resizable().scaledToFill()
                            .frame(height: 140)
                            .padding(.top, -16)          // bleed past the card's top padding
                        ShadCardHeader {
                            ShadCardTitle("Northern lights")
                            ShadCardDescription("Tromsø, Norway · 4 min read")
                        }
                        ShadCardFooter {
                            ShadAvatarGroup { … }
                            Spacer()
                            ShadButton("Read", variant: .outline, size: .sm,
                                       trailingIcon: .arrowRight) {}
                        }
                    }
                    """#
                ) {
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
                },

                DocExample(
                    "With separators",
                    description: "Header and footer can each draw a rule against the body.",
                    width: 600,
                    code: #"""
                    ShadCard {
                        ShadCardHeader(showsSeparator: true) {
                            ShadCardTitle("Team members")
                            ShadCardDescription("Invite your team to collaborate.")
                        } action: {
                            ShadBadge("3 seats", variant: .secondary)
                        }
                        ShadCardContent { … }
                        ShadCardFooter(showsSeparator: true) {
                            ShadButton("Invite", size: .sm, icon: .plus) {}
                        }
                    }
                    """#
                ) {
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
                },
            ],
            notes: [
                "Header, content and footer read --card-spacing from the environment, so they always share the card's horizontal padding.",
            ],
            api: [
                DocAPI("ShadCard", [
                    DocProperty("size", "ShadCardSize", default: ".default", "default (24pt) or sm (16pt)."),
                    DocProperty("spacing", "CGFloat?", default: "nil", "Overrides the size's spacing."),
                ]),
                DocAPI("ShadCardHeader", [
                    DocProperty("showsSeparator", "Bool", default: "false", "Draws a rule beneath the header."),
                    DocProperty("action", "() -> View", default: "EmptyView()", "Top-right slot."),
                ]),
                DocAPI("ShadCardFooter", [
                    DocProperty("showsSeparator", "Bool", default: "false", "Draws a rule above the footer."),
                ]),
            ]
        )
    }

    // MARK: - Avatar

    static var avatar: DocComponent {
        DocComponent(
            slug: "avatar",
            title: "Avatar",
            summary: "An image element with a fallback for representing the user.",
            group: "Display",
            examples: [
                DocExample(
                    "Sizes",
                    description: "sm (24pt), default (32pt) and lg (40pt), or any custom point size.",
                    code: #"""
                    ShadAvatar(fallback: "CN", size: .sm)
                    ShadAvatar(fallback: "CN")
                    ShadAvatar(fallback: "CN", size: .lg)
                    ShadAvatar(fallback: "CN", customSize: 64)
                    """#
                ) {
                    HStack(spacing: 16) {
                        ShadAvatar(fallback: "CN", size: .sm)
                        ShadAvatar(fallback: "CN")
                        ShadAvatar(fallback: "CN", size: .lg)
                        ShadAvatar(fallback: "CN", customSize: 64)
                    }
                },

                DocExample(
                    "Image and fallbacks",
                    description: "A remote image loads over the fallback; when it fails the initials, an icon, or a symbol tile remain.",
                    code: #"""
                    ShadAvatar(image: .url(url), fallback: "CN")
                    ShadAvatar(fallback: "EV")
                    ShadAvatar()                                  // person icon
                    ShadAvatar(image: .symbol(.bot), size: .lg)
                    ShadAvatar(fallback: "SQ", size: .lg, shape: .rounded)
                    """#
                ) {
                    HStack(spacing: 16) {
                        ShadAvatar(fallback: "EV")
                        ShadAvatar()
                        ShadAvatar(image: .symbol(.bot), size: .lg)
                        ShadAvatar(fallback: "SQ", size: .lg, shape: .rounded)
                    }
                },

                DocExample(
                    "Badges",
                    description: "A presence dot, or a tiny icon, in any corner.",
                    code: #"""
                    ShadAvatar(fallback: "CN", size: .lg)
                        .badge(color: Color(oklch: 0.7, 0.16, 150))

                    ShadAvatar(fallback: "AB", size: .lg)
                        .badge(icon: .check)

                    ShadAvatar(fallback: "TP", size: .lg)
                        .badge(icon: .bell, alignment: .topTrailing)
                    """#
                ) {
                    HStack(spacing: 20) {
                        ShadAvatar(fallback: "CN", size: .lg)
                            .badge(color: Color(oklch: 0.7, 0.16, 150))
                        ShadAvatar(fallback: "LR", size: .lg)
                            .badge(color: Color(oklch: 0.75, 0.17, 70))
                        ShadAvatar(fallback: "AB", size: .lg)
                            .badge(icon: .check)
                        ShadAvatar(fallback: "TP", size: .lg)
                            .badge(icon: .bell, alignment: .topTrailing)
                    }
                },

                DocExample(
                    "Group",
                    description: "Overlapping avatars, closed with a count.",
                    code: #"""
                    ShadAvatarGroup {
                        ShadAvatar(fallback: "CN")
                        ShadAvatar(fallback: "LR")
                        ShadAvatarGroupCount(3)
                    }
                    """#
                ) {
                    HStack(spacing: 28) {
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
                            ShadAvatarGroupCount(12, size: .lg)
                        }
                    }
                },
            ],
            api: [
                DocAPI("ShadAvatar", [
                    DocProperty("image", "ShadAvatarImage", default: ".none", ".none, .url(URL), .resource(String) or .symbol(ShadIcon)."),
                    DocProperty("fallback", "String", default: "\"\"", "Initials shown when there is no image."),
                    DocProperty("size", "ShadAvatarSize", default: ".default", "sm, default or lg."),
                    DocProperty("customSize", "CGFloat?", default: "nil", "Overrides size with an exact diameter."),
                    DocProperty("shape", "ShadButtonShape", default: ".pill", "pill (circle), rounded or square."),
                    DocProperty("badge(color:icon:alignment:)", "ShadAvatar", "Adds a status indicator."),
                ]),
            ]
        )
    }

    // MARK: - Item

    static var item: DocComponent {
        DocComponent(
            slug: "item",
            title: "Item",
            summary: "A flex container for a title, a description and some actions.",
            group: "Display",
            anatomy: #"""
            ShadItemGroup
            └── ShadItem
                ├── .header { … }
                ├── ShadItemMedia
                ├── ShadItemContent
                │   ├── ShadItemTitle
                │   └── ShadItemDescription
                ├── ShadItemActions
                └── .footer { … }
            """#,
            examples: [
                DocExample(
                    "Variants",
                    description: "default is transparent, outline adds a border, muted fills with the muted colour.",
                    code: #"""
                    ShadItem {                       // default
                        ShadItemMedia(icon: .bell)
                        ShadItemContent {
                            ShadItemTitle("Default")
                            ShadItemDescription("Transparent, no border.")
                        }
                        ShadItemActions {
                            ShadButton("Action", variant: .outline, size: .sm) {}
                        }
                    }

                    ShadItem(variant: .outline) { … }
                    ShadItem(variant: .muted) { … }
                    """#
                ) {
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
                },

                DocExample(
                    "Sizes",
                    description: "default, sm and xs tighten the padding and the gap.",
                    code: #"""
                    ShadItem(variant: .outline) { … }             // default
                    ShadItem(variant: .outline, size: .sm) { … }
                    ShadItem(variant: .outline, size: .xs) { … }
                    """#
                ) {
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
                },

                DocExample(
                    "Header and footer",
                    description: "Optional slots above and below the row, added with modifiers.",
                    code: #"""
                    ShadItem(variant: .outline) {
                        ShadItemMedia(icon: .gitPullRequest)
                        ShadItemContent {
                            ShadItemTitle("Add OKLCH theme tokens")
                            ShadItemDescription("Converts the shadcn palette at build time.")
                        }
                        ShadItemActions { ShadBadge("Open", variant: .secondary) }
                    }
                    .header { Text("PULL REQUEST #128") }
                    .footer { Text("Opened 3 days ago · 4 files changed") }
                    """#
                ) {
                    ShadItem(variant: .outline) {
                        ShadItemMedia(icon: .gitPullRequest)
                        ShadItemContent {
                            ShadItemTitle("Add OKLCH theme tokens")
                            ShadItemDescription("Converts the shadcn palette at build time.")
                        }
                        ShadItemActions { ShadBadge("Open", variant: .secondary) }
                    }
                    .header { Text("PULL REQUEST #128") }
                    .footer { Text("Opened 3 days ago · 4 files changed") }
                },

                DocExample(
                    "Grouped and clickable",
                    description: "ShadItemGroup stacks rows; passing an action makes a row behave like a button.",
                    code: #"""
                    ShadItemGroup(isBordered: true) {
                        ShadItem(size: .sm, action: { open() }) {
                            ShadItemMedia(icon: .settings, size: 32)
                            ShadItemContent {
                                ShadItemTitle("Preferences")
                                ShadItemDescription("Theme, shortcuts and defaults")
                            }
                            ShadItemActions { ShadIconView(.chevronRight, size: 14) }
                        }
                        ShadItemSeparator()
                        ShadItem(size: .sm, action: { open() }) { … }
                    }
                    """#
                ) {
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
                },
            ],
            notes: [
                "Item is a layout container, not a form control. Use ShadField when you need a label bound to an input.",
            ],
            api: [
                DocAPI("ShadItem", [
                    DocProperty("variant", "ShadItemVariant", default: ".default", "default, outline or muted."),
                    DocProperty("size", "ShadItemSize", default: ".default", "default, sm or xs."),
                    DocProperty("action", "(() -> Void)?", default: "nil", "Makes the row hoverable and clickable."),
                    DocProperty(".header { }", "ShadItem", "Content above the row."),
                    DocProperty(".footer { }", "ShadItem", "Content below the row."),
                ]),
                DocAPI("ShadItemMedia", [
                    DocProperty("variant", "Variant", default: ".default", "default (bare), icon (muted tile) or image."),
                    DocProperty("size", "CGFloat", default: "40", "Tile size in points."),
                ]),
                DocAPI("ShadItemGroup", [
                    DocProperty("spacing", "CGFloat", default: "0", "Gap between rows."),
                    DocProperty("isBordered", "Bool", default: "false", "Wraps the group in one bordered card."),
                ]),
            ]
        )
    }

    // MARK: - Spinner

    static var spinner: DocComponent {
        DocComponent(
            slug: "spinner",
            title: "Spinner",
            summary: "An indeterminate loading indicator.",
            group: "Display",
            examples: [
                DocExample(
                    "Styles",
                    description: "arc is the default and matches Lucide's loader-circle.",
                    code: #"""
                    ShadSpinner()                       // .arc
                    ShadSpinner(style: .spokes)
                    ShadSpinner(style: .dots)
                    """#
                ) {
                    HStack(spacing: 32) {
                        ShadSpinner(size: 24)
                        ShadSpinner(size: 24, style: .spokes)
                        ShadSpinner(size: 24, style: .dots)
                    }
                },

                DocExample(
                    "Sizes",
                    description: "Any point size. The stroke width scales with it unless you override lineWidth.",
                    code: #"""
                    ShadSpinner(size: 12)
                    ShadSpinner(size: 16)     // default
                    ShadSpinner(size: 24)
                    ShadSpinner(size: 48, lineWidth: 3)
                    """#
                ) {
                    HStack(spacing: 24) {
                        ShadSpinner(size: 12)
                        ShadSpinner(size: 16)
                        ShadSpinner(size: 24)
                        ShadSpinner(size: 32)
                        ShadSpinner(size: 48)
                    }
                },

                DocExample(
                    "In other components",
                    description: "Buttons, badges and items all take a spinner directly.",
                    code: #"""
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
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            ShadButton("Please wait", isLoading: true) {}
                            ShadBadge(variant: .secondary) {
                                ShadSpinner(size: 10)
                                Text("Processing")
                            }
                        }
                        ShadItem(variant: .outline, size: .sm) {
                            ShadItemMedia { ShadSpinner(size: 18) }
                            ShadItemContent {
                                ShadItemTitle("Indexing repository")
                                ShadItemDescription("1,204 of 3,880 files")
                            }
                        }
                        .frame(width: 340)
                    }
                },
            ],
            notes: [
                "The animation stops entirely when the theme's motion is disabled (ShadMotion.none), which is what the snapshots in these docs use.",
            ],
            api: [
                DocAPI("ShadSpinner", [
                    DocProperty("size", "CGFloat", default: "16", "Diameter in points."),
                    DocProperty("style", "Style", default: ".arc", "arc, spokes or dots."),
                    DocProperty("color", "Color?", default: "nil", "Defaults to mutedForeground."),
                    DocProperty("lineWidth", "CGFloat?", default: "nil", "Defaults to size / 8."),
                ]),
            ]
        )
    }
}
