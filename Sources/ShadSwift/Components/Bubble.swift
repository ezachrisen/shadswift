import SwiftUI

/// The bubble treatments.
///
/// ``sent`` and ``received`` are the conversation defaults and read their
/// colours from dedicated theme tokens, so a chat keeps its own palette however
/// the brand colour is set. The remaining cases mirror shadcn's variants.
public enum ShadBubbleVariant: String, CaseIterable, Sendable {
    /// The current user's bubble — blue by default, on the right.
    case sent
    /// The other party's bubble — grey by default, on the left.
    case received
    /// A strong primary bubble.
    case `default`
    /// Neutral conversation content.
    case secondary
    /// Lower-emphasis supporting content.
    case muted
    /// A subtle primary tint.
    case tinted
    /// Bordered, for secondary content.
    case outline
    /// Unframed, full width — ideal for assistant text.
    case ghost
    /// Errors and failed actions.
    case destructive
}

/// Which side a bubble hugs.
public enum ShadBubbleAlignment: String, CaseIterable, Sendable {
    case start
    case end

    var horizontal: HorizontalAlignment { self == .start ? .leading : .trailing }
    var frameAlignment: Alignment { self == .start ? .leading : .trailing }
}

/// A chat bubble.
///
/// ```swift
/// ShadBubble(variant: .default, align: .end) {
///     ShadBubbleContent("Can you help me refactor this?")
/// }
/// ```
public struct ShadBubble<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    private let variant: ShadBubbleVariant
    private let align: ShadBubbleAlignment
    /// Fraction of the container a bubble may occupy. Ghost bubbles ignore it.
    private let maxWidthFraction: CGFloat
    private let content: Content

    public init(
        variant: ShadBubbleVariant = .received,
        align: ShadBubbleAlignment = .start,
        maxWidthFraction: CGFloat = 0.8,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.align = align
        self.maxWidthFraction = maxWidthFraction
        self.content = content()
    }

    private var isDark: Bool { theme.colorScheme == .dark }

    private var background: Color {
        switch variant {
        case .sent: return theme.colors.bubbleSent
        case .received: return theme.colors.bubbleReceived
        case .default: return theme.colors.primary
        case .secondary: return theme.colors.secondary
        case .muted: return theme.colors.muted
        // shadcn derives the tint from `primary`: same hue, much lighter, and
        // a fraction of the chroma.
        case .tinted:
            return theme.colors.primary.shadLightness { _ in isDark ? 0.30 : 0.93 }
                .shadMix(with: theme.colors.background, amount: isDark ? 0.35 : 0.45)
        case .outline: return theme.colors.background
        case .ghost: return .clear
        case .destructive: return theme.colors.destructive.opacity(isDark ? 0.20 : 0.10)
        }
    }

    private var foreground: Color {
        switch variant {
        case .sent: return theme.colors.bubbleSentForeground
        case .received: return theme.colors.bubbleReceivedForeground
        case .default: return theme.colors.primaryForeground
        case .secondary: return theme.colors.secondaryForeground
        case .muted, .tinted, .outline, .ghost: return theme.colors.foreground
        case .destructive: return theme.colors.destructive
        }
    }

    private var border: Color? {
        variant == .outline ? theme.colors.border : nil
    }

    public var body: some View {
        VStack(alignment: align.horizontal, spacing: 6) {
            content
        }
        .font(theme.font(theme.typography.sm))
        .lineSpacing(3)
        .foregroundStyle(foreground)
        .padding(.horizontal, variant == .ghost ? 0 : 12)
        .padding(.vertical, variant == .ghost ? 0 : 10)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.bubble).fill(background)
        )
        .overlay {
            if let border {
                ShadRoundedRectangle(cornerRadius: theme.radius.bubble)
                    .strokeBorder(border, lineWidth: theme.borderWidth)
            }
        }
        .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.bubble))
        .modifier(ShadBubbleWidthLimit(fraction: variant == .ghost ? 1 : maxWidthFraction, align: align))
    }
}

/// Applies the 80% width cap shadcn puts on bubbles.
private struct ShadBubbleWidthLimit: ViewModifier {
    let fraction: CGFloat
    let align: ShadBubbleAlignment
    @State private var available: CGFloat = 600

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: fraction >= 1 ? .infinity : available * fraction, alignment: align.frameAlignment)
            .frame(maxWidth: .infinity, alignment: align.frameAlignment)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { available = proxy.size.width }
                        .onChange(of: proxy.size.width) { _, width in available = width }
                }
            )
    }
}

/// The text inside a bubble.
public struct ShadBubbleContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
    }
}

extension ShadBubbleContent where Content == Text {
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Emoji reactions anchored to a bubble's edge.
public struct ShadBubbleReactions: View {
    @Environment(\.shadTheme) private var theme
    private let reactions: [String]

    public init(_ reactions: [String]) { self.reactions = reactions }
    public init(_ reaction: String) { self.reactions = [reaction] }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(reactions, id: \.self) { reaction in
                Text(reaction).font(.system(size: 11))
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
            Capsule().fill(theme.colors.background)
        )
        .overlay(Capsule().strokeBorder(theme.colors.border, lineWidth: theme.borderWidth))
    }
}

/// Stacks bubbles from the same sender with tighter spacing.
public struct ShadBubbleGroup<Content: View>: View {
    private let align: ShadBubbleAlignment
    private let content: Content

    public init(align: ShadBubbleAlignment = .start, @ViewBuilder content: () -> Content) {
        self.align = align
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: align.horizontal, spacing: 3) { content }
            .frame(maxWidth: .infinity, alignment: align.frameAlignment)
    }
}
