import SwiftUI

/// An indeterminate loading indicator.
///
/// ```swift
/// ShadSpinner()
/// ShadSpinner(size: 24)
/// ShadSpinner(style: .dots)
/// ```
public struct ShadSpinner: View {
    /// The shape of the animation.
    public enum Style: Sendable, Hashable {
        /// A rotating arc — the equivalent of Lucide's `loader-circle`.
        case arc
        /// Twelve fading spokes — the equivalent of Lucide's `loader`.
        case spokes
        /// Three pulsing dots.
        case dots
    }

    @Environment(\.shadTheme) private var theme
    @State private var isAnimating = false

    private let size: CGFloat
    private let style: Style
    private let color: Color?
    private let lineWidth: CGFloat?

    public init(size: CGFloat = 16, style: Style = .arc, color: Color? = nil, lineWidth: CGFloat? = nil) {
        self.size = size
        self.style = style
        self.color = color
        self.lineWidth = lineWidth
    }

    private var tint: Color { color ?? theme.colors.mutedForeground }
    private var stroke: CGFloat { lineWidth ?? max(1.5, size / 8) }

    public var body: some View {
        Group {
            switch style {
            case .arc: arc
            case .spokes: spokes
            case .dots: dots
            }
        }
        .frame(width: size, height: style == .dots ? size * 0.4 : size)
        .accessibilityLabel("Loading")
        .onAppear { isAnimating = theme.motion.isEnabled }
    }

    private var arc: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(tint, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
            .padding(stroke / 2)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(theme.motion.isEnabled ? theme.motion.loop : nil, value: isAnimating)
    }

    private var spokes: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(tint)
                    .frame(width: stroke, height: size * 0.26)
                    .offset(y: -size * 0.34)
                    .rotationEffect(.degrees(Double(index) / 12 * 360))
                    .opacity(isAnimating ? 0.15 + 0.85 * (Double(index) / 12) : 0.4)
            }
        }
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(theme.motion.isEnabled ? theme.motion.loop : nil, value: isAnimating)
    }

    private var dots: some View {
        HStack(spacing: size * 0.16) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(tint)
                    .frame(width: size * 0.28, height: size * 0.28)
                    .scaleEffect(isAnimating ? 1 : 0.55)
                    .opacity(isAnimating ? 1 : 0.4)
                    .animation(
                        theme.motion.isEnabled
                            ? .easeInOut(duration: 0.55).repeatForever().delay(Double(index) * 0.15)
                            : nil,
                        value: isAnimating
                    )
            }
        }
    }
}
