import SwiftUI

// MARK: - Column model

/// Which edge a column's cells line up on.
public enum ShadTableAlignment: Sendable, Hashable {
    case leading
    case center
    case trailing

    var frameAlignment: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    var textAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

/// How wide a column wants to be.
///
/// This mirrors `table-layout: auto`: automatic columns size to their widest
/// cell, then any room left over is shared out — among the flexible columns if
/// there are any, otherwise across the automatic ones in proportion.
public enum ShadTableColumnWidth: Sendable, Hashable {
    /// Sizes to the widest cell, and takes a share of any surplus.
    case automatic
    /// Takes the surplus, never dropping below `min`.
    case flexible(min: CGFloat = 0)
    /// Exactly this wide, whatever the content.
    case fixed(CGFloat)
}

/// How one cell's text is drawn — the hook for "red when it is over budget".
///
/// ```swift
/// style: { $0.amount > 100 ? ShadTableCellStyle(color: .red, weight: .medium) : .plain }
/// ```
public struct ShadTableCellStyle: Sendable, Hashable {
    /// `nil` keeps the table's own foreground.
    public var color: Color?
    /// `nil` keeps the table's own weight.
    public var weight: Font.Weight?
    /// Draws the value in the theme's monospaced face, for figures that should
    /// line up down the column.
    public var isMonospaced: Bool
    public var opacity: Double?

    public init(
        color: Color? = nil,
        weight: Font.Weight? = nil,
        isMonospaced: Bool = false,
        opacity: Double? = nil
    ) {
        self.color = color
        self.weight = weight
        self.isMonospaced = isMonospaced
        self.opacity = opacity
    }

    /// The table's own styling, unchanged.
    public static let plain = ShadTableCellStyle()

    /// Just a colour.
    public static func color(_ color: Color) -> ShadTableCellStyle {
        ShadTableCellStyle(color: color)
    }
}

/// One column of a ``ShadTable``: what it is called, how it reads, how it is
/// aligned, how wide it wants to be, and how it sorts.
///
/// A value column formats each row into a string, and may style the result:
///
/// ```swift
/// ShadTableColumn<Payment>(
///     "Amount",
///     alignment: .trailing,
///     value: { $0.amount.formatted(.currency(code: "USD")) },
///     style: { $0.amount > 100 ? .color(.red) : .plain },
///     sortBy: { $0.amount < $1.amount }
/// )
/// ```
///
/// A content column draws whatever you like instead:
///
/// ```swift
/// ShadTableColumn<Payment>("Status") { ShadBadge($0.status.name) }
/// ```
public struct ShadTableColumn<Row>: Identifiable {
    public let id: String
    public var title: String
    public var alignment: ShadTableAlignment
    public var width: ShadTableColumnWidth
    /// Whether the column picker may hide this column.
    public var canHide: Bool
    /// Whether the filter field searches this column.
    public var isSearchable: Bool
    /// Whether the header offers a sort control.
    public var isSortable: Bool { comparator != nil }

    let value: ((Row) -> String)?
    let style: ((Row) -> ShadTableCellStyle)?
    let content: ((Row) -> AnyView)?
    let comparator: ((Row, Row) -> Bool)?
    let searchValue: ((Row) -> String)?

    /// A column of formatted text.
    public init(
        _ title: String,
        id: String? = nil,
        alignment: ShadTableAlignment = .leading,
        width: ShadTableColumnWidth = .automatic,
        canHide: Bool = true,
        isSearchable: Bool = true,
        value: @escaping (Row) -> String,
        style: ((Row) -> ShadTableCellStyle)? = nil,
        sortBy: ((Row, Row) -> Bool)? = nil
    ) {
        self.id = id ?? title
        self.title = title
        self.alignment = alignment
        self.width = width
        self.canHide = canHide
        self.isSearchable = isSearchable
        self.value = value
        self.style = style
        self.content = nil
        self.comparator = sortBy
        self.searchValue = value
    }

