import SwiftUI

/// How a data table lets you move between pages.
public enum ShadTablePaginationStyle: Sendable, Hashable {
    /// Previous and Next buttons, as on shadcn's data table.
    case simple
    /// The full ``ShadPagination`` strip, with page numbers.
    case numbered
}

/// A table with a filter field, a column picker, sortable headers, row
/// selection and pages — shadcn's data table, assembled.
///
/// The columns carry everything about how the data reads:
///
/// ```swift
/// ShadDataTable(payments, columns: [
///     ShadTableColumn("Status", value: \.status.capitalized),
///     ShadTableColumn("Email", value: \.email, sortBy: { $0.email < $1.email }),
///     ShadTableColumn(
///         "Amount",
///         alignment: .trailing,
///         value: { $0.amount.formatted(.currency(code: "USD")) },
///         style: { $0.amount > 100 ? .color(.red) : .plain }
///     ),
///     ShadTableColumn.actions { payment in
///         ShadDropdownMenuItem("Copy payment ID") { copy(payment.id) }
///     },
/// ], selection: $selected, filter: $query, pageSize: 5)
/// ```
///
/// Filtering, sorting and paging all happen in memory, in that order, so the
/// page always shows the rows the filter left behind.
public struct ShadDataTable<Row: Identifiable>: View {
    @Environment(\.shadTheme) private var theme

    private let rows: [Row]
    private let columns: [ShadTableColumn<Row>]
    private let selection: Binding<Set<Row.ID>>?
    private let externalFilter: Binding<String>?
    private let filterPlaceholder: String
    private let showsColumnPicker: Bool
    private let showsSelectionCount: Bool
    private let pageSize: Int?
    private let paginationStyle: ShadTablePaginationStyle
    private let emptyMessage: String
    private let bordered: Bool

    @State private var internalFilter = ""
    @State private var hiddenColumns: Set<String> = []
    @State private var sort: ShadTableSort?
    @State private var page = 0

