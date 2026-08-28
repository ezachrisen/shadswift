import SwiftUI

/// One option in a ``ShadSelect`` or ``ShadCombobox``.
public struct ShadSelectOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let label: String
    public var description: String?
    public var icon: ShadIcon?
    public var isDisabled: Bool
    /// Extra text matched when filtering a combobox.
    public var keywords: [String]

    public init(
        _ label: String,
        value: Value,
        description: String? = nil,
        icon: ShadIcon? = nil,
        isDisabled: Bool = false,
        keywords: [String] = []
    ) {
        self.value = value
        self.label = label
        self.description = description
        self.icon = icon
        self.isDisabled = isDisabled
        self.keywords = keywords
    }

    public var id: Value { value }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let needle = query.lowercased()
        if label.lowercased().contains(needle) { return true }
        if let description, description.lowercased().contains(needle) { return true }
        return keywords.contains { $0.lowercased().contains(needle) }
    }
}

extension ShadSelectOption where Value == String {
    /// A option whose value is its own label.
    public init(_ label: String, description: String? = nil, icon: ShadIcon? = nil, isDisabled: Bool = false) {
        self.init(label, value: label, description: description, icon: icon, isDisabled: isDisabled)
    }
}

/// A labelled group of options, rendered with a heading and a separator.
public struct ShadSelectSection<Value: Hashable>: Identifiable {
    public let label: String?
    public let options: [ShadSelectOption<Value>]
    public let id: String

    public init(_ label: String? = nil, options: [ShadSelectOption<Value>]) {
        self.label = label
        self.options = options
        self.id = label ?? "section-\(options.first.map { String(describing: $0.value) } ?? "empty")"
    }
}

/// The Select trigger's height.
///
/// shadcn's Select is a single size — 32pt with a 14pt label. Offering a
/// smaller one drops the trigger's type below the 14pt used by the panel rows,
/// so the label changes size as the menu opens.
private let shadSelectTriggerHeight: CGFloat = 32

/// Displays a list of options for the user to pick from, triggered by a button.
///
/// ```swift
/// ShadSelect(selection: $theme, options: [
///     ShadSelectOption("Light", value: Theme.light),
///     ShadSelectOption("Dark", value: Theme.dark),
/// ], placeholder: "Theme")
/// ```
public struct ShadSelect<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: Value?
    private let sections: [ShadSelectSection<Value>]
    private let placeholder: String
    private let isInvalid: Bool
    private let width: CGFloat?
    private let externalIsOpen: Binding<Bool>?

    @State private var internalIsOpen = false
    @State private var highlighted: Value?
    @FocusState private var isFocused: Bool

    public init(
        selection: Binding<Value?>,
        sections: [ShadSelectSection<Value>],
        placeholder: String = "Select…",
        isInvalid: Bool = false,
        width: CGFloat? = nil,
        isOpen: Binding<Bool>? = nil
    ) {
        self._selection = selection
        self.sections = sections
        self.placeholder = placeholder
        self.isInvalid = isInvalid
        self.width = width
        self.externalIsOpen = isOpen
    }

    public init(
        selection: Binding<Value?>,
        options: [ShadSelectOption<Value>],
        placeholder: String = "Select…",
        isInvalid: Bool = false,
        width: CGFloat? = nil,
        isOpen: Binding<Bool>? = nil
    ) {
        self.init(
            selection: selection,
            sections: [ShadSelectSection(nil, options: options)],
            placeholder: placeholder,
            isInvalid: isInvalid,
            width: width,
            isOpen: isOpen
        )
    }



    /// Controlled when an `isOpen` binding was supplied, uncontrolled otherwise.
    private var isOpen: Binding<Bool> { externalIsOpen ?? $internalIsOpen }

    private var allOptions: [ShadSelectOption<Value>] {
        sections.flatMap(\.options)
    }

    private var selectedOption: ShadSelectOption<Value>? {
        guard let selection else { return nil }
        return allOptions.first { $0.value == selection }
    }

    /// How far down the panel the selected row starts, so it can be laid over
    /// the trigger the way a shadcn Select — and a macOS pop-up button — does.
    ///
    /// The arithmetic uses ``ShadMenuMetrics``, the same constants the rows are
    /// laid out with, so the label cannot shift as the panel opens.
    private var anchorOffset: CGFloat {
        var offset = ShadMenuMetrics.surfacePadding
        for (index, section) in sections.enumerated() {
            if section.label != nil {
                if index > 0 { offset += ShadMenuMetrics.separatorHeight }
                offset += ShadMenuMetrics.labelHeight + ShadMenuMetrics.rowSpacing
            }
            for option in section.options {
                if option.value == selection {
                    return offset - centeringInset(for: option)
                }
                offset += ShadMenuMetrics.height(hasDescription: option.description != nil)
                    + ShadMenuMetrics.rowSpacing
            }
        }
        // Nothing selected: the first row lands on the trigger.
        return ShadMenuMetrics.surfacePadding - centeringInset(for: allOptions.first)
    }

    /// A menu row is 28pt tall and the trigger is 32, so lining up their top
    /// edges leaves the two labels 2pt apart — which reads as the text hopping
    /// as the panel opens. Centre the row on the trigger instead.
    private func centeringInset(for option: ShadSelectOption<Value>?) -> CGFloat {
        let rowHeight = ShadMenuMetrics.height(hasDescription: option?.description != nil)
        return (shadSelectTriggerHeight - rowHeight) / 2
    }

    public var body: some View {
        Button {
            isOpen.wrappedValue.toggle()
            highlighted = selection ?? allOptions.first(where: { !$0.isDisabled })?.value
        } label: {
            trigger
        }
        .buttonStyle(.shadPlain)
        .focusable(isEnabled)
        .focused($isFocused)
        .focusEffectDisabled()
        .shadPointerCursor(isEnabled)
        .frame(width: width)
        .shadPopover(
            isPresented: isOpen,
            configuration: ShadPopoverConfiguration(
                alignment: .overTrigger,
                gap: 0,
                matchesTriggerWidth: true,
                verticalAnchorOffset: anchorOffset
            ),
            onKey: handleKey
        ) {
            ShadPopoverSurface {
                ShadOptionList(
                    sections: sections,
                    selection: selection,
                    highlighted: $highlighted,
                    emptyMessage: "No options.",
                    onSelect: choose
                )
            }
        }
    }

    private var trigger: some View {
        // No ring while the panel is open: the panel sits directly on top of the
        // trigger, and a 3pt ring would peek out on either side of it.
        ShadInputChrome(
            isFocused: isFocused && !isOpen.wrappedValue,
            isInvalid: isInvalid,
            height: shadSelectTriggerHeight,
            keyboardOnlyFocusRing: true
        ) {
            HStack(spacing: 8) {
                if let icon = selectedOption?.icon {
                    ShadIconView(icon, size: 16)
                        .foregroundStyle(theme.colors.mutedForeground)
                }
                Text(selectedOption?.label ?? placeholder)
                    .font(theme.font(theme.typography.sm))
                    .foregroundStyle(selectedOption == nil ? theme.colors.mutedForeground : theme.colors.foreground)
                    .lineLimit(1)
                Spacer(minLength: 0)
                ShadIconView(.chevronDown, size: 14)
                    .foregroundStyle(theme.colors.mutedForeground)
            }
        }
    }

    private func choose(_ option: ShadSelectOption<Value>) {
        selection = option.value
        isOpen.wrappedValue = false
    }

    private func handleKey(_ key: ShadPopoverKey) -> Bool {
        let enabled = allOptions.filter { !$0.isDisabled }
        guard !enabled.isEmpty else { return false }
        let index = enabled.firstIndex { $0.value == highlighted } ?? -1

        switch key {
        case .down:
            highlighted = enabled[min(index + 1, enabled.count - 1)].value
            return true
        case .up:
            highlighted = enabled[max(index - 1, 0)].value
            return true
        case .home:
            highlighted = enabled.first?.value
            return true
        case .end:
            highlighted = enabled.last?.value
            return true
        case .return:
            if let highlighted, let option = enabled.first(where: { $0.value == highlighted }) {
                choose(option)
            }
            return true
        default:
            return false
        }
    }
}

