import SwiftUI
import ShadSwift

/// The rows shadcn's data table demo uses.
struct DocPayment: Identifiable, Hashable {
    let id: String
    let amount: Double
    let status: String
    let email: String

    static let sample: [DocPayment] = [
        DocPayment(id: "m5gr84i9", amount: 316, status: "Success", email: "ken99@example.com"),
        DocPayment(id: "3u1reuv4", amount: 242, status: "Success", email: "Abe45@example.com"),
        DocPayment(id: "derv1ws0", amount: 837, status: "Processing", email: "Monserrat44@example.com"),
        DocPayment(id: "5kma53ae", amount: 874, status: "Success", email: "Silas22@example.com"),
        DocPayment(id: "bhqecj4p", amount: 721, status: "Failed", email: "carmella@example.com"),
    ]

    var formattedAmount: String { amount.formatted(.currency(code: "USD")) }
}

@MainActor
extension DocCatalog {
    static var data: [DocComponent] {
        [table, pagination]
    }

    // MARK: - Table

    static var table: DocComponent {
        DocComponent(
            slug: "table",
            title: "Table",
            summary: "A table of rows and columns, with sorting, filtering, selection and pages.",
            group: "Data",
            anatomy: #"""
            ShadDataTable(rows, columns:)          // filter field, column picker, table, pages
            └── ShadTable(rows, columns:)          // the grid on its own
                └── ShadTableColumn(_:value:)      // text, formatted and styled per row
                    ShadTableColumn(_:content:)    // or any view you like
                    ShadTableColumn.actions        // the trailing ⋯ menu

            ShadTableQuery                         // filter, sort and page as plain functions
            """#,
            examples: [
                DocExample(
                    "Data table",
                    description: "Checkboxes, a sortable header, a right-aligned amount, a column picker, a filter and pages.",
                    width: 760,
                    code: #"""
                    struct Payment: Identifiable {
                        let id: String
                        let amount: Double
                        let status: String
                        let email: String
                    }

                    @State private var selected: Set<String> = []
                    @State private var query = ""

                    ShadDataTable(payments, columns: [
                        ShadTableColumn("Status", isSearchable: false, value: \.status),
                        ShadTableColumn(
                            "Email",
                            width: .flexible(min: 220),
                            value: \.email,
                            sortBy: { $0.email < $1.email }
                        ),
                        ShadTableColumn(
                            "Amount",
                            alignment: .trailing,
                            value: { $0.amount.formatted(.currency(code: "USD")) },
                            style: { _ in ShadTableCellStyle(weight: .medium) }
                        ),
                        ShadTableColumn.actions { payment in
                            ShadDropdownMenuLabel("Actions")
                            ShadDropdownMenuItem("Copy payment ID") { copy(payment.id) }
                            ShadDropdownMenuSeparator()
                            ShadDropdownMenuItem("View customer") { open(payment) }
                        },
                    ], selection: $selected, filter: $query,
                       filterPlaceholder: "Filter emails...", pageSize: 5)
                    """#
                ) {
                    DocDataTablePreview()
                },

                DocExample(
                    "Alignment, formatters and stylers",
                    description: "Every column decides how its value reads: the formatter turns 250.23 into $250.23, and the styler colours anything over $500.",
                    width: 760,
                    code: #"""
                    ShadTableColumn(
                        "Amount",
                        alignment: .trailing,                       // right-aligned
                        value: { $0.amount.formatted(.currency(code: "USD")) },   // formatter
                        style: { payment in                                       // styler
                            payment.amount > 500
                                ? ShadTableCellStyle(color: .red, weight: .medium, isMonospaced: true)
                                : ShadTableCellStyle(isMonospaced: true)
                        },
                        sortBy: { $0.amount < $1.amount }
                    )
                    """#
                ) {
                    DocStyledTablePreview()
                },

                DocExample(
                    "Cells of your own",
                    description: "A content column draws whatever it likes — a badge, an avatar, a sparkline — and says how it should be searched and sorted.",
                    width: 640,
                    code: #"""
                    ShadTableColumn(
                        "Status",
                        searchValue: \.status,
                        sortBy: { $0.status < $1.status }
                    ) { payment in
                        ShadBadge(payment.status, variant: payment.status == "Failed" ? .destructive : .secondary)
                    }
                    """#
                ) {
                    DocContentTablePreview()
                },

                DocExample(
                    "Empty",
                    description: "A filter that matches nothing keeps the header and says so.",
                    width: 560,
                    code: #"""
                    ShadDataTable(matches, columns: columns, emptyMessage: "No results.")
                    """#
                ) {
                    ShadTable(
                        [DocPayment](),
                        columns: [
                            ShadTableColumn("Status", value: \.status),
                            ShadTableColumn("Email", width: .flexible(min: 220), value: \.email),
                            ShadTableColumn("Amount", alignment: .trailing, value: \.formattedAmount),
                        ]
                    )
                },

                DocExample(
                    "Filtering, sorting and paging without the view",
                    description: "The same rules as plain functions, for a server-side page or a pre-computed slice.",
                    code: #"""
                    let matched = ShadTableQuery.filtered(payments, columns: columns, query: "example.com")
                    let ordered = ShadTableQuery.sorted(matched, columns: columns, by: sort)
                    let visible = ShadTableQuery.page(ordered, page: 1, pageSize: 10)

                    ShadTableQuery.pageCount(rowCount: ordered.count, pageSize: 10)
                    """#
                ),
            ],
            notes: [
                "Cells are laid out the way a browser lays out `table-layout: auto`: a column takes the width of its widest cell, and any room left over goes to the flexible columns, or in proportion to the automatic ones when there are none.",
                "Filtering runs before sorting, which runs before paging — so a page is always a slice of what the filter left behind, and changing the filter returns you to page one.",
                "Select-all covers the rows on the current page, matching shadcn; the count beside it is of everything the filter left.",
                "shadcn shows one static glyph on a sortable header. This one shows the direction once a column is sorted, which the static glyph cannot.",
                "A column with an empty title still occupies a cell — the actions column's header is blank, not absent.",
            ],
            api: [
                DocAPI(
                    "ShadTableColumn",
                    [
                        DocProperty("title", "String", "the header label"),
                        DocProperty("id", "String?", default: "the title", "identity, for hiding and sorting"),
                        DocProperty("alignment", "ShadTableAlignment", default: ".leading", "leading, center or trailing"),
                        DocProperty("width", "ShadTableColumnWidth", default: ".automatic", "automatic, flexible(min:) or fixed"),
                        DocProperty("canHide", "Bool", default: "true", "whether the column picker may hide it"),
                        DocProperty("isSearchable", "Bool", default: "true", "whether the filter searches it"),
                        DocProperty("value", "(Row) -> String", "the formatter"),
                        DocProperty("style", "((Row) -> ShadTableCellStyle)?", default: "nil", "the styler"),
                        DocProperty("sortBy", "((Row, Row) -> Bool)?", default: "nil", "makes the header sortable"),
                        DocProperty("content", "(Row) -> View", "draws the cell instead of formatting text"),
                    ]
                ),
                DocAPI(
                    "ShadTableCellStyle",
                    [
                        DocProperty("color", "Color?", default: "nil", "nil keeps the table's foreground"),
                        DocProperty("weight", "Font.Weight?", default: "nil", "nil keeps the table's weight"),
                        DocProperty("isMonospaced", "Bool", default: "false", "figures line up down the column"),
                        DocProperty("opacity", "Double?", default: "nil", "for dimming a row's value"),
                    ]
                ),
                DocAPI(
                    "ShadDataTable",
                    [
                        DocProperty("rows", "[Row]", "any Identifiable — a struct, or a SwiftData model"),
                        DocProperty("columns", "[ShadTableColumn<Row>]", "what to show and how"),
                        DocProperty("selection", "Binding<Set<Row.ID>>?", default: "nil", "nil leaves out the checkbox column"),
                        DocProperty("filter", "Binding<String>?", default: "nil", "nil keeps the query internal"),
                        DocProperty("showsFilter / showsColumnPicker", "Bool", default: "true", "the two toolbar controls"),
                        DocProperty("pageSize", "Int?", default: "10", "nil shows every row on one page"),
                        DocProperty("paginationStyle", "ShadTablePaginationStyle", default: ".simple", "simple is Previous/Next, numbered is the full strip"),
                        DocProperty("sort", "ShadTableSort?", default: "nil", "the column to open sorted by"),
                        DocProperty("emptyMessage", "String", default: "\"No results.\"", "shown when nothing matches"),
                    ]
                ),
            ]
        )
    }

    // MARK: - Pagination

    static var pagination: DocComponent {
        DocComponent(
            slug: "pagination",
            title: "Pagination",
            summary: "Page navigation with previous and next links.",
            group: "Data",
            anatomy: #"""
            ShadPagination(page:pageCount:siblingCount:showsLabels:)
            ├── Previous
            ├── page numbers, the current one an outline button
            ├── … where pages were left out
            └── Next

            ShadPagination.entries(page:pageCount:siblingCount:)   // the windowing on its own
            """#,
            examples: [
                DocExample(
                    "Default",
                    description: "The current page is an outline button; the rest are ghosts.",
                    width: 560,
                    code: #"""
                    @State private var page = 0

                    ShadPagination(page: $page, pageCount: 12)
                    """#
                ) {
                    ShadPagination(page: .constant(5), pageCount: 12)
                },

                DocExample(
                    "Few pages",
                    description: "Below the point where an ellipsis would save room, every page is listed.",
                    width: 560,
                    code: #"""
                    ShadPagination(page: $page, pageCount: 5)
                    """#
                ) {
                    ShadPagination(page: .constant(1), pageCount: 5)
                },

                DocExample(
                    "Compact",
                    description: "Without labels, and with a narrower window.",
                    width: 560,
                    code: #"""
                    ShadPagination(page: $page, pageCount: 20, siblingCount: 0, showsLabels: false)
                    """#
                ) {
                    ShadPagination(page: .constant(6), pageCount: 20, siblingCount: 0, showsLabels: false)
                },
            ],
            notes: [
                "Pages are zero-based in the binding and shown one-based, so the value drops straight into an array slice.",
                "The first and last page are always present, and an ellipsis only appears where it hides more than one page — swapping a single number for a gap saves nothing.",
                "A page index outside the range clamps rather than trapping.",
            ],
            api: [
                DocAPI(
                    "ShadPagination",
                    [
                        DocProperty("page", "Binding<Int>", "the current page, counting from zero"),
                        DocProperty("pageCount", "Int", "how many pages there are"),
                        DocProperty("siblingCount", "Int", default: "1", "pages either side of the current one"),
                        DocProperty("showsLabels", "Bool", default: "true", "\"Previous\" and \"Next\" beside the chevrons"),
                    ]
                ),
            ]
        )
    }
}

// MARK: - Snapshot helpers

@MainActor
private var docColumns: [ShadTableColumn<DocPayment>] {
    [
        ShadTableColumn("Status", isSearchable: false, value: \.status),
        ShadTableColumn(
            "Email",
            width: .flexible(min: 220),
            value: \.email,
            sortBy: { $0.email < $1.email }
        ),
        ShadTableColumn(
            "Amount",
            alignment: .trailing,
            isSearchable: false,
            value: \.formattedAmount,
            style: { _ in ShadTableCellStyle(weight: .medium) }
        ),
        ShadTableColumn.actions { _ in
            ShadDropdownMenuItem("Copy payment ID") {}
        },
    ]
}

@MainActor
struct DocDataTablePreview: View {
    var body: some View {
        ShadDataTable(
            DocPayment.sample,
            columns: docColumns,
            selection: .constant(["3u1reuv4", "derv1ws0"]),
            filter: .constant(""),
            filterPlaceholder: "Filter emails...",
            pageSize: 5
        )
    }
}

@MainActor
struct DocStyledTablePreview: View {
    var body: some View {
        ShadTable(
            DocPayment.sample,
            columns: [
                ShadTableColumn("Reference", value: \.id),
                ShadTableColumn("Email", width: .flexible(min: 200), value: \.email),
                ShadTableColumn(
                    "Amount",
                    alignment: .trailing,
                    value: \.formattedAmount,
                    style: { payment in
                        payment.amount > 500
                            ? ShadTableCellStyle(color: .red, weight: .medium, isMonospaced: true)
                            : ShadTableCellStyle(isMonospaced: true)
                    }
                ),
                ShadTableColumn(
                    "Share",
                    alignment: .trailing,
                    value: { ($0.amount / 3_000).formatted(.percent.precision(.fractionLength(1))) },
                    style: { $0.amount > 500 ? .color(.orange) : .plain }
                ),
            ]
        )
    }
}

@MainActor
struct DocContentTablePreview: View {
    var body: some View {
        ShadTable(
            Array(DocPayment.sample.prefix(4)),
            columns: [
                ShadTableColumn("Status", searchValue: \.status) { payment in
                    ShadBadge(
                        payment.status,
                        variant: payment.status == "Failed" ? .destructive : .secondary
                    )
                },
                ShadTableColumn("Email", width: .flexible(min: 200), value: \.email),
                ShadTableColumn("Amount", alignment: .trailing, value: \.formattedAmount),
            ]
        )
    }
}