    public init(
        _ rows: [Row],
        columns: [ShadTableColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        filter: Binding<String>? = nil,
        filterPlaceholder: String = "Filter…",
        showsFilter: Bool = true,
        showsColumnPicker: Bool = true,
        showsSelectionCount: Bool? = nil,
        pageSize: Int? = 10,
        paginationStyle: ShadTablePaginationStyle = .simple,
        sort: ShadTableSort? = nil,
        emptyMessage: String = "No results.",
        bordered: Bool = true
    ) {
        self.rows = rows
        self.columns = columns
        self.selection = selection
        self.externalFilter = filter
        self.filterPlaceholder = filterPlaceholder
        self.showsColumnPicker = showsColumnPicker
        self.showsSelectionCount = showsSelectionCount ?? (selection != nil)
        self.pageSize = pageSize
        self.paginationStyle = paginationStyle
        self.emptyMessage = emptyMessage
        self.bordered = bordered
        self.showsFilter = showsFilter
        _sort = State(initialValue: sort)
    }

    private let showsFilter: Bool

    private var filter: Binding<String> { externalFilter ?? $internalFilter }

    public var body: some View {
        VStack(spacing: 0) {
            if showsFilter || showsColumnPicker { toolbar }

            ShadTable(
                pageRows,
                columns: visibleColumns,
                selection: selection,
                sort: Binding(get: { sort }, set: { sort = $0 }),
                bordered: bordered,
                emptyMessage: emptyMessage
            )

            if showsSelectionCount || pageCount > 1 { footer }
        }
        .onChange(of: filter.wrappedValue) { _, _ in page = 0 }
        .onChange(of: rows.count) { _, _ in page = min(page, max(0, pageCount - 1)) }
    }

    // MARK: Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            if showsFilter {
                ShadInput(filterPlaceholder, text: filter)
                    .frame(maxWidth: 384)
            }
            Spacer(minLength: 0)
            if showsColumnPicker, !hideableColumns.isEmpty {
                ShadDropdownMenu(
                    "Columns",
                    variant: .outline,
                    showsChevron: true,
                    alignment: .bottomTrailing
                ) {
                    ForEach(hideableColumns) { column in
                        ShadDropdownMenuCheckboxItem(
                            column.title,
                            isOn: visibilityBinding(for: column)
                        )
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }

    private var hideableColumns: [ShadTableColumn<Row>] {
        columns.filter { $0.canHide && !$0.title.isEmpty }
    }

    private func visibilityBinding(for column: ShadTableColumn<Row>) -> Binding<Bool> {
        Binding(
            get: { !hiddenColumns.contains(column.id) },
            set: { isVisible in
                if isVisible { hiddenColumns.remove(column.id) }
                else { hiddenColumns.insert(column.id) }
            }
        )
    }

    private var visibleColumns: [ShadTableColumn<Row>] {
        columns.filter { !hiddenColumns.contains($0.id) }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 8) {
            if showsSelectionCount {
                Text("\(selection?.wrappedValue.count ?? 0) of \(filteredRows.count) row(s) selected.")
                    .font(theme.font(theme.typography.sm))
                    .foregroundStyle(theme.colors.mutedForeground)
            }
            Spacer(minLength: 0)
            if pageCount > 1 {
                switch paginationStyle {
                case .simple:
                    HStack(spacing: 8) {
                        ShadButton("Previous", variant: .outline, size: .sm) {
                            page = max(0, page - 1)
                        }
                        .disabled(page <= 0)
                        ShadButton("Next", variant: .outline, size: .sm) {
                            page = min(pageCount - 1, page + 1)
                        }
                        .disabled(page >= pageCount - 1)
                    }
                case .numbered:
                    ShadPagination(page: $page, pageCount: pageCount)
                }
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: Data

    /// Filter, then sort, then page — in that order, so a page is always a
    /// slice of what the filter left behind.
    var filteredRows: [Row] {
        let matched = ShadTableQuery.filtered(
            rows,
            columns: visibleColumns,
            query: filter.wrappedValue
        )
        return ShadTableQuery.sorted(matched, columns: columns, by: sort)
    }

    var pageCount: Int {
        ShadTableQuery.pageCount(rowCount: filteredRows.count, pageSize: pageSize)
    }

    var pageRows: [Row] {
        ShadTableQuery.page(filteredRows, page: page, pageSize: pageSize)
    }
}

// MARK: - Query

/// Filtering, sorting and paging as plain functions over rows.
///
/// ``ShadDataTable`` runs these in order — filter, sort, page — and they are
/// public so the same rules can be applied elsewhere: a server-side page, a
/// pre-computed slice, or a test.
public enum ShadTableQuery {
    /// The rows whose searchable columns contain `query`, case-insensitively.
    ///
    /// An empty or whitespace-only query matches everything. A column takes
    /// part only when it is searchable and knows how to render itself as text.
    public static func filtered<Row>(
        _ rows: [Row],
        columns: [ShadTableColumn<Row>],
        query: String
    ) -> [Row] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return rows }
        let needle = trimmed.lowercased()
        let searchable = columns.filter(\.isSearchable)
        guard !searchable.isEmpty else { return [] }
        return rows.filter { row in
            searchable.contains { column in
                column.searchText(for: row)?.lowercased().contains(needle) ?? false
            }
        }
    }

    /// The rows in the order `sort` asks for.
    ///
    /// Returns them untouched when nothing is sorted, when the column has gone
    /// away, or when that column has no comparator.
    public static func sorted<Row>(
        _ rows: [Row],
        columns: [ShadTableColumn<Row>],
        by sort: ShadTableSort?
    ) -> [Row] {
        guard let sort,
              let column = columns.first(where: { $0.id == sort.columnID }),
              let comparator = column.comparator
        else { return rows }
        let ascending = rows.sorted(by: comparator)
        return sort.direction == .ascending ? ascending : ascending.reversed()
    }

    /// How many pages `rowCount` rows fill. Always at least one, so a table
    /// with nothing in it still has a page to show.
    public static func pageCount(rowCount: Int, pageSize: Int?) -> Int {
        guard let pageSize, pageSize > 0 else { return 1 }
        return max(1, Int(ceil(Double(rowCount) / Double(pageSize))))
    }

    /// The slice of `rows` on `page`, counting from zero.
    ///
    /// A page past the end comes back empty rather than trapping.
    public static func page<Row>(_ rows: [Row], page: Int, pageSize: Int?) -> [Row] {
        guard let pageSize, pageSize > 0 else { return rows }
        let start = max(0, page) * pageSize
        guard start < rows.count else { return [] }
        return Array(rows[start..<min(start + pageSize, rows.count)])
    }
}
