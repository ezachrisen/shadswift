import SwiftUI
import ShadSwift

/// A titled block on a component page.
struct DemoSection<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    let title: String
    var description: String? = nil
    @ViewBuilder var content: () -> Content

    init(_ title: String, description: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.description = description
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.font(theme.typography.base, theme.typography.semibold))
                    .foregroundStyle(theme.colors.foreground)
                if let description {
                    Text(description)
                        .font(theme.font(theme.typography.sm))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            content()
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .fill(theme.colors.card)
                )
                .overlay(
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
                )
        }
    }
}

/// A horizontal run of examples that wraps.
struct DemoRow<Content: View>: View {
    var spacing: CGFloat = 16
    @ViewBuilder var content: () -> Content

    init(spacing: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ShadWrapLayout(spacing: spacing, lineSpacing: spacing, alignment: .center) {
            content()
        }
    }
}

/// The page scaffold: heading, blurb, then sections.
struct DemoPage<Content: View>: View {
    @Environment(\.shadTheme) private var theme

    let title: String
    let subtitle: String
    @ViewBuilder var content: () -> Content

    init(title: String, subtitle: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(theme.font(34, theme.typography.semibold))
                        .foregroundStyle(theme.colors.foreground)
                    Text(subtitle)
                        .font(theme.font(theme.typography.base))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 4)
                content()
            }
            .padding(.horizontal, 48)
            .padding(.top, 44)
            .padding(.bottom, 96)
            .frame(maxWidth: 1000, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(theme.colors.background)
    }
}

/// Small caption used to label individual examples.
struct DemoCaption: View {
    @Environment(\.shadTheme) private var theme
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(theme.font(theme.typography.xs, .medium))
            .foregroundStyle(theme.colors.mutedForeground)
    }
}

/// A labelled example: caption above, example below.
struct DemoLabeled<Content: View>: View {
    let label: String
    var width: CGFloat? = nil
    @ViewBuilder var content: () -> Content

    init(label: String, width: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.width = width
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DemoCaption(label)
            content()
        }
        .frame(width: width, alignment: .leading)
    }
}
