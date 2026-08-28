import SwiftUI

/// A flow layout: places subviews left to right and wraps to a new line when
/// it runs out of width. Used for combobox chips and any other tag list.
public struct ShadWrapLayout: Layout {
    public var spacing: CGFloat
    public var lineSpacing: CGFloat
    public var alignment: VerticalAlignment

    public init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8, alignment: VerticalAlignment = .center) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.alignment = alignment
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = layout(subviews: subviews, maxWidth: maxWidth)
        let height = rows.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, rows.count - 1))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = layout(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for element in row.elements {
                let size = subviews[element.index].sizeThatFits(.unspecified)
                let dy: CGFloat
                switch alignment {
                case .top: dy = 0
                case .bottom: dy = row.height - size.height
                default: dy = (row.height - size.height) / 2
                }
                subviews[element.index].place(
                    at: CGPoint(x: x, y: y + dy),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row {
        var elements: [(index: Int, width: CGFloat)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func layout(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = current.elements.isEmpty ? size.width : current.width + spacing + size.width
            if needed > maxWidth, !current.elements.isEmpty {
                rows.append(current)
                current = Row()
                current.elements = [(index, size.width)]
                current.width = size.width
                current.height = size.height
            } else {
                current.elements.append((index, size.width))
                current.width = needed
                current.height = max(current.height, size.height)
            }
        }
        if !current.elements.isEmpty { rows.append(current) }
        return rows
    }
}
