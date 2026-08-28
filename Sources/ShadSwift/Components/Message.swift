import SwiftUI

/// Which side of the conversation a message sits on.
public enum ShadMessageAlignment: String, CaseIterable, Sendable {
    case start
    case end

    var horizontal: HorizontalAlignment { self == .start ? .leading : .trailing }
    var frameAlignment: Alignment { self == .start ? .leading : .trailing }
    var bubbleAlignment: ShadBubbleAlignment { self == .start ? .start : .end }
}

private struct ShadMessageAlignmentKey: EnvironmentKey {
    static let defaultValue = ShadMessageAlignment.start
}

extension EnvironmentValues {
    /// The enclosing message's alignment, read by ``ShadMessageContent`` and
    /// ``ShadMessageFooter``.
    public var shadMessageAlignment: ShadMessageAlignment {
        get { self[ShadMessageAlignmentKey.self] }
        set { self[ShadMessageAlignmentKey.self] = newValue }
    }
}

/// One message in a conversation: an avatar plus its content column.
///
/// ```swift
/// ShadMessage(align: .start) {
///     ShadMessageAvatar { ShadAvatar(fallback: "CN") }
///     ShadMessageContent {
///         ShadMessageHeader("Olivia")
///         ShadBubble { ShadBubbleContent("How can I help you today?") }
///         ShadMessageFooter("Read Yesterday")
///     }
/// }
/// ```
public struct ShadMessage<Content: View>: View {
    private let align: ShadMessageAlignment
    private let spacing: CGFloat
    private let hasFooter: Bool
    private let content: Content

    /// - Parameter hasFooter: set when the content carries a
    ///   ``ShadMessageFooter``, so the avatar stays level with the bubble
    ///   rather than sinking to the footer's baseline. shadcn does the same
    ///   thing with `-translate-y-8`.
    public init(
        align: ShadMessageAlignment = .start,
        spacing: CGFloat = 8,
        hasFooter: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.align = align
        self.spacing = spacing
        self.hasFooter = hasFooter
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            if align == .end { Spacer(minLength: 0) }
            content
            if align == .start { Spacer(minLength: 0) }
        }
        .environment(\.shadMessageAlignment, align)
        .environment(\.shadMessageAvatarLift, hasFooter ? 26 : 0)
        .frame(maxWidth: .infinity, alignment: align.frameAlignment)
    }
}

private struct ShadMessageAvatarLiftKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// How far the avatar rides up so it lines up with the bubble when a
    /// footer sits below it.
    var shadMessageAvatarLift: CGFloat {
        get { self[ShadMessageAvatarLiftKey.self] }
        set { self[ShadMessageAvatarLiftKey.self] = newValue }
    }
}

/// The avatar slot. It stays anchored to the bottom of the message, clear of
/// any footer.
public struct ShadMessageAvatar<Content: View>: View {
    @Environment(\.shadMessageAvatarLift) private var lift
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .offset(y: -lift)
            .frame(height: lift > 0 ? nil : nil)
    }
}

/// Wraps the header, the bubble and the footer.
public struct ShadMessageContent<Content: View>: View {
    @Environment(\.shadMessageAlignment) private var align
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: align.horizontal, spacing: 10) {
            content
        }
    }
}

/// Content above the message, such as the sender's name. It stays left-aligned
/// no matter which side the message is on.
public struct ShadMessageHeader<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 6) { content }
            .font(theme.font(theme.typography.xs, theme.typography.medium))
            .foregroundStyle(theme.colors.mutedForeground)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ShadMessageHeader where Content == Text {
    public init(_ text: String) { self.init { Text(text) } }
}

/// Content below the message — status, timestamps or action buttons. It aligns
/// to the same side as the message.
public struct ShadMessageFooter<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadMessageAlignment) private var align
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 4) { content }
            .font(theme.font(theme.typography.xs, theme.typography.medium))
            .foregroundStyle(theme.colors.mutedForeground)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: align.frameAlignment)
    }
}

extension ShadMessageFooter where Content == Text {
    public init(_ text: String) { self.init { Text(text) } }
}

/// Stacks consecutive messages from the same sender with tighter spacing.
public struct ShadMessageGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 3, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) { content }
    }
}


/// The "Oliver is typing…" line: three pulsing dots and an optional name,
/// shown while the other party is composing.
public struct ShadTypingIndicator: View {
    @Environment(\.shadTheme) private var theme
    @State private var isAnimating = false

    private let label: String?

    public init(_ label: String? = nil) { self.label = label }

    public var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(theme.colors.mutedForeground)
                        .frame(width: 5, height: 5)
                        .opacity(isAnimating ? 1 : 0.3)
                        .animation(
                            theme.motion.isEnabled
                                ? .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.15)
                                : nil,
                            value: isAnimating
                        )
                }
            }
            if let label {
                Text(label)
                    .font(theme.font(theme.typography.xs, theme.typography.medium))
                    .foregroundStyle(theme.colors.mutedForeground)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { isAnimating = theme.motion.isEnabled }
        .accessibilityLabel(label ?? "Typing")
    }
}
