import SwiftUI

/// One slot in a pagination strip: a page, or a gap where pages were left out.
///
/// The number on an ellipsis distinguishes the leading gap from the trailing
/// one, so the two stay separate identities as the current page moves.
public enum ShadPaginationEntry: Hashable, Sendable {
    case page(Int)
    case ellipsis(Int)
}

/// Page navigation: previous, a window of page numbers, next.
///
/// ```swift
/// @State private var page = 0
///
/// ShadPagination(page: $page, pageCount: 12)
/// ```
///
/// Pages are zero-based in the binding and shown one-based, so `page` drops
/// straight into an array slice.
public struct ShadPagination: View {
    @Environment(\.shadTheme) private var theme

    @Binding private var page: Int
    private let pageCount: Int
    private let siblingCount: Int
    private let showsLabels: Bool

    public init(
        page: Binding<Int>,
        pageCount: Int,
        siblingCount: Int = 1,
        showsLabels: Bool = true
    ) {
        self._page = page
        self.pageCount = max(0, pageCount)
        self.siblingCount = max(0, siblingCount)
        self.showsLabels = showsLabels
    }


    public var body: some View {
        HStack(spacing: 2) {
            ShadPaginationEdgeButton(
                title: showsLabels ? "Previous" : nil,
                icon: .chevronLeft,
                edge: .leading
            ) {
                page = max(0, page - 1)
            }
            .disabled(page <= 0)

            ForEach(entries, id: \.self) { entry in
                switch entry {
                case .page(let index):
                    ShadPaginationPageButton(
                        number: index + 1,
                        isCurrent: index == page
                    ) {
                        page = index
                    }
                case .ellipsis:
                    ShadPaginationEllipsis()
                }
            }

            ShadPaginationEdgeButton(
                title: showsLabels ? "Next" : nil,
                icon: .chevronRight,
                edge: .trailing
            ) {
                page = min(pageCount - 1, page + 1)
            }
            .disabled(page >= pageCount - 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pagination")
    }

    var entries: [ShadPaginationEntry] {
        Self.entries(page: page, pageCount: pageCount, siblingCount: siblingCount)
    }

    /// The first page, the last page, and a window around the current one —
    /// with an ellipsis wherever that skips more than a single page.
    ///
    /// Public so the same windowing can drive a strip of your own.
    ///
    /// ```swift
    /// ShadPagination.entries(page: 6, pageCount: 12)
    /// // [.page(0), .ellipsis, .page(5), .page(6), .page(7), .ellipsis, .page(11)]
    /// ```
    public static func entries(
        page: Int,
        pageCount: Int,
        siblingCount: Int = 1
    ) -> [ShadPaginationEntry] {
        guard pageCount > 0 else { return [] }
        let siblingCount = max(0, siblingCount)
        let page = min(max(0, page), pageCount - 1)
        // A window plus its two ellipses is only shorter once the run is long
        // enough to hide more than one page at each end.
        guard pageCount > siblingCount * 2 + 5 else {
            return (0..<pageCount).map(ShadPaginationEntry.page)
        }

        let first = 0
        let last = pageCount - 1
        let lower = max(first + 1, page - siblingCount)
        let upper = min(last - 1, page + siblingCount)

        var entries: [ShadPaginationEntry] = [.page(first)]
        if lower > first + 1 { entries.append(.ellipsis(0)) }
        entries.append(contentsOf: (lower...upper).map(ShadPaginationEntry.page))
        if upper < last - 1 { entries.append(.ellipsis(1)) }
        entries.append(.page(last))
        return entries
    }
}

/// Previous and Next, which carry a label beside the chevron.
struct ShadPaginationEdgeButton: View {
    @Environment(\.shadTheme) private var theme

    let title: String?
    let icon: ShadIcon
    let edge: HorizontalEdge
    let action: () -> Void

    var body: some View {
        ShadButton(variant: .ghost, size: .default, action: action) {
            HStack(spacing: 6) {
                if edge == .leading { ShadIconView(icon, size: 16) }
                if let title { Text(title) }
                if edge == .trailing { ShadIconView(icon, size: 16) }
            }
            // `pl-1.5!` / `pr-1.5!`: the chevron sits closer to the edge than
            // the label does.
            .padding(edge == .leading ? .leading : .trailing, -4)
        }
    }
}

/// One page number. The current page is an outline button, the rest ghosts.
struct ShadPaginationPageButton: View {
    let number: Int
    let isCurrent: Bool
    let action: () -> Void

    var body: some View {
        ShadButton(variant: isCurrent ? .outline : .ghost, size: .icon, action: action) {
            Text("\(number)")
        }
        .accessibilityLabel("Page \(number)")
        .accessibilityAddTraits(isCurrent ? [.isButton, .isSelected] : .isButton)
    }
}

/// The gap where pages were left out.
struct ShadPaginationEllipsis: View {
    @Environment(\.shadTheme) private var theme

    var body: some View {
        ShadIconView(.moreHorizontal, size: 16)
            .foregroundStyle(theme.colors.mutedForeground)
            .frame(width: 32, height: 32)
            .accessibilityLabel("More pages")
    }
}
