import SwiftUI
import ShadSwift

// MARK: - Bubble

struct BubblePage: View {
    var body: some View {
        DemoPage(title: "Bubble", subtitle: "The message surface: seven variants, two alignments, optional reactions.") {
            DemoSection("Variants", description: "Bubbles are generously rounded — shadcn's rounded-3xl, 22pt against the default radius.") {
                VStack(alignment: .leading, spacing: 12) {
                    bubble(.sent, "The current user's bubble — blue by default, on the right.")
                    bubble(.received, "The other party's bubble — grey by default, on the left.")
                    bubble(.default, "A strong primary bubble.")
                    bubble(.secondary, "Standard neutral conversation content.")
                    bubble(.muted, "Lower-emphasis supporting content.")
                    bubble(.tinted, "A subtle primary tint.")
                    bubble(.outline, "A bordered variant for secondary content.")
                    bubble(.ghost, "Unframed content spanning the full width — ideal for assistant text.")
                    bubble(.destructive, "An error or a failed action.")
                }
            }

            DemoSection("Alignment", description: "start for the receiver, end for the sender. Bubbles cap at 80% of the container.") {
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
            }

            DemoSection("Groups and reactions") {
                VStack(spacing: 14) {
                    ShadBubbleGroup(align: .start) {
                        ShadBubble(variant: .received) { ShadBubbleContent("Three things to look at:") }
                        ShadBubble(variant: .received) { ShadBubbleContent("1. The OKLCH converter") }
                        ShadBubble(variant: .received) { ShadBubbleContent("2. The popover panel host") }
                    }
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: -10) {
                            ShadBubble(variant: .sent, align: .end) {
                                ShadBubbleContent("Shipping it 🚀")
                            }
                            ShadBubbleReactions(["👍", "🎉"])
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
        }
    }

    private func bubble(_ variant: ShadBubbleVariant, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            DemoCaption(String(describing: variant))
                .frame(width: 84, alignment: .leading)
                .padding(.top, 9)
            ShadBubble(variant: variant) { ShadBubbleContent(text) }
        }
    }
}

// MARK: - Marker

struct MarkerPage: View {
    var body: some View {
        DemoPage(title: "Marker", subtitle: "An inline status, system note, bordered row or labelled separator in a conversation.") {
            DemoSection("Variants") {
                VStack(alignment: .leading, spacing: 14) {
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
            }

            DemoSection("Status with a spinner", description: "Pair with a Spinner for streaming progress.") {
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
            }

            DemoSection("Interactive", description: "Give a marker an action and it becomes a link.") {
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
            }

            DemoSection("In a transcript") {
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
            }
        }
    }
}

// MARK: - Message

struct MessagePage: View {
    var body: some View {
        DemoPage(title: "Message", subtitle: "Lays out one message: avatar, header, bubble and footer.") {
            DemoSection("A conversation", description: "The shadcn demo, with reactions and a live typing indicator.") {
                VStack(spacing: 14) {
                    ShadMessage(align: .end) {
                        ShadMessageContent {
                            ShadBubble(variant: .sent, align: .end) {
                                ShadBubbleContent("Deploying to prod real quick.")
                            }
                        }
                        ShadMessageAvatar { ShadAvatar(fallback: "EZ", size: .default) }
                    }

                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(fallback: "OL", size: .default) }
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
                        ShadMessageAvatar { ShadAvatar(fallback: "EZ", size: .default) }
                    }

                    ShadMessage {
                        ShadMessageAvatar { ShadAvatar(fallback: "OL", size: .default) }
                        ShadMessageContent {
                            VStack(alignment: .leading, spacing: -10) {
                                ShadBubble(variant: .received) {
                                    ShadBubbleContent("It's always a one-line change 😭.")
                                }
                                ShadBubbleReactions(["👍"])
                                    .padding(.leading, 10)
                            }
                        }
                    }

                    ShadTypingIndicator("Oliver is typing…")
                }
            }

            DemoSection("Alignment", description: "Put the avatar before the content for a received message, after it for a sent one.") {
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
            }

            DemoSection("Header and footer", description: "The header stays left-aligned; the footer follows the message.") {
                VStack(spacing: 20) {
                    ShadMessage(hasFooter: true) {
                        ShadMessageAvatar { ShadAvatar(fallback: "OL") }
                        ShadMessageContent {
                            ShadMessageHeader("Olivia")
                            ShadBubble(variant: .received) {
                                ShadBubbleContent("The design tokens are in. Radius and colours both come from the theme.")
                            }
                            ShadMessageFooter("Read yesterday")
                        }
                    }
                    ShadMessage(align: .end, hasFooter: true) {
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
            }

            DemoSection("Assistant style", description: "A ghost bubble spans the full width for long-form answers.") {
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
            }
        }
    }
}

// MARK: - Message scroller

private struct DemoChatMessage: Identifiable, Equatable {
    let id: Int
    let role: Role
    let text: String

