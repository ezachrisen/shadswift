import SwiftUI

/// An autocomplete input with a list of suggestions.
///
/// The text field *is* the trigger, matching shadcn's `ComboboxInput`
/// anatomy. For the popup-trigger flavour — a button that opens a panel with
/// the search field inside it — use ``ShadComboboxButton``.
///
/// ```swift
/// ShadCombobox(selection: $framework, options: frameworks,
///              placeholder: "Select framework…", showsClear: true)
/// ```
public struct ShadCombobox<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.shadStaticRendering) private var isStatic
    @FocusState private var isFocused: Bool

    @Binding private var selection: Value?
    private let sections: [ShadSelectSection<Value>]
    private let placeholder: String
    private let emptyMessage: String
    private let size: ShadInputSize
    private let isInvalid: Bool
    private let showsClear: Bool
    private let autoHighlight: Bool
    private let icon: ShadIcon?
    private let width: CGFloat?

    @State private var query = ""
    @State private var isOpen = false
    @State private var highlighted: Value?

    public init(
        selection: Binding<Value?>,
        sections: [ShadSelectSection<Value>],
        placeholder: String = "Search…",
        emptyMessage: String = "No results found.",
        size: ShadInputSize = .default,
        isInvalid: Bool = false,
        showsClear: Bool = false,
        autoHighlight: Bool = true,
        icon: ShadIcon? = nil,
        width: CGFloat? = nil
    ) {
        self._selection = selection
        self.sections = sections
        self.placeholder = placeholder
        self.emptyMessage = emptyMessage
        self.size = size
        self.isInvalid = isInvalid
        self.showsClear = showsClear
        self.autoHighlight = autoHighlight
        self.icon = icon
        self.width = width
    }

    public init(
        selection: Binding<Value?>,
        options: [ShadSelectOption<Value>],
        placeholder: String = "Search…",
        emptyMessage: String = "No results found.",
        size: ShadInputSize = .default,
        isInvalid: Bool = false,
        showsClear: Bool = false,
        autoHighlight: Bool = true,
        icon: ShadIcon? = nil,
        width: CGFloat? = nil
    ) {
        self.init(
            selection: selection,
            sections: [ShadSelectSection(nil, options: options)],
            placeholder: placeholder,
            emptyMessage: emptyMessage,
            size: size,
            isInvalid: isInvalid,
            showsClear: showsClear,
            autoHighlight: autoHighlight,
            icon: icon,
            width: width
        )
    }

    private var allOptions: [ShadSelectOption<Value>] { sections.flatMap(\.options) }

    private var selectedOption: ShadSelectOption<Value>? {
        guard let selection else { return nil }
        return allOptions.first { $0.value == selection }
    }

    private var filtered: [ShadSelectSection<Value>] {
        guard isOpen, !query.isEmpty else { return sections }
        return sections
            .map { ShadSelectSection($0.label, options: $0.options.filter { $0.matches(query) }) }
            .filter { !$0.options.isEmpty }
    }

    private var filteredOptions: [ShadSelectOption<Value>] {
        filtered.flatMap(\.options).filter { !$0.isDisabled }
    }

    public var body: some View {
        ShadInputChrome(isFocused: isFocused || isOpen, isInvalid: isInvalid, height: size.height) {
            HStack(spacing: 8) {
                if let icon {
                    ShadIconView(icon, size: 16).foregroundStyle(theme.colors.mutedForeground)
                }
                if isStatic {
                    ShadStaticTextValue(
                        text: query,
                        placeholder: placeholder,
                        font: theme.font(size.fontSize(theme.typography))
                    )
                } else {
                TextField("", text: $query, prompt: Text(placeholder).foregroundColor(theme.colors.mutedForeground))
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .font(theme.font(size.fontSize(theme.typography)))
                    .foregroundStyle(theme.colors.foreground)
                    .onChange(of: query) { _, newValue in
                        if isFocused {
                            isOpen = true
                            if autoHighlight { highlighted = filteredOptions.first?.value }
                        }
                        if newValue.isEmpty { selection = nil }
                    }
                    .onChange(of: isFocused) { _, focused in
                        if focused { isOpen = true }
                    }
                }
                if showsClear, !query.isEmpty {
                    Button {
                        query = ""
                        selection = nil
                    } label: {
                        ShadIconView(.circleX, size: 14)
                            .foregroundStyle(theme.colors.mutedForeground)
                    }
                    .buttonStyle(.shadPlain)
                    .focusEffectDisabled()
                    .shadPointerCursor()
                }
                Button {
                    isOpen.toggle()
                    if isOpen { isFocused = true }
                } label: {
                    ShadIconView(.chevronDown, size: 14)
                        .foregroundStyle(theme.colors.mutedForeground)
                }
                .buttonStyle(.shadPlain)
                .focusEffectDisabled()
                .shadPointerCursor()
            }
        }
        .frame(width: width)
        .shadPopover(
            isPresented: $isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomLeading, gap: 4, matchesTriggerWidth: true),
            onKey: handleKey
        ) {
            ShadPopoverSurface {
                ShadOptionList(
                    sections: filtered,
                    selection: selection,
                    highlighted: $highlighted,
                    emptyMessage: emptyMessage,
                    onSelect: choose
                )
            }
        }
        .onAppear { query = selectedOption?.label ?? "" }
        .onChange(of: selection) { _, _ in
            if !isOpen { query = selectedOption?.label ?? "" }
        }
    }

    private func choose(_ option: ShadSelectOption<Value>) {
        selection = option.value
        query = option.label
        isOpen = false
        isFocused = false
    }

    private func handleKey(_ key: ShadPopoverKey) -> Bool {
        let options = filteredOptions
        guard !options.isEmpty else { return false }
        let index = options.firstIndex { $0.value == highlighted } ?? -1
        switch key {
        case .down:
            highlighted = options[min(index + 1, options.count - 1)].value
            return true
        case .up:
            highlighted = options[max(index - 1, 0)].value
            return true
        case .return:
            if let highlighted, let option = options.first(where: { $0.value == highlighted }) {
                choose(option)
            }
            return true
        default:
            return false
        }
    }
}