    /// A column that draws its own cells.
    public init<Content: View>(
        _ title: String,
        id: String? = nil,
        alignment: ShadTableAlignment = .leading,
        width: ShadTableColumnWidth = .automatic,
        canHide: Bool = true,
        searchValue: ((Row) -> String)? = nil,
        sortBy: ((Row, Row) -> Bool)? = nil,
        @ViewBuilder content: @escaping (Row) -> Content
    ) {
        self.id = id ?? title
        self.title = title
        self.alignment = alignment
        self.width = width
        self.canHide = canHide
        self.isSearchable = searchValue != nil
        self.value = nil
        self.style = nil
        self.content = { AnyView(content($0)) }
        self.comparator = sortBy
        self.searchValue = searchValue
    }

    /// The trailing column of per-row menus, as on shadcn's data table.
    ///
    /// ```swift
    /// ShadTableColumn.actions { payment in
    ///     ShadDropdownMenuItem("Copy payment ID") { copy(payment.id) }
    ///     ShadDropdownMenuSeparator()
    ///     ShadDropdownMenuItem("View customer") { open(payment) }
    /// }
    /// ```
    public static func actions<Menu: View>(
        id: String = "actions",
        label: String = "Open menu",
        @ViewBuilder menu: @escaping (Row) -> Menu
    ) -> ShadTableColumn<Row> {
        ShadTableColumn(
            "",
            id: id,
            alignment: .trailing,
            width: .automatic,
            canHide: false
        ) { row in
            ShadDropdownMenu(alignment: .bottomTrailing) { isOpen in
                ShadTableActionButton(label: label, isOpen: isOpen)
            } content: {
                menu(row)
            }
        }
    }

    func text(for row: Row) -> String? { value?(row) }
    func searchText(for row: Row) -> String? { isSearchable ? searchValue?(row) : nil }
}

// MARK: - Metrics

/// The measurements shadcn's table is built from.
enum ShadTableMetrics {
    /// `h-10` on the header cells.
    static let headerHeight: CGFloat = 40
    /// `px-2` on header cells, `p-2` on body cells.
    static let cellPadding: CGFloat = 8
    /// `h-24` on the empty-state row.
    static let emptyHeight: CGFloat = 96
    /// The `size-4` checkbox and the column it sits in.
    static let checkboxSize: CGFloat = 16
    /// `size-6` on the row action button, with a `size-3` glyph.
    static let actionButtonSize: CGFloat = 24
    static let actionIconSize: CGFloat = 12
}

// MARK: - Layout

/// What ``ShadTableLayout`` needs to know about each column.
struct ShadTableColumnMetrics {
    var width: ShadTableColumnWidth
}

/// Lays cells out in a grid the way a browser lays out `table-layout: auto`.
///
/// Subviews arrive row-major. Each column takes the width of its widest cell —
/// or its fixed width — and any room left over is shared out. Every cell in a
/// row is then given that row's full height, so a cell can paint the row's
/// background and separator itself and they meet without seams.
struct ShadTableLayout: Layout {
    let columns: [ShadTableColumnMetrics]

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !columns.isEmpty, !subviews.isEmpty else { return .zero }
        let widths = columnWidths(subviews: subviews, proposedWidth: proposal.width)
        let heights = rowHeights(subviews: subviews, widths: widths)
        return CGSize(width: widths.reduce(0, +), height: heights.reduce(0, +))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !columns.isEmpty else { return }
        let widths = columnWidths(subviews: subviews, proposedWidth: bounds.width)
        let heights = rowHeights(subviews: subviews, widths: widths)