    enum Role { case user, assistant }
}

struct MessageScrollerPage: View {
    @StateObject private var scroller = ShadMessageScrollerModel(
        autoScroll: true,
        defaultScrollPosition: .end,
        scrollPreviousItemPeek: 40
    )
    @State private var messages: [DemoChatMessage] = MessageScrollerPage.seed
    @State private var nextID = 100
    @State private var oldestID = -1
    @Environment(\.shadTheme) private var theme

    var body: some View {
        DemoPage(title: "Message Scroller", subtitle: "A transcript container for streaming conversations: anchoring, auto-scroll, history loading and jump-to.") {
            DemoSection("Live transcript", description: "New user turns anchor near the top; the jump button appears when you scroll away.") {
                VStack(spacing: 12) {
                    ShadMessageScrollerProvider(scroller) {
                        ShadMessageScroller(isBordered: true) {
                            ShadMessageScrollerViewport {
                                ShadMessageScrollerContent(ids: messages.map(\.id)) {
                                    ForEach(messages) { message in
                                        ShadMessageScrollerItem(
                                            messageId: message.id,
                                            scrollAnchor: message.role == .user
                                        ) {
                                            row(message)
                                        }
                                    }
                                }
                            }
                            ShadMessageScrollerButton(edge: .end, title: "Latest")
                        }
                        .frame(height: 380)
                    }

                    HStack(spacing: 8) {
                        ShadButton("Send turn", size: .sm, icon: .send) { appendTurn() }
                        ShadButton("Load older", variant: .outline, size: .sm, icon: .arrowUp) { prependHistory() }
                        ShadButton("Jump to top", variant: .ghost, size: .sm) { scroller.scrollToStart() }
                        ShadButton("Jump to first", variant: .ghost, size: .sm) {
                            if let first = messages.first { scroller.scrollToMessage(first.id) }
                        }
                        Spacer()
                        ShadSwitch("Auto-scroll", isOn: Binding(
                            get: { scroller.autoScroll },
                            set: { scroller.autoScroll = $0 }
                        ), size: .sm)
                    }
                }
            }

            DemoSection("Scroll state", description: "The model publishes what is visible, so the UI can react.") {
                DemoRow {
                    ShadBadge(scroller.isAtEnd ? "at end" : "scrolled away", variant: scroller.isAtEnd ? .secondary : .outline)
                    ShadBadge(scroller.isAtStart ? "at start" : "not at start", variant: .outline)
                    ShadBadge("\(scroller.visibleMessageIds.count) visible", variant: .outline)
                    ShadBadge("anchor: \(scroller.currentAnchorId.map { "\($0.base)" } ?? "none")", variant: .outline)
                    ShadBadge("\(messages.count) messages", variant: .outline)
                }
            }
        }
    }

    @ViewBuilder
    private func row(_ message: DemoChatMessage) -> some View {
        if message.role == .user {
            ShadMessage(align: .end) {
                ShadMessageContent {
                    ShadBubble(variant: .sent, align: .end) { ShadBubbleContent(message.text) }
                }
                ShadMessageAvatar { ShadAvatar(fallback: "EZ", size: .sm) }
            }
        } else {
            ShadMessage {
                ShadMessageAvatar { ShadAvatar(image: .symbol(.sparkles), size: .sm) }
                ShadMessageContent {
                    ShadBubble(variant: .ghost) { ShadBubbleContent(message.text) }
                }
            }
        }
    }

    private func appendTurn() {
        let userID = nextID
        messages.append(DemoChatMessage(id: userID, role: .user, text: "Turn \(userID): what changed in the theme?"))
        nextID += 1
        let replyID = nextID
        nextID += 1
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            messages.append(DemoChatMessage(
                id: replyID,
                role: .assistant,
                text: "The radius and the palette both come from ShadThemeSet, so nothing in this transcript hard-codes a colour. Scroll up and the anchor from your last turn stays put."
            ))
        }
    }

    private func prependHistory() {
        let older = (0..<3).map { offset in
            DemoChatMessage(
                id: oldestID - offset,
                role: offset.isMultiple(of: 2) ? .assistant : .user,
                text: "Older message \(abs(oldestID - offset)) restored from history."
            )
        }.reversed()
        oldestID -= 3
        messages.insert(contentsOf: older, at: 0)
    }

    private static let seed: [DemoChatMessage] = [
        DemoChatMessage(id: 1, role: .user, text: "Can you walk me through how theming works?"),
        DemoChatMessage(id: 2, role: .assistant, text: "A ShadThemeSet holds a light palette, a dark palette, and the shape and type decisions shared between them."),
        DemoChatMessage(id: 3, role: .user, text: "And the components?"),
        DemoChatMessage(id: 4, role: .assistant, text: "They read the resolved ShadTheme from the environment. That is the whole contract — no component owns a colour."),
        DemoChatMessage(id: 5, role: .user, text: "What about corner radius?"),
        DemoChatMessage(id: 6, role: .assistant, text: "ShadRadius derives sm, md, lg and xl from one base value, mirroring the calc() chain in shadcn's CSS."),
    ]
}
