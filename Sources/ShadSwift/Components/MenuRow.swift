import SwiftUI

/// The measurements every popup list shares.
///
/// ``ShadSelect`` positions its panel so the selected row lands exactly on the
/// trigger, which means it has to predict the row geometry. Deriving both from
/// the same constants is what stops the label shifting as the menu opens.
enum ShadMenuMetrics {
    /// Padding inside ``ShadPopoverSurface``.
    static let surfacePadding: CGFloat = 4
    /// A row with a title only.
    static let rowHeight: CGFloat = 28
    /// A row that also carries a description.
    static let rowWithDescriptionHeight: CGFloat = 44
    /// shadcn stacks menu rows with no gap between them.
    static let rowSpacing: CGFloat = 0
    /// A section heading.
    static let labelHeight: CGFloat = 24
    /// A separator plus the 4pt breathing room on each side.
    static let separatorHeight: CGFloat = 9

    static func height(hasDescription: Bool) -> CGFloat {
        hasDescription ? rowWithDescriptionHeight : rowHeight
    }
}

/// The visual treatment of a menu row.
public enum ShadMenuItemVariant: String, CaseIterable, Sendable {
    case `default`
    case destructive
}

/// The row shared by ``ShadDropdownMenu``, ``ShadSelect`` and
/// ``ShadCombobox`` so every popup list looks identical.
///
/// It is public so you can build bespoke menu content that still matches the
/// rest of the library.
public struct ShadMenuRow<Leading: View, Trailing: View>: View {
    @Environment(\.shadTheme) private var theme

    var title: String
    var description: String? = nil
    var variant: ShadMenuItemVariant = .default
    var isHighlighted: Bool = false
    var isDisabled: Bool = false
    var isInset: Bool = false
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    public init(
        title: String,
        description: String? = nil,
        variant: ShadMenuItemVariant = .default,
        isHighlighted: Bool = false,
        isDisabled: Bool = false,
        isInset: Bool = false,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.description = description
        self.variant = variant
        self.isHighlighted = isHighlighted
        self.isDisabled = isDisabled
        self.isInset = isInset
        self.leading = leading
        self.trailing = trailing
    }

    private var foreground: Color {
        if isDisabled { return theme.colors.mutedForeground.opacity(0.6) }
        switch variant {
        case .default: return theme.colors.popoverForeground
        case .destructive: return theme.colors.destructive
        }
    }

    private var highlight: Color {
        switch variant {
        case .default: return theme.colors.accent
        case .destructive: return theme.colors.destructive.opacity(0.12)
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            leading()
                .frame(width: isInset ? 16 : nil, alignment: .center)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(theme.font(theme.typography.sm))
                    .lineLimit(1)
                if let description {
                    Text(description)
                        .font(theme.font(theme.typography.xs))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 6)
        // A fixed height, not a minimum: Select predicts these to place its
        // panel, and a row that grows by a point makes the label jump.
        .frame(height: ShadMenuMetrics.height(hasDescription: description != nil))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.md)
                .fill(isHighlighted && !isDisabled ? highlight : .clear)
        )
        .contentShape(Rectangle())
        .opacity(isDisabled ? 0.55 : 1)
    }
}

extension ShadMenuRow where Leading == EmptyView, Trailing == EmptyView {
    public init(
        title: String,
        description: String? = nil,
        variant: ShadMenuItemVariant = .default,
        isHighlighted: Bool = false,
        isDisabled: Bool = false,
        isInset: Bool = false
    ) {
        self.init(
            title: title,
            description: description,
            variant: variant,
            isHighlighted: isHighlighted,
            isDisabled: isDisabled,
            isInset: isInset,
            leading: { EmptyView() },
            trailing: { EmptyView() }
        )
    }
}

/// A section heading inside a popup list.
public struct ShadMenuLabel: View {
    @Environment(\.shadTheme) private var theme
    private let text: String
    private let isInset: Bool

    public init(_ text: String, isInset: Bool = false) {
        self.text = text
        self.isInset = isInset
    }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.xs, theme.typography.medium))
            .foregroundStyle(theme.colors.mutedForeground)
            .padding(.horizontal, 6)
            .padding(.leading, isInset ? 22 : 0)
            .frame(height: ShadMenuMetrics.labelHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The keyboard hint on the right of a menu row.
public struct ShadMenuShortcut: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.xs))
            .foregroundStyle(theme.colors.mutedForeground)
            .tracking(1)
    }
}