// MARK: - Multiple selection

/// A combobox that keeps its selections as chips, shadcn's `multiple` mode.
///
/// ```swift
/// ShadComboboxMultiple(selection: $frameworks, options: options)
/// ```
public struct ShadComboboxMultiple<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.shadStaticRendering) private var isStatic
    @FocusState private var isFocused: Bool

    @Binding private var selection: Set<Value>
    private let sections: [ShadSelectSection<Value>]
    private let placeholder: String
    private let emptyMessage: String
    private let isInvalid: Bool
    private let width: CGFloat?

    @State private var query = ""
    @State private var isOpen = false
    @State private var highlighted: Value?

    public init(
        selection: Binding<Set<Value>>,
        sections: [ShadSelectSection<Value>],
        placeholder: String = "Search…",
        emptyMessage: String = "No results found.",
        isInvalid: Bool = false,
        width: CGFloat? = nil
    ) {
        self._selection = selection
        self.sections = sections
        self.placeholder = placeholder
        self.emptyMessage = emptyMessage
        self.isInvalid = isInvalid
        self.width = width
    }

    public init(
        selection: Binding<Set<Value>>,
        options: [ShadSelectOption<Value>],
        placeholder: String = "Search…",
        emptyMessage: String = "No results found.",
        isInvalid: Bool = false,
        width: CGFloat? = nil
    ) {
        self.init(
            selection: selection,
            sections: [ShadSelectSection(nil, options: options)],
            placeholder: placeholder,
            emptyMessage: emptyMessage,
            isInvalid: isInvalid,
            width: width
        )
    }

    private var allOptions: [ShadSelectOption<Value>] { sections.flatMap(\.options) }

    private var chips: [ShadSelectOption<Value>] {
        allOptions.filter { selection.contains($0.value) }
    }

    private var filtered: [ShadSelectSection<Value>] {
        guard !query.isEmpty else { return sections }
        return sections
            .map { ShadSelectSection($0.label, options: $0.options.filter { $0.matches(query) }) }
            .filter { !$0.options.isEmpty }
    }

    private var filteredOptions: [ShadSelectOption<Value>] {
        filtered.flatMap(\.options).filter { !$0.isDisabled }
    }

    /// ↑ ↓ move the highlight and Return commits it, so narrowing the list by
    /// typing and pressing Return picks the match.
    private func handleKey(_ key: ShadPopoverKey) -> Bool {
        let options = filteredOptions
        guard !options.isEmpty else { return false }
        let index = options.firstIndex { $0.value == highlighted } ?? -1
        switch key {
        case .down:
            highlighted = options[min(index + 1, options.count - 1)].value
            return true
        case .up:
            highlighted = options[max(index - 1, 0)].value
            return true
        case .return:
            let option = highlighted.flatMap { value in options.first { $0.value == value } }
                ?? options.first
            if let option { toggle(option) }
            return true
        default:
            return false
        }
    }

    public var body: some View {
        ShadInputChrome(
            isFocused: isFocused || isOpen,
            isInvalid: isInvalid,
            height: nil,
            horizontalPadding: 6,
            verticalPadding: 5
        ) {
            HStack(spacing: 6) {
                ShadWrapLayout(spacing: 4, lineSpacing: 4) {
                    ForEach(chips) { option in
                        chip(option)
                    }
                    if isStatic {
                        if chips.isEmpty {
                            ShadStaticTextValue(text: "", placeholder: placeholder)
                                .frame(minWidth: 60)
                        }
                    } else {
                        TextField("", text: $query, prompt: chips.isEmpty ? Text(placeholder).foregroundColor(theme.colors.mutedForeground) : nil)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .font(theme.font(theme.typography.sm))
                            .frame(minWidth: 60)
                            .onChange(of: query) { _, _ in
                                isOpen = true
                                highlighted = filteredOptions.first?.value
                            }
                            .onChange(of: isFocused) { _, focused in if focused { isOpen = true } }
                    }
                }
            }
        }
        .frame(width: width)
        .shadPopover(
            isPresented: $isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomLeading, gap: 4, matchesTriggerWidth: true),
            onKey: handleKey
        ) {
            ShadPopoverSurface {
                ShadOptionList(
                    sections: filtered,
                    selection: nil,
                    selectedValues: selection,
                    highlighted: $highlighted,
                    emptyMessage: emptyMessage,
                    onSelect: toggle
                )
            }
        }
    }

    private func chip(_ option: ShadSelectOption<Value>) -> some View {
        HStack(spacing: 4) {
            Text(option.label)
                .font(theme.font(theme.typography.xs, theme.typography.medium))
            Button {
                selection.remove(option.value)
            } label: {
                ShadIconView(.x, size: 10)
            }
            .buttonStyle(.shadPlain)
            .focusEffectDisabled()
            .shadPointerCursor()
        }
        .foregroundStyle(theme.colors.secondaryForeground)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            ShadRoundedRectangle(cornerRadius: theme.radius.sm)
                .fill(theme.colors.secondary)
        )
    }

    private func toggle(_ option: ShadSelectOption<Value>) {
        if selection.contains(option.value) {
            selection.remove(option.value)
        } else {
            selection.insert(option.value)
        }
        query = ""
        highlighted = nil
    }
}