/// The scrollable list of options shared by Select and Combobox.
struct ShadOptionList<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme

    let sections: [ShadSelectSection<Value>]
    var selection: Value?
    var selectedValues: Set<Value> = []
    @Binding var highlighted: Value?
    var emptyMessage: String
    var onSelect: (ShadSelectOption<Value>) -> Void

    private var isEmpty: Bool { sections.allSatisfy { $0.options.isEmpty } }

    var body: some View {
        Group {
            if isEmpty {
                Text(emptyMessage)
                    .font(theme.font(theme.typography.sm))
                    .foregroundStyle(theme.colors.mutedForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ShadScrollContainer {
                        VStack(alignment: .leading, spacing: ShadMenuMetrics.rowSpacing) {
                            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                                if let label = section.label {
                                    if index > 0 { ShadSeparator().padding(.vertical, 4) }
                                    ShadMenuLabel(label)
                                }
                                ForEach(section.options) { option in
                                    row(for: option)
                                        .id(option.value)
                                }
                            }
                        }
                    }
                    .onChange(of: highlighted) { _, value in
                        if let value { withAnimation(.none) { proxy.scrollTo(value) } }
                    }
                }
            }
        }
    }

    private func isSelected(_ option: ShadSelectOption<Value>) -> Bool {
        selection == option.value || selectedValues.contains(option.value)
    }

    private func row(for option: ShadSelectOption<Value>) -> some View {
        Button {
            guard !option.isDisabled else { return }
            onSelect(option)
        } label: {
            ShadMenuRow(
                title: option.label,
                description: option.description,
                isHighlighted: highlighted == option.value,
                isDisabled: option.isDisabled
            ) {
                if let icon = option.icon {
                    ShadIconView(icon, size: 16)
                }
            } trailing: {
                if isSelected(option) {
                    ShadIconView(.check, size: 14)
                }
            }
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .onHover { hovering in
            if hovering, !option.isDisabled { highlighted = option.value }
        }
        .shadPointerCursor(!option.isDisabled)
    }
}
