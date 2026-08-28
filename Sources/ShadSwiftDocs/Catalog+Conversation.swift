import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var conversation: [DocComponent] {
        [bubble, message, marker, messageScroller]
    }

    // MARK: - Bubble

    static var bubble: DocComponent {
        DocComponent(
            slug: "bubble",
            title: "Bubble",
            summary: "The message surface: seven variants, two alignments, optional reactions.",
            group: "Conversation",
            anatomy: #"""
            ShadBubbleGroup
            └── ShadBubble
                ├── ShadBubbleContent
                └── ShadBubbleReactions
            """#,
            examples: [
                DocExample(
                    "Variants",
                    description: "ghost drops the frame and the width cap, which is what you want for long assistant answers.",
                    width: 760,
                    code: #"""
                    ShadBubble(variant: .default) { ShadBubbleContent("…") }
                    ShadBubble(variant: .received) { … }
                    ShadBubble(variant: .muted) { … }
                    ShadBubble(variant: .tinted) { … }
                    ShadBubble(variant: .outline) { … }
                    ShadBubble(variant: .ghost) { … }
                    ShadBubble(variant: .destructive) { … }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        bubbleRow(.sent, "The current user's bubble — blue by default.")
                        bubbleRow(.received, "The other party's bubble — grey by default.")
                        bubbleRow(.default, "A strong primary bubble.")
                        bubbleRow(.secondary, "Standard neutral conversation content.")
                        bubbleRow(.muted, "Lower-emphasis supporting content.")
                        bubbleRow(.tinted, "A subtle primary tint.")
                        bubbleRow(.outline, "A bordered variant for secondary content.")
                        bubbleRow(.ghost, "Unframed content spanning the full width.")
                        bubbleRow(.destructive, "An error or a failed action.")
                    }
                },

                DocExample(
                    "Alignment",
                    description: "start for the receiver, end for the sender. Bubbles hug their text and cap at 80% of the container's width.",
                    width: 700,
                    code: #"""
                    ShadBubble(variant: .sent, align: .end) {
                        ShadBubbleContent("Deploying to prod real quick.")
                    }
                    ShadBubble(variant: .received, align: .start) {
                        ShadBubbleContent("It's 4:55 PM. On a Friday.")
                    }
                    ShadBubble(variant: .sent, align: .end) {
                        ShadBubbleContent("It's a one-line change.")
                    }
                    ShadBubble(variant: .received, align: .start) {
                        ShadBubbleContent("It's always a one-line change 😭.")
                    }
                    """#
                ) {
                    VStack(spacing: 10) {
                        ShadBubble(variant: .sent, align: .end) {
                            ShadBubbleContent("Deploying to prod real quick.")
                        }
                        ShadBubble(variant: .received, align: .start) {
                            ShadBubbleContent("It's 4:55 PM. On a Friday.")
                        }
                        ShadBubble(variant: .sent, align: .end) {
                            ShadBubbleContent("It's a one-line change.")
                        }
                        ShadBubble(variant: .received, align: .start) {
                            ShadBubbleContent("It's always a one-line change 😭.")
                        }
                    }
                },

                DocExample(
                    "Groups and reactions",
                    width: 700,
                    code: #"""
                    ShadBubbleGroup(align: .start) {
                        ShadBubble(variant: .received) { ShadBubbleContent("Three things:") }
                        ShadBubble(variant: .received) { ShadBubbleContent("1. The OKLCH converter") }
                        ShadBubble(variant: .received) { ShadBubbleContent("2. The popover host") }
                    }

                    ShadBubble(variant: .sent, align: .end) {
                        ShadBubbleContent("Shipping it 🚀")
                    }
                    ShadBubbleReactions(["👍", "🎉"])
                    """#
                ) {
                    VStack(spacing: 10) {
                        ShadBubbleGroup(align: .start) {
                            ShadBubble(variant: .received) { ShadBubbleContent("Three things to look at:") }
                            ShadBubble(variant: .received) { ShadBubbleContent("1. The OKLCH converter") }
                            ShadBubble(variant: .received) { ShadBubbleContent("2. The popover panel host") }
                        }
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: -8) {
                                ShadBubble(variant: .sent, align: .end) {
                                    ShadBubbleContent("Shipping it 🚀")
                                }
                                ShadBubbleReactions(["👍", "🎉"]).padding(.trailing, 8)
                            }
                        }
                    }
                },
            ],
            notes: [
                "Bubbles are generously rounded: shadcn's rounded-3xl, which is 22pt against the default 10pt radius. The whole scale moves with the theme.",
                "The destructive and tinted variants are washes, not solid fills.",
            ],
            api: [
                DocAPI("ShadBubble", [
                    DocProperty("variant", "ShadBubbleVariant", default: ".secondary", "default, secondary, muted, tinted, outline, ghost or destructive."),
                    DocProperty("align", "ShadBubbleAlignment", default: ".start", "start or end."),
                    DocProperty("maxWidthFraction", "CGFloat", default: "0.8", "Width cap; ghost ignores it."),
                ]),
                DocAPI("ShadBubbleReactions", [
                    DocProperty("reactions", "[String]", "Emoji shown in a pill against the bubble's edge."),
                ]),
            ]
        )
    }

    // MARK: - Message

    static var message: DocComponent {
        DocComponent(
            slug: "message",
            title: "Message",
            summary: "Lays out one message: avatar, header, bubble and footer.",
            group: "Conversation",
            anatomy: #"""
            ShadMessageGroup
            └── ShadMessage(align:)
                ├── ShadMessageAvatar
                └── ShadMessageContent
                    ├── ShadMessageHeader
                    ├── ShadBubble
                    └── ShadMessageFooter
            """#,
            examples: [
                DocExample(
                    "A conversation",
                    description: "The shadcn demo, with a reaction and a live typing indicator.",
                    width: 700,
                    code: #"""
                    ShadMessage(align: .end) {
                        ShadMessageContent {
                            ShadBubble(variant: .sent, align: .end) {
                                ShadBubbleContent("Deploying to prod real quick.")
                            }
                        }
                        ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                    }

                    // hasFooter lifts the avatar so it stays level with the bubble.
                    ShadMessage(align: .end, hasFooter: true) {
                        ShadMessageContent {
                            ShadBubble(variant: .sent, align: .end) {
                                ShadBubbleContent("It's a one-line change.")
                            }
                            ShadMessageFooter("Delivered")
                        }
                        ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                    }

                    ShadTypingIndicator("Oliver is typing…")
                    """#
                ) {
                    VStack(spacing: 14) {
                        ShadMessage(align: .end) {
                            ShadMessageContent {
                                ShadBubble(variant: .sent, align: .end) {
                                    ShadBubbleContent("Deploying to prod real quick.")
                                }
                            }
                            ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                        }
                        ShadMessage {
                            ShadMessageAvatar { ShadAvatar(fallback: "OL") }
                            ShadMessageContent {
                                ShadBubble(variant: .received) {
                                    ShadBubbleContent("It's 4:55 PM. On a Friday.")
                                }
                            }
                        }
                        ShadMessage(align: .end, hasFooter: true) {
                            ShadMessageContent {
                                ShadBubble(variant: .sent, align: .end) {
                                    ShadBubbleContent("It's a one-line change.")
                                }
                                ShadMessageFooter("Delivered")
                            }
                            ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                        }
                        ShadMessage {
                            ShadMessageAvatar { ShadAvatar(fallback: "OL") }
                            ShadMessageContent {
                                VStack(alignment: .leading, spacing: -10) {
                                    ShadBubble(variant: .received) {
                                        ShadBubbleContent("It's always a one-line change 😭.")
                                    }
                                    ShadBubbleReactions(["👍"]).padding(.leading, 10)
                                }
                            }
                        }
                        ShadTypingIndicator("Oliver is typing…")
                    }
                },

                DocExample(
                    "Alignment",
                    description: "Put the avatar before the content for a received message, after it for a sent one.",
                    width: 700,
                    code: #"""
                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(fallback: "CN") }
                        ShadMessageContent {
                            ShadBubble(variant: .received) {
                                ShadBubbleContent("How can I help you today?")
                            }
                        }
                    }

                    ShadMessage(align: .end) {
                        ShadMessageContent {
                            ShadBubble(variant: .sent, align: .end) {
                                ShadBubbleContent("I want to theme the whole app from one struct.")
                            }
                        }
                        ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                    }
                    """#
                ) {
                    VStack(spacing: 14) {
                        ShadMessage {
                            ShadMessageAvatar { ShadAvatar(fallback: "CN") }
                            ShadMessageContent {
                                ShadBubble(variant: .received) {
                                    ShadBubbleContent("How can I help you today?")
                                }
                            }
                        }
                        ShadMessage(align: .end) {
                            ShadMessageContent {
                                ShadBubble(variant: .sent, align: .end) {
                                    ShadBubbleContent("I want to theme the whole app from one struct.")
                                }
                            }
                            ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                        }
                    }
                },

                DocExample(
                    "Header and footer",
                    description: "The header stays left-aligned whichever side the message is on; the footer follows the message.",
                    width: 700,
                    code: #"""
                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(fallback: "OL") }
                        ShadMessageContent {
                            ShadMessageHeader("Olivia")
                            ShadBubble(variant: .received) { ShadBubbleContent("…") }
                            ShadMessageFooter("Read yesterday")
                        }
                    }

                    ShadMessageFooter {
                        ShadButton(icon: .copy, variant: .ghost, size: .iconXS,
                                   accessibilityLabel: "Copy") {}
                        Text("2:14 PM")
                    }
                    """#
                ) {
                    VStack(spacing: 18) {
                        ShadMessage {
                            ShadMessageAvatar { ShadAvatar(fallback: "OL") }
                            ShadMessageContent {
                                ShadMessageHeader("Olivia")
                                ShadBubble(variant: .received) {
                                    ShadBubbleContent("The design tokens are in. Radius and colours both come from the theme.")
                                }
                                ShadMessageFooter("Read yesterday")
                            }
                        }
                        ShadMessage(align: .end) {
                            ShadMessageContent {
                                ShadMessageHeader("You")
                                ShadBubble(variant: .sent, align: .end) {
                                    ShadBubbleContent("Perfect.")
                                }
                                ShadMessageFooter {
                                    ShadButton(icon: .copy, variant: .ghost, size: .iconXS, accessibilityLabel: "Copy") {}
                                    ShadButton(icon: .refresh, variant: .ghost, size: .iconXS, accessibilityLabel: "Retry") {}
                                    Text("2:14 PM")
                                }
                            }
                            ShadMessageAvatar { ShadAvatar(fallback: "EZ") }
                        }
                    }
                },

                DocExample(
                    "Assistant style",
                    description: "A ghost bubble spans the full width, which suits long-form answers.",
                    width: 700,
                    code: #"""
                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(image: .symbol(.sparkles)) }
                        ShadMessageContent {
                            ShadMessageHeader("Assistant")
                            ShadBubble(variant: .ghost) { ShadBubbleContent("…") }
                            ShadMessageFooter {
                                ShadMarker {
                                    ShadMarkerIcon(.check)
                                    ShadMarkerContent("Answered in 1.2s")
                                }
                            }
                        }
                    }
                    """#
                ) {
                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(image: .symbol(.sparkles)) }
                        ShadMessageContent {
                            ShadMessageHeader("Assistant")
                            ShadBubble(variant: .ghost) {
                                ShadBubbleContent("ShadSwift resolves a ShadThemeSet against the ambient color scheme, then hands the flattened ShadTheme down the environment. Components never read colours directly, which is what makes a single radius slider retheme the whole gallery.")
                            }
                            ShadMessageFooter {
                                ShadMarker {
                                    ShadMarkerIcon(.check)
                                    ShadMarkerContent("Answered in 1.2s")
                                }
                            }
                        }
                    }
                },
            ],
            api: [
                DocAPI("ShadMessage", [
                    DocProperty("align", "ShadMessageAlignment", default: ".start", "start or end."),
                    DocProperty("spacing", "CGFloat", default: "8", "Gap between avatar and content."),
                    DocProperty("hasFooter", "Bool", default: "false", "Lifts the avatar so it stays level with the bubble."),
                ]),
                DocAPI("ShadTypingIndicator", summary: "Three pulsing dots and an optional name.", [
                    DocProperty("label", "String?", default: "nil", "e.g. \"Oliver is typing…\"."),
                ]),
                DocAPI("ShadMessageGroup", [
                    DocProperty("spacing", "CGFloat", default: "3", "Tight gap for consecutive messages from one sender."),
                ]),
            ]
        )
    }

    // MARK: - Marker

    static var marker: DocComponent {
        DocComponent(
            slug: "marker",
            title: "Marker",
            summary: "An inline status, system note, bordered row or labelled separator in a conversation.",
            group: "Conversation",
            anatomy: #"""
            ShadMarker(variant:action:)
            ├── ShadMarkerIcon
            └── ShadMarkerContent
            """#,
            examples: [
                DocExample(
                    "Variants",
                    description: "default is inline, border adds a rule underneath, separator centres the label between two lines.",
                    width: 700,
                    code: #"""
                    ShadMarker {
                        ShadMarkerIcon(.check)
                        ShadMarkerContent("Explored 4 files")
                    }

                    ShadMarker(variant: .border) {
                        ShadMarkerIcon(.gitBranch)
                        ShadMarkerContent("Switched to branch feature/theme-tokens")
                    }

                    ShadMarker(variant: .separator) {
                        ShadMarkerContent("Today")
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        ShadMarker {
                            ShadMarkerIcon(.check)
                            ShadMarkerContent("Explored 4 files")
                        }
                        ShadMarker(variant: .border) {
                            ShadMarkerIcon(.gitBranch)
                            ShadMarkerContent("Switched to branch feature/theme-tokens")
                        }
                        ShadMarker(variant: .separator) {
                            ShadMarkerContent("Today")
                        }
                    }
                },

                DocExample(
                    "Streaming status",
                    description: "Pair with a spinner for progress, and set shimmer for streaming text.",
                    width: 700,
                    code: #"""
                    ShadMarker {
                        ShadMarkerIcon { ShadSpinner(size: 12) }
                        ShadMarkerContent("Running the test suite…")
                    }

                    ShadMarker {
                        ShadMarkerIcon { ShadSpinner(size: 12, style: .dots) }
                        ShadMarkerContent("Thinking", shimmer: true)
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadMarker {
                            ShadMarkerIcon { ShadSpinner(size: 12) }
                            ShadMarkerContent("Running the test suite…")
                        }
                        ShadMarker {
                            ShadMarkerIcon { ShadSpinner(size: 12, style: .dots) }
                            ShadMarkerContent("Thinking", shimmer: true)
                        }
                    }
                },

                DocExample(
                    "Interactive",
                    description: "Give a marker an action and it behaves like a link.",
                    width: 700,
                    code: #"""
                    ShadMarker(action: { open(pullRequest) }) {
                        ShadMarkerIcon(.gitPullRequest)
                        ShadMarkerContent("View the pull request")
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadMarker(action: {}) {
                            ShadMarkerIcon(.gitPullRequest)
                            ShadMarkerContent("View the pull request")
                        }
                        ShadMarker(action: {}) {
                            ShadMarkerIcon(.file)
                            ShadMarkerContent("Open Sources/ShadSwift/Theme/OKLCH.swift")
                        }
                    }
                },

                DocExample(
                    "In a transcript",
                    description: "Markers are designed to sit between messages.",
                    width: 700,
                    code: #"""
                    ShadMarker(variant: .separator) { ShadMarkerContent("Yesterday") }
                    ShadMessage { … }
                    ShadMarker {
                        ShadMarkerIcon(.check)
                        ShadMarkerContent("Converted 38 tokens")
                    }
                    ShadMessage(align: .end) { … }
                    """#
                ) {
                    VStack(spacing: 12) {
                        ShadMarker(variant: .separator) { ShadMarkerContent("Yesterday") }
                        ShadMessage {
                            ShadMessageAvatar { ShadAvatar(fallback: "CN") }
                            ShadMessageContent {
                                ShadBubble(variant: .received) { ShadBubbleContent("Can you convert the palette?") }
                            }
                        }
                        ShadMarker {
                            ShadMarkerIcon(.check)
                            ShadMarkerContent("Converted 38 tokens")
                        }
                        ShadMessage(align: .end) {
                            ShadMessageContent {
                                ShadBubble(variant: .sent, align: .end) { ShadBubbleContent("Done — all in OKLCH now.") }
                            }
                        }
                    }
                },
            ],
            notes: [
                "View.shadShimmer() applies the same sweep to any view.",
            ],
            api: [
                DocAPI("ShadMarker", [
                    DocProperty("variant", "ShadMarkerVariant", default: ".default", "default, border or separator."),
                    DocProperty("action", "(() -> Void)?", default: "nil", "Turns the marker into a link."),
                ]),
                DocAPI("ShadMarkerContent", [
                    DocProperty("shimmer", "Bool", default: "false", "Sweeps a highlight across the text while it streams."),
                ]),
            ]
        )
    }

    // MARK: - Message scroller

    static var messageScroller: DocComponent {
        DocComponent(
            slug: "message-scroller",
            title: "Message Scroller",
            summary: "A transcript container for streaming conversations: anchoring, auto-scroll, history loading and jump-to.",
            group: "Conversation",
            anatomy: #"""
            ShadMessageScrollerProvider(model)
            └── ShadMessageScroller
                ├── ShadMessageScrollerViewport
                │   └── ShadMessageScrollerContent(ids:)
                │       └── ShadMessageScrollerItem(messageId:scrollAnchor:)
                └── ShadMessageScrollerButton
            """#,
            examples: [
                DocExample(
                    "Complete transcript",
                    description: "The ids array is what lets the scroller tell an append from a prepend, so history loading never moves the reader.",
                    width: 760,
                    height: 460,
                    code: #"""
                    @StateObject private var scroller = ShadMessageScrollerModel(
                        autoScroll: true,
                        defaultScrollPosition: .lastAnchor,
                        scrollPreviousItemPeek: 40
                    )

                    ShadMessageScrollerProvider(scroller) {
                        ShadMessageScroller(isBordered: true) {
                            ShadMessageScrollerViewport {
                                ShadMessageScrollerContent(ids: messages.map(\.id)) {
                                    ForEach(messages) { message in
                                        ShadMessageScrollerItem(
                                            messageId: message.id,
                                            scrollAnchor: message.role == .user
                                        ) {
                                            ShadMessage(align: message.role == .user ? .end : .start) {
                                                …
                                            }
                                        }
                                    }
                                }
                            }
                            ShadMessageScrollerButton(edge: .end, title: "Latest")
                        }
                    }
                    """#
                ) {
                    DocTranscriptPreview()
                },

                DocExample(
                    "Driving it from code",
                    code: #"""
                    scroller.scrollToEnd()
                    scroller.scrollToStart()
                    scroller.scrollToMessage(id, anchor: .top)

                    scroller.autoScroll = false          // stop following the live edge
                    scroller.isAtEnd                     // is the reader at the bottom?
                    scroller.visibleMessageIds           // what is on screen
                    scroller.currentAnchorId             // the anchored turn in view
                    scroller.scrollable                  // (start: Bool, end: Bool)

                    scroller.onReachStart = { loadOlderMessages() }
                    """#
                ),
            ],
            notes: [
                "The button only appears when that edge is off screen.",
                "Rows are laid out in a LazyVStack, so long transcripts stay cheap.",
            ],
            api: [
                DocAPI("ShadMessageScrollerModel", [
                    DocProperty("autoScroll", "Bool", default: "true", "Follow the live edge while streaming; released when the reader scrolls away."),
                    DocProperty("defaultScrollPosition", "ShadScrollPosition", default: ".end", "end, start or lastAnchor."),
                    DocProperty("scrollPreviousItemPeek", "CGFloat", default: "0", "Points of the previous row left visible when an anchor scrolls up."),
                    DocProperty("preserveScrollOnPrepend", "Bool", default: "true", "Hold the reader's place when history is inserted at the top."),
                    DocProperty("onReachStart", "(() -> Void)?", default: "nil", "Fires when the first row becomes visible."),
                ]),
                DocAPI("ShadMessageScrollerContent", [
                    DocProperty("ids", "[ID]", "The ordered message ids. Required — this is how appends and prepends are told apart."),
                    DocProperty("spacing", "CGFloat", default: "16", "Gap between rows."),
                ]),
                DocAPI("ShadMessageScrollerItem", [
                    DocProperty("messageId", "ID", "Used for scroll-to and visibility tracking."),
                    DocProperty("scrollAnchor", "Bool", default: "false", "Marks a turn that should settle near the top when it arrives."),
                ]),
                DocAPI("ShadMessageScrollerButton", [
                    DocProperty("edge", "Edge", default: ".end", "end or start."),
                    DocProperty("title", "String?", default: "nil", "Optional label beside the arrow."),
                ]),
            ]
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    static func bubbleRow(_ variant: ShadBubbleVariant, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(describing: variant))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)
                .padding(.top, 7)
            ShadBubble(variant: variant) { ShadBubbleContent(text) }
        }
    }
}

/// A static transcript used for the Message Scroller snapshot.
private struct DocTranscriptPreview: View {
    @Environment(\.shadTheme) private var theme

    private struct Row: Identifiable {
        let id: Int
        let isUser: Bool
        let text: String
    }

    private let rows: [Row] = [
        Row(id: 1, isUser: true, text: "Can you walk me through how theming works?"),
        Row(id: 2, isUser: false, text: "A ShadThemeSet holds a light palette, a dark palette, and the shape and type decisions shared between them."),
        Row(id: 3, isUser: true, text: "And the components?"),
        Row(id: 4, isUser: false, text: "They read the resolved ShadTheme from the environment. That is the whole contract — no component owns a colour."),
        Row(id: 5, isUser: true, text: "What about corner radius?"),
    ]

    var body: some View {
        ShadMessageScrollerProvider(ShadMessageScrollerModel()) {
            ShadMessageScroller(isBordered: true) {
                ShadMessageScrollerViewport {
                    ShadMessageScrollerContent(ids: rows.map(\.id)) {
                        ForEach(rows) { row in
                            ShadMessageScrollerItem(messageId: row.id, scrollAnchor: row.isUser) {
                                if row.isUser {
                                    ShadMessage(align: .end) {
                                        ShadMessageContent {
                                            ShadBubble(variant: .sent, align: .end) {
                                                ShadBubbleContent(row.text)
                                            }
                                        }
                                        ShadMessageAvatar { ShadAvatar(fallback: "EZ", size: .sm) }
                                    }
                                } else {
                                    ShadMessage {
                                        ShadMessageAvatar { ShadAvatar(image: .symbol(.sparkles), size: .sm) }
                                        ShadMessageContent {
                                            ShadBubble(variant: .ghost) { ShadBubbleContent(row.text) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                HStack(spacing: 6) {
                    ShadIconView(.arrowDown, size: 14)
                    Text("Latest").font(theme.font(theme.typography.xs, .medium))
                }
                .foregroundStyle(theme.colors.popoverForeground)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(theme.colors.popover))
                .overlay(Capsule().strokeBorder(theme.colors.border, lineWidth: theme.borderWidth))
                .shadShadow(theme.shadows.md)
                .padding(.bottom, 12)
            }
        }
    }
}