        var y = bounds.minY
        for row in heights.indices {
            var x = bounds.minX
            for column in columns.indices {
                let index = row * columns.count + column
                guard index < subviews.count else { break }
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: widths[column], height: heights[row])
                )
                x += widths[column]
            }
            y += heights[row]
        }
    }

    private func columnWidths(subviews: Subviews, proposedWidth: CGFloat?) -> [CGFloat] {
        var widths = [CGFloat](repeating: 0, count: columns.count)
        for (index, subview) in subviews.enumerated() {
            let column = index % columns.count
            if case .fixed(let fixed) = columns[column].width {
                widths[column] = fixed
            } else {
                widths[column] = max(widths[column], subview.sizeThatFits(.unspecified).width)
            }
        }
        for (index, metrics) in columns.enumerated() {
            if case .flexible(let minimum) = metrics.width {
                widths[index] = max(widths[index], minimum)
            }
        }

        let total = widths.reduce(0, +)
        guard let proposedWidth, proposedWidth > total else { return widths }

        // Flexible columns soak up the surplus; failing that the automatic ones
        // grow in proportion, which is what an auto-laid-out table does.
        let flexible = columns.indices.filter {
            if case .flexible = columns[$0].width { return true }
            return false
        }
        let growable = flexible.isEmpty
            ? columns.indices.filter {
                if case .fixed = columns[$0].width { return false }
                return true
            }
            : flexible
        guard !growable.isEmpty else { return widths }

        let surplus = proposedWidth - total
        let base = growable.reduce(0) { $0 + widths[$1] }
        for index in growable {
            widths[index] += base > 0
                ? surplus * (widths[index] / base)
                : surplus / CGFloat(growable.count)
        }
        return widths
    }

    private func rowHeights(subviews: Subviews, widths: [CGFloat]) -> [CGFloat] {
        let rowCount = Int(ceil(Double(subviews.count) / Double(columns.count)))
        return (0..<rowCount).map { row in
            var height: CGFloat = 0
            for column in columns.indices {
                let index = row * columns.count + column
                guard index < subviews.count else { break }
                let fits = subviews[index].sizeThatFits(
                    ProposedViewSize(width: widths[column], height: nil)
                )
                height = max(height, fits.height)
            }
            return height
        }
    }
}

// MARK: - Table

/// A table of rows and columns.
///
/// ```swift
/// ShadTable(payments, columns: columns, selection: $selected, bordered: true)
/// ```
///
/// This is the presentation on its own — no toolbar, no pagination. Reach for
/// ``ShadDataTable`` when you want filtering, sorting, a column picker and
/// pages around it.
public struct ShadTable<Row: Identifiable>: View {
    @Environment(\.shadTheme) private var theme

    private let rows: [Row]
    private let columns: [ShadTableColumn<Row>]
    private let selection: Binding<Set<Row.ID>>?
    private let sort: Binding<ShadTableSort?>?
    private let bordered: Bool
    private let emptyMessage: String

    @State private var hoveredRow: Row.ID?

