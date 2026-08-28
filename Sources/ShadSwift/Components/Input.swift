import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Input heights. `default` is 32pt, matching shadcn's `h-8`.
public enum ShadInputSize: String, CaseIterable, Sendable {
    case sm
    case `default`
    case lg

    var height: CGFloat {
        switch self {
        case .sm: return 28
        case .default: return 32
        case .lg: return 36
        }
    }

    func fontSize(_ typography: ShadTypography) -> CGFloat {
        self == .sm ? typography.sm - 1.2 : typography.sm
    }
}

/// The chrome shared by every text control: border, fill, focus ring and
/// invalid state. ``ShadInput``, ``ShadTextarea``, ``ShadSelect`` and the
/// combobox trigger all render through it.
///
/// Measured from shadcn: `h-8 rounded-lg border border-input bg-transparent
/// px-2.5` with no shadow at all. The ring is 3pt and shows for focus *and*
/// for the invalid state, which is the soft red halo around the red border.
struct ShadInputChrome<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var isFocused: Bool
    var isInvalid: Bool
    var height: CGFloat?
    var horizontalPadding: CGFloat = 10
    var verticalPadding: CGFloat = 0
    /// Text fields ring on click as well as on tab; a Select trigger is a
    /// button, so it should follow `:focus-visible` and ring only for the
    /// keyboard.
    var keyboardOnlyFocusRing: Bool = false
    @ViewBuilder var content: () -> Content

    private var borderColor: Color {
        if isInvalid { return theme.colors.destructive }
        if isFocused { return theme.colors.ring }
        return theme.colors.input
    }

    private var ringColor: Color {
        isInvalid ? theme.colors.destructive : theme.colors.ring
    }

    private var fill: Color {
        guard isEnabled else { return theme.colors.input.opacity(0.5) }
        return theme.colorScheme == .dark ? theme.colors.input.opacity(0.3) : .clear
    }

    var body: some View {
        content()
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(height: height)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg).fill(fill)
            )
            .overlay(
                ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                    .strokeBorder(borderColor, lineWidth: theme.borderWidth)
            )
            .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
            .shadFocusRing(
                theme.radius.lg,
                isFocused: isFocused,
                keyboardOnly: keyboardOnlyFocusRing,
                isPersistent: isInvalid,
                theme: theme,
                color: ringColor
            )
            .opacity(isEnabled ? 1 : 0.5)
            .animation(theme.interactionAnimation, value: isFocused)
            .animation(theme.interactionAnimation, value: isInvalid)
    }
}

/// A text input.
///
/// ```swift
/// ShadInput("Email", text: $email)
/// ShadInput("Password", text: $password, isSecure: true)
/// ShadInput("Search", text: $query, icon: .search)
/// ShadInput("Username", text: $name, isInvalid: true)
/// ```
public struct ShadInput<Leading: View, Trailing: View>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.shadStaticRendering) private var isStatic
    @FocusState private var isFocused: Bool

    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let size: ShadInputSize
    private let isInvalid: Bool
    private let onSubmit: (() -> Void)?
    private let leading: Leading
    private let trailing: Trailing

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        size: ShadInputSize = .default,
        isInvalid: Bool = false,
        onSubmit: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.size = size
        self.isInvalid = isInvalid
        self.onSubmit = onSubmit
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        ShadInputChrome(
            isFocused: isFocused,
            isInvalid: isInvalid,
            height: size.height
        ) {
            HStack(spacing: 8) {
                leading
                    .foregroundStyle(theme.colors.mutedForeground)
                field
                trailing
                    .foregroundStyle(theme.colors.mutedForeground)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private var field: some View {
        if isStatic {
            ShadStaticTextValue(
                text: text,
                placeholder: placeholder,
                isSecure: isSecure,
                font: theme.font(size.fontSize(theme.typography))
            )
        } else {
            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: promptText)
                } else {
                    TextField("", text: $text, prompt: promptText)
                }
            }
            .textFieldStyle(.plain)
            .focused($isFocused)
            .font(theme.font(size.fontSize(theme.typography)))
            .foregroundStyle(theme.colors.foreground)
            .onSubmit { onSubmit?() }
        }
    }

    private var promptText: Text? {
        placeholder.isEmpty
            ? nil
            : Text(placeholder).foregroundColor(theme.colors.mutedForeground)
    }
}

extension ShadInput where Leading == EmptyView, Trailing == EmptyView {
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        size: ShadInputSize = .default,
        isInvalid: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self.init(
            placeholder,
            text: text,
            isSecure: isSecure,
            size: size,
            isInvalid: isInvalid,
            onSubmit: onSubmit,
            leading: { EmptyView() },
            trailing: { EmptyView() }
        )
    }
}

extension ShadInput where Leading == ShadIconView, Trailing == EmptyView {
    /// An input with a leading icon, the shadcn "input group" pattern.
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        icon: ShadIcon,
        isSecure: Bool = false,
        size: ShadInputSize = .default,
        isInvalid: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self.init(
            placeholder,
            text: text,
            isSecure: isSecure,
            size: size,
            isInvalid: isInvalid,
            onSubmit: onSubmit,
            leading: { ShadIconView(icon, size: 16) },
            trailing: { EmptyView() }
        )
    }
}

/// The `type="file"` flavour of Input: a button plus the chosen file's name.
public struct ShadFileInput: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var url: URL?
    private let prompt: String
    private let allowedExtensions: [String]?
    private let size: ShadInputSize
    private let isInvalid: Bool

    public init(
        url: Binding<URL?>,
        prompt: String = "Choose file",
        allowedExtensions: [String]? = nil,
        size: ShadInputSize = .default,
        isInvalid: Bool = false
    ) {
        self._url = url
        self.prompt = prompt
        self.allowedExtensions = allowedExtensions
        self.size = size
        self.isInvalid = isInvalid
    }

    public var body: some View {
        ShadInputChrome(isFocused: false, isInvalid: isInvalid, height: size.height) {
            HStack(spacing: 10) {
                // shadcn styles the file button as plain medium text:
                // `file:border-0 file:bg-transparent file:text-sm file:font-medium`.
                Button(action: choose) {
                    Text(prompt)
                        .font(theme.font(size.fontSize(theme.typography), theme.typography.medium))
                        .foregroundStyle(theme.colors.foreground)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadPointerCursor()
                Text(url?.lastPathComponent ?? "No file chosen")
                    .font(theme.font(size.fontSize(theme.typography)))
                    .foregroundStyle(url == nil ? theme.colors.mutedForeground : theme.colors.foreground)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer(minLength: 0)
            }
        }
    }

    private func choose() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if let allowedExtensions {
            panel.allowedContentTypes = allowedExtensions.compactMap { UTType(filenameExtension: $0) }
        }
        if panel.runModal() == .OK {
            url = panel.url
        }
    }
}
