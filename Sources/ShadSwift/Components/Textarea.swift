import SwiftUI
import AppKit

/// A multi-line text input.
///
/// ```swift
/// ShadTextarea("Type your message here.", text: $message)
/// ShadTextarea("Bio", text: $bio, minHeight: 120, isInvalid: hasError)
/// ```
public struct ShadTextarea: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.shadStaticRendering) private var isStatic
    @FocusState private var isFocused: Bool

    private let placeholder: String
    @Binding private var text: String
    private let minHeight: CGFloat
    private let maxHeight: CGFloat?
    private let isInvalid: Bool
    private let isResizable: Bool

    @State private var draggedHeight: CGFloat?

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        minHeight: CGFloat = 64,
        maxHeight: CGFloat? = nil,
        isInvalid: Bool = false,
        isResizable: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isInvalid = isInvalid
        self.isResizable = isResizable
    }

    private var resolvedMinHeight: CGFloat { draggedHeight ?? minHeight }

    /// The corner grip a browser draws on a resizable textarea: two short
    /// diagonal rules, which is exactly what shadcn shows.
    private var resizeHandle: some View {
        ShadResizeGrip()
            .stroke(theme.colors.mutedForeground.opacity(0.6),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round))
            .frame(width: 8, height: 8)
            .padding(5)
            .contentShape(Rectangle())
            .onHover { inside in
                if inside { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let base = draggedHeight ?? minHeight
                        draggedHeight = max(minHeight, base + value.translation.height)
                    }
            )
    }

    public var body: some View {
        ShadInputChrome(
            isFocused: isFocused,
            isInvalid: isInvalid,
            height: nil,
            horizontalPadding: 10,
            verticalPadding: 8
        ) {
            if isStatic {
                ShadStaticTextValue(
                    text: text,
                    placeholder: placeholder,
                    lineLimit: nil,
                    alignment: .topLeading
                )
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .frame(minHeight: resolvedMinHeight, alignment: .topLeading)
            } else {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(theme.font(theme.typography.sm))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .focused($isFocused)
                    .font(theme.font(theme.typography.sm))
                    .foregroundStyle(theme.colors.foreground)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: resolvedMinHeight, maxHeight: maxHeight)
            }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isResizable { resizeHandle }
        }
    }
}

/// The two diagonal rules a browser draws in a resizable textarea's corner.
struct ShadResizeGrip: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for inset in [CGFloat(0), rect.width * 0.45] {
            path.move(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - inset))
        }
        return path
    }
}
