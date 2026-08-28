import SwiftUI

/// A form label. Renders the small medium-weight text shadcn uses, dims itself
/// when the surrounding control is disabled, and can show a required marker.
public struct ShadLabel: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let text: String
    private let isRequired: Bool

    public init(_ text: String, isRequired: Bool = false) {
        self.text = text
        self.isRequired = isRequired
    }

    public var body: some View {
        HStack(spacing: 2) {
            Text(text)
            if isRequired {
                Text("*").foregroundStyle(theme.colors.destructive)
            }
        }
        .font(theme.font(theme.typography.sm, theme.typography.medium))
        .foregroundStyle(theme.colors.foreground)
        .opacity(isEnabled ? 1 : 0.5)
    }
}
