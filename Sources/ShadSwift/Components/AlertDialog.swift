import SwiftUI

/// A modal dialog that interrupts the user with important content and expects
/// a response.
///
/// Unlike ``ShadDialogContent`` there is no close button and the backdrop does
/// not dismiss: the only way out is one of the two actions.
///
/// ```swift
/// ContentView()
///     .shadAlertDialog(isPresented: $isConfirming) {
///         ShadAlertDialogContent {
///             ShadAlertDialogTitle("Are you absolutely sure?")
///             ShadAlertDialogDescription(
///                 "This action cannot be undone. This will permanently delete "
///                 + "your account and remove your data from our servers."
///             )
///         } actions: {
///             ShadAlertDialogCancel("Cancel")
///             ShadAlertDialogAction("Continue") { delete() }
///         }
///     }
/// ```
extension View {
    /// Presents an alert dialog over this view.
    ///
    /// Attach it to the root of a window so the scrim covers everything.
    public func shadAlertDialog<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        shadDialog(isPresented: isPresented, dismissOnBackdropTap: false, content: content)
    }
}

/// The alert panel: header, optional body, and a right-aligned action row.
public struct ShadAlertDialogContent<Content: View, Actions: View>: View {
    @Environment(\.shadTheme) private var theme

    private let maxWidth: CGFloat
    private let content: Content
    private let actions: Actions

    public init(
        maxWidth: CGFloat = 448,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions
    ) {
        self.maxWidth = maxWidth
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                actions
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: maxWidth, alignment: .leading)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                .fill(theme.colors.background)
        )
        .overlay(
            ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                .strokeBorder(theme.colors.border, lineWidth: theme.borderWidth)
        )
        .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
        .shadElevation(theme.shadows.lg, cornerRadius: theme.radius.lg, fill: theme.colors.background)
        .padding(24)
        .accessibilityAddTraits(.isModal)
    }
}

/// The alert's heading.
public struct ShadAlertDialogTitle: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.lg, theme.typography.semibold))
            .foregroundStyle(theme.colors.foreground)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// The alert's supporting copy.
public struct ShadAlertDialogDescription: View {
    @Environment(\.shadTheme) private var theme
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.font(theme.typography.sm))
            .foregroundStyle(theme.colors.mutedForeground)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The dismissing action — an outline button that always closes the alert.
public struct ShadAlertDialogCancel: View {
    @Environment(\.shadDialogDismiss) private var dismiss

    private let title: String
    private let action: () -> Void

    public init(_ title: String = "Cancel", action: @escaping () -> Void = {}) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        ShadButton(title, variant: .outline) {
            action()
            dismiss()
        }
    }
}

/// The confirming action. Pass `variant: .destructive` for a deletion.
public struct ShadAlertDialogAction: View {
    @Environment(\.shadDialogDismiss) private var dismiss

    private let title: String
    private let variant: ShadButtonVariant
    private let dismissesOnTap: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        variant: ShadButtonVariant = .default,
        dismissesOnTap: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.dismissesOnTap = dismissesOnTap
        self.action = action
    }

    public var body: some View {
        ShadButton(title, variant: variant) {
            action()
            if dismissesOnTap { dismiss() }
        }
    }
}
