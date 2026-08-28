import SwiftUI
import ShadSwift

// MARK: - Sample data

/// The rows from shadcn's data table demo.
struct Payment: Identifiable, Hashable {
    let id: String
    let amount: Double
    let status: Status
    let email: String

    enum Status: String, CaseIterable, Hashable {
        case pending, processing, success, failed

        var tone: ShadBadgeVariant {
            switch self {
            case .success: return .secondary
            case .failed: return .destructive
            default: return .outline
            }
        }
    }

    static let sample: [Payment] = [
        Payment(id: "m5gr84i9", amount: 316, status: .success, email: "ken99@example.com"),
        Payment(id: "3u1reuv4", amount: 242, status: .success, email: "Abe45@example.com"),
        Payment(id: "derv1ws0", amount: 837, status: .processing, email: "Monserrat44@example.com"),
        Payment(id: "5kma53ae", amount: 874, status: .success, email: "Silas22@example.com"),
        Payment(id: "bhqecj4p", amount: 721, status: .failed, email: "carmella@example.com"),
        Payment(id: "9xk2mq7t", amount: 95, status: .pending, email: "rowan@example.com"),
        Payment(id: "p4vn18cd", amount: 1_204, status: .success, email: "imani@example.com"),
        Payment(id: "t7yh32ba", amount: 58, status: .failed, email: "dev@example.com"),
        Payment(id: "w1qz65er", amount: 430, status: .processing, email: "kit@example.com"),
        Payment(id: "z8lp09uk", amount: 187, status: .success, email: "noor@example.com"),
        Payment(id: "c3bd47fm", amount: 62, status: .pending, email: "arlo@example.com"),
        Payment(id: "v6te21ns", amount: 990, status: .success, email: "sasha@example.com"),
    ]
}

private let currency: FloatingPointFormatStyle<Double>.Currency = .currency(code: "USD")

// MARK: - Table

struct TablePage: View {
    @State private var selection: Set<String> = []
    @State private var filter = ""
    @State private var lastAction = "—"

    @State private var plainSelection: Set<String> = []
    @State private var numberedFilter = ""

    var body: some View {
        DemoPage(title: "Table", subtitle: "A responsive table component with sorting, filtering, selection and pages.") {
            DemoSection(
                "Data table",
                description: "shadcn's demo, column for column: checkboxes, a sortable email header, a right-aligned amount, a column picker, a text filter and pages."
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    ShadDataTable(
                        Payment.sample,
                        columns: demoColumns,
                        selection: $selection,
                        filter: $filter,
                        filterPlaceholder: "Filter emails...",
                        pageSize: 5
                    )
                    DemoCaption(lastAction)
                }
            }

            DemoSection(
                "Alignment, formatters and stylers",
                description: "Each column decides how its value reads: a formatter turns 250.23 into $250.23, a styler colours anything over $500."
            ) {
                ShadDataTable(
                    Payment.sample,
                    columns: [
                        ShadTableColumn("Reference", value: \.id, sortBy: { $0.id < $1.id }),
                        ShadTableColumn(
                            "Email",
                            width: .flexible(min: 180),
                            value: \.email,
                            sortBy: { $0.email < $1.email }
                        ),
                        ShadTableColumn(
                            "Amount",
                            alignment: .trailing,
                            value: { $0.amount.formatted(currency) },
                            style: { payment in
                                payment.amount > 500
                                    ? ShadTableCellStyle(color: .red, weight: .medium, isMonospaced: true)
                                    : ShadTableCellStyle(isMonospaced: true)
                            },
                            sortBy: { $0.amount < $1.amount }
                        ),
                        ShadTableColumn(
                            "Share",
                            alignment: .trailing,
                            value: { ($0.amount / 6_000).formatted(.percent.precision(.fractionLength(1))) },
                            style: { $0.amount > 500 ? .color(.orange) : .plain }
                        ),
                    ],
                    showsFilter: false,
                    pageSize: 6,
                    paginationStyle: .numbered,
                    sort: ShadTableSort(columnID: "Amount", direction: .descending)
                )
            }

            DemoSection("Plain table", description: "ShadTable on its own — no toolbar, no pages.") {
                ShadTable(
                    Array(Payment.sample.prefix(4)),
                    columns: [
                        ShadTableColumn("Status") { payment in
                            ShadBadge(payment.status.rawValue.capitalized, variant: payment.status.tone)
                        },
                        ShadTableColumn("Email", width: .flexible(min: 200), value: \.email),
                        ShadTableColumn(
                            "Amount",
                            alignment: .trailing,
                            value: { $0.amount.formatted(currency) }
                        ),
                    ],
                    selection: $plainSelection
                )
            }

            DemoSection("Empty", description: "A filter that matches nothing keeps the header and says so.") {
                ShadDataTable(
                    [Payment](),
                    columns: [
                        ShadTableColumn("Status", value: { $0.status.rawValue.capitalized }),
                        ShadTableColumn("Email", width: .flexible(min: 200), value: \.email),
                    ],
                    showsFilter: false,
                    showsColumnPicker: false,
                    pageSize: nil
                )
            }
        }
    }

    private var demoColumns: [ShadTableColumn<Payment>] {
        [
            ShadTableColumn(
                "Status",
                isSearchable: false,
                value: { $0.status.rawValue.capitalized }
            ),
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
                value: { $0.amount.formatted(currency) },
                style: { _ in ShadTableCellStyle(weight: .medium) }
            ),
            ShadTableColumn.actions { payment in
                ShadDropdownMenuLabel("Actions")
                ShadDropdownMenuItem("Copy payment ID") { lastAction = "Copied \(payment.id)" }
                ShadDropdownMenuSeparator()
                ShadDropdownMenuItem("View customer") { lastAction = "Customer \(payment.email)" }
                ShadDropdownMenuItem("View payment details") { lastAction = "Details for \(payment.id)" }
            },
        ]
    }
}

// MARK: - Pagination

struct PaginationPage: View {
    @State private var page = 3
    @State private var shortPage = 1
    @State private var compactPage = 5

    var body: some View {
        DemoPage(title: "Pagination", subtitle: "Page navigation with previous and next links.") {
            DemoSection("Default", description: "The current page is an outline button; the rest are ghosts.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadPagination(page: $page, pageCount: 12)
                    DemoCaption("page \(page + 1) of 12")
                }
            }

            DemoSection("Few pages", description: "Below the point where an ellipsis would save room, every page is listed.") {
                ShadPagination(page: $shortPage, pageCount: 5)
            }

            DemoSection("Compact", description: "showsLabels: false leaves just the chevrons, and siblingCount narrows the window.") {
                ShadPagination(page: $compactPage, pageCount: 20, siblingCount: 0, showsLabels: false)
            }
        }
    }
}