    public init(
        _ rows: [Row],
        columns: [ShadTableColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        sort: Binding<ShadTableSort?>? = nil,
        bordered: Bool = true,
        emptyMessage: String = "No results."
    ) {
        self.rows = rows
        self.columns = columns
        self.selection = selection
        self.sort = sort
        self.bordered = bordered
        self.emptyMessage = emptyMessage
    }

    private var hasSelection: Bool { selection != nil }

    /// The checkbox column, when there is one, plus the real columns.
    private var layoutMetrics: [ShadTableColumnMetrics] {
        var metrics = columns.map { ShadTableColumnMetrics(width: $0.width) }
        if hasSelection {
            metrics.insert(ShadTableColumnMetrics(width: .automatic), at: 0)
        }
        return metrics
    }

    public var body: some View {
        VStack(spacing: 0) {
            // One flat, row-major list rather than nested ForEachs: the layout
            // reads its subviews in order, and a conditional leading column
            // inside a nested ForEach does not reliably keep its place.
            ShadTableLayout(columns: layoutMetrics) {
                ForEach(cells) { cell in
                    view(for: cell)
                }
            }
            if rows.isEmpty { emptyState }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(ShadRoundedRectangle(cornerRadius: bordered ? theme.radius.md : 0))
        .overlay {
            if bordered {
                ShadRoundedRectangle(cornerRadius: theme.radius.md)
                    .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
            }
        }
        .font(theme.font(theme.typography.sm))
        .accessibilityElement(children: .contain)
    }

    /// One cell's place in the grid.
    private enum Cell: Identifiable {
        case selectAll
        case header(Int)
        case select(Int)
        case value(row: Int, column: Int)

        var id: String {
            switch self {
            case .selectAll: return "h-select"
            case .header(let column): return "h-\(column)"
            case .select(let row): return "r\(row)-select"
            case .value(let row, let column): return "r\(row)-c\(column)"
            }
        }
    }

    private var cells: [Cell] {
        var cells: [Cell] = []
        if hasSelection { cells.append(.selectAll) }
        cells.append(contentsOf: columns.indices.map(Cell.header))
        for row in rows.indices {
            if hasSelection { cells.append(.select(row)) }
            cells.append(contentsOf: columns.indices.map { Cell.value(row: row, column: $0) })
        }
        return cells
    }

    @ViewBuilder
    private func view(for cell: Cell) -> some View {
        switch cell {
        case .selectAll:
            headerShell(alignment: .leading, trailingPadding: 0) {
                ShadCheckbox(state: selectAllBinding)
                    .accessibilityLabel("Select all")
            }
        case .header(let index):
            headerShell(alignment: columns[index].alignment) {
                headerLabel(for: columns[index])
            }
        case .select(let index):
            bodyShell(row: rows[index], alignment: .leading, trailingPadding: 0) {
                ShadCheckbox(isOn: rowSelectionBinding(rows[index]))
                    .accessibilityLabel("Select row")
            }
        case .value(let rowIndex, let columnIndex):
            let row = rows[rowIndex]
            let column = columns[columnIndex]
            bodyShell(row: row, alignment: column.alignment) {
                cellContent(row: row, column: column)
            }
        }
    }

    // MARK: Header

    @ViewBuilder
    private func headerLabel(for column: ShadTableColumn<Row>) -> some View {
        if column.isSortable, let sort {
            ShadTableSortButton(
                title: column.title,
                direction: sort.wrappedValue?.columnID == column.id
                    ? sort.wrappedValue?.direction
                    : nil
            ) {
                sort.wrappedValue = ShadTableSort.toggled(sort.wrappedValue, for: column.id)
            }
            // The button carries its own 10pt padding, so it sits flush with
            // the text in the cells below it.
            .padding(.horizontal, -ShadTableMetrics.cellPadding - 2)
        } else if !column.title.isEmpty {
            Text(column.title)
                .font(theme.font(theme.typography.sm, theme.typography.medium))
                .foregroundStyle(theme.colors.foreground)
        }
    }

    private func headerShell<Content: View>(
        alignment: ShadTableAlignment,
        trailingPadding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        // The stack matters: a cell whose content is an EmptyView — the header
        // of the actions column, say — would otherwise be elided, and every
        // cell after it would slide one place to the left.
        HStack(spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: alignment.frameAlignment)
            .padding(.leading, ShadTableMetrics.cellPadding)
            .padding(.trailing, trailingPadding ?? ShadTableMetrics.cellPadding)
            .frame(height: ShadTableMetrics.headerHeight)
            .overlay(alignment: .bottom) { separator }
    }

    // MARK: Body

    @ViewBuilder
    private func cellContent(row: Row, column: ShadTableColumn<Row>) -> some View {
        if let content = column.content {
            content(row)
        } else if let text = column.text(for: row) {
            let style = column.style?(row) ?? .plain
            Text(text)
                .font(
                    style.isMonospaced
                        ? theme.monoFont(theme.typography.sm, style.weight ?? theme.typography.regular)
                        : theme.font(theme.typography.sm, style.weight ?? theme.typography.regular)
                )
                .foregroundStyle(style.color ?? theme.colors.foreground)
                .opacity(style.opacity ?? 1)
                .multilineTextAlignment(column.alignment.textAlignment)
        }
    }

    private func bodyShell<Content: View>(
        row: Row,
        alignment: ShadTableAlignment,
        trailingPadding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: alignment.frameAlignment)
            .padding(.vertical, ShadTableMetrics.cellPadding)
            .padding(.leading, ShadTableMetrics.cellPadding)
            .padding(.trailing, trailingPadding ?? ShadTableMetrics.cellPadding)
            .frame(maxHeight: .infinity)
            .background(background(for: row))
            .overlay(alignment: .bottom) { separator }
            .contentShape(Rectangle())
            .onHover { inside in
                if inside {
                    hoveredRow = row.id
                } else if hoveredRow == row.id {
                    hoveredRow = nil
                }
            }
    }

    private func background(for row: Row) -> Color {
        if selection?.wrappedValue.contains(row.id) == true { return theme.colors.muted }
        if hoveredRow == row.id { return theme.colors.muted.opacity(0.5) }
        return .clear
    }

    private var separator: some View {
        Rectangle()
            .fill(theme.colors.border)
            .frame(height: theme.borderWidth)
    }

    private var emptyState: some View {
        Text(emptyMessage)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: ShadTableMetrics.emptyHeight)
    }