// MARK: - Popup trigger mode

/// The combobox's popup-trigger mode: a button opens a panel that holds the
/// search field and the list. This is shadcn's `render={<Button/>}` example.
public struct ShadComboboxButton<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme

    @Binding private var selection: Value?
    private let sections: [ShadSelectSection<Value>]
    private let placeholder: String
    private let searchPlaceholder: String
    private let emptyMessage: String
    private let width: CGFloat

    @State private var query = ""
    @State private var isOpen = false
    @State private var highlighted: Value?

    public init(
        selection: Binding<Value?>,
        options: [ShadSelectOption<Value>],
        placeholder: String = "Select…",
        searchPlaceholder: String = "Search…",
        emptyMessage: String = "No results found.",
        width: CGFloat = 220
    ) {
        self._selection = selection
        self.sections = [ShadSelectSection(nil, options: options)]
        self.placeholder = placeholder
        self.searchPlaceholder = searchPlaceholder
        self.emptyMessage = emptyMessage
        self.width = width
    }

    public init(
        selection: Binding<Value?>,
        sections: [ShadSelectSection<Value>],
        placeholder: String = "Select…",
        searchPlaceholder: String = "Search…",
        emptyMessage: String = "No results found.",
        width: CGFloat = 220
    ) {
        self._selection = selection
        self.sections = sections
        self.placeholder = placeholder
        self.searchPlaceholder = searchPlaceholder
        self.emptyMessage = emptyMessage
        self.width = width
    }

    private var allOptions: [ShadSelectOption<Value>] { sections.flatMap(\.options) }

    private var selectedOption: ShadSelectOption<Value>? {
        guard let selection else { return nil }
        return allOptions.first { $0.value == selection }
    }

    private var filtered: [ShadSelectSection<Value>] {
        guard !query.isEmpty else { return sections }
        return sections
            .map { ShadSelectSection($0.label, options: $0.options.filter { $0.matches(query) }) }
            .filter { !$0.options.isEmpty }
    }

    public var body: some View {
        Button {
            isOpen.toggle()
        } label: {
            ShadButtonSurface(
                variant: .outline,
                size: .default,
                shape: .rounded,
                isLoading: false,
                fillsWidth: true,
                isPressed: isOpen
            ) {
                HStack(spacing: 8) {
                    Text(selectedOption?.label ?? placeholder)
                        .foregroundStyle(selectedOption == nil ? theme.colors.mutedForeground : theme.colors.foreground)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    ShadIconView(.chevronDown, size: 14)
                        .foregroundStyle(theme.colors.mutedForeground)
                }
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .frame(width: width)
        .shadPointerCursor()
        .shadPopover(
            isPresented: $isOpen,
            configuration: ShadPopoverConfiguration(
                alignment: .bottomLeading,
                gap: 4,
                matchesTriggerWidth: true,
                becomesKey: true
            )
        ) {
            ShadPopoverSurface(padding: 0) {
                VStack(spacing: 0) {
                    ShadComboboxSearchField(text: $query, placeholder: searchPlaceholder)
                    ShadSeparator()
                    ShadOptionList(
                        sections: filtered,
                        selection: selection,
                        highlighted: $highlighted,
                        emptyMessage: emptyMessage,
                        onSelect: choose
                    )
                    .padding(4)
                }
            }
        }
    }

    private func choose(_ option: ShadSelectOption<Value>) {
        selection = option.value
        query = ""
        isOpen = false
    }
}

/// The search field inside a combobox panel.
public struct ShadComboboxSearchField: View {
    @Environment(\.shadTheme) private var theme
    @Binding var text: String
    let placeholder: String
    @Environment(\.shadStaticRendering) private var isStatic
    @FocusState private var isFocused: Bool

    public init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: 8) {
            ShadIconView(.search, size: 14)
                .foregroundStyle(theme.colors.mutedForeground)
            if isStatic {
                ShadStaticTextValue(text: text, placeholder: placeholder)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(theme.colors.mutedForeground))
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .font(theme.font(theme.typography.sm))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .task {
            try? await Task.sleep(nanoseconds: 60_000_000)
            isFocused = true
        }
    }
}