    // MARK: Selection

    private var selectAllBinding: Binding<ShadCheckboxState> {
        Binding(
            get: {
                guard let selection, !rows.isEmpty else { return .unchecked }
                let selected = rows.filter { selection.wrappedValue.contains($0.id) }.count
                if selected == 0 { return .unchecked }
                return selected == rows.count ? .checked : .indeterminate
            },
            set: { newValue in
                guard let selection else { return }
                if newValue == .checked {
                    for row in rows { selection.wrappedValue.insert(row.id) }
                } else {
                    for row in rows { selection.wrappedValue.remove(row.id) }
                }
            }
        )
    }

    private func rowSelectionBinding(_ row: Row) -> Binding<Bool> {
        Binding(
            get: { selection?.wrappedValue.contains(row.id) ?? false },
            set: { isOn in
                guard let selection else { return }
                if isOn { selection.wrappedValue.insert(row.id) }
                else { selection.wrappedValue.remove(row.id) }
            }
        )
    }
}

// MARK: - Sorting

/// Which column a table is sorted by, and which way round.
public struct ShadTableSort: Sendable, Hashable {
    public enum Direction: Sendable, Hashable {
        case ascending
        case descending

        var flipped: Direction { self == .ascending ? .descending : .ascending }
    }

    public var columnID: String
    public var direction: Direction

    public init(columnID: String, direction: Direction = .ascending) {
        self.columnID = columnID
        self.direction = direction
    }

    /// Clicking a header: sort by it ascending, then flip, then flip back.
    ///
    /// Public because ``ShadTable`` takes a `sort` binding — driving it from
    /// your own state should follow the same cycle the headers do.
    public static func toggled(_ current: ShadTableSort?, for columnID: String) -> ShadTableSort {
        guard let current, current.columnID == columnID else {
            return ShadTableSort(columnID: columnID)
        }
        return ShadTableSort(columnID: columnID, direction: current.direction.flipped)
    }
}

/// The ghost button a sortable header wears.
struct ShadTableSortButton: View {
    @Environment(\.shadTheme) private var theme

    let title: String
    let direction: ShadTableSort.Direction?
    let action: () -> Void

    var body: some View {
        ShadButton(variant: .ghost, size: .default, action: action) {
            HStack(spacing: 6) {
                Text(title)
                // shadcn shows one static glyph; showing the direction once a
                // column is sorted costs nothing and answers "sorted how?".
                ShadIconView(icon, size: 16)
                    .foregroundStyle(
                        direction == nil ? theme.colors.mutedForeground : theme.colors.foreground
                    )
            }
        }
        .accessibilityLabel("\(title), \(sortDescription)")
    }

    private var icon: ShadIcon {
        switch direction {
        case .none: return .arrowUpDown
        case .ascending: return .arrowUp
        case .descending: return .arrowDown
        }
    }

    private var sortDescription: String {
        switch direction {
        case .none: return "not sorted"
        case .ascending: return "sorted ascending"
        case .descending: return "sorted descending"
        }
    }
}

/// The `size-6` ellipsis button that opens a row's menu.
struct ShadTableActionButton: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    let label: String
    let isOpen: Bool

    var body: some View {
        ShadIconView(.moreHorizontal, size: ShadTableMetrics.actionIconSize)
            .foregroundStyle(theme.colors.foreground)
            .frame(
                width: ShadTableMetrics.actionButtonSize,
                height: ShadTableMetrics.actionButtonSize
            )
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(isHovering || isOpen ? theme.colors.muted : .clear)
            )
            .shadHover($isHovering, enabled: isEnabled)
            .shadPointerCursor(isEnabled)
            .accessibilityLabel(label)
    }
}
