import SwiftUI

// MARK: - Trigger decoration

/// The affordance a date picker's trigger carries.
///
/// shadcn's examples use all three: a bare label, a leading calendar glyph, and
/// a trailing chevron with the label pushed to the left.
public enum ShadDatePickerIcon: Sendable, Hashable {
    /// Text only.
    case none
    /// A leading calendar glyph.
    case calendar
    /// A trailing chevron, with the label and the chevron pushed apart.
    case chevron
}

// MARK: - Formatting

/// How a picker turns a date into the text on its trigger.
public struct ShadDateFormat: Sendable {
    let format: @Sendable (Date, Locale, Calendar, TimeZone) -> String

    public init(_ format: @escaping @Sendable (Date, Locale, Calendar, TimeZone) -> String) {
        self.format = format
    }

    /// A `DateFormatter` style — `.medium` gives "Aug 27, 2026".
    public static func style(_ style: DateFormatter.Style) -> ShadDateFormat {
        ShadDateFormat { date, locale, calendar, timeZone in
            let formatter = DateFormatter()
            formatter.calendar = calendar
            formatter.locale = locale
            formatter.timeZone = timeZone
            formatter.dateStyle = style
            return formatter.string(from: date)
        }
    }

    /// A skeleton such as `"MMMM d, yyyy"`, localised for the reader.
    public static func template(_ template: String) -> ShadDateFormat {
        ShadDateFormat { date, locale, calendar, timeZone in
            let formatter = DateFormatter()
            formatter.calendar = calendar
            formatter.locale = locale
            formatter.timeZone = timeZone
            formatter.setLocalizedDateFormatFromTemplate(template)
            return formatter.string(from: date)
        }
    }

    /// The default: "Aug 27, 2026".
    public static let medium = ShadDateFormat.style(.medium)

    func callAsFunction(_ date: Date, locale: Locale, calendar: Calendar, timeZone: TimeZone) -> String {
        format(date, locale, calendar, timeZone)
    }
}

/// Everything both pickers pass straight through to their calendar.
struct ShadDatePickerOptions {
    var captionLayout: ShadCalendarCaptionLayout = .label
    var startMonth: Date?
    var endMonth: Date?
    var calendar: Calendar = .current
    var locale: Locale = .current
    var timeZone: TimeZone = .current
    var isDateDisabled: ((Date) -> Bool)?
    var showsOutsideDays: Bool = true
}

// MARK: - Date picker

/// A button that opens a calendar to pick one day.
///
/// ```swift
/// @State private var date: Date?
///
/// ShadField {
///     ShadFieldLabel("Date")
///     ShadDatePicker(selection: $date)
/// }
/// ```
///
/// Pass `captionLayout: .dropdown` for the date-of-birth pattern, where the
/// month and year become menus and paging back decades is one click.
public struct ShadDatePicker: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: Date?
    private let placeholder: String
    private let icon: ShadDatePickerIcon
    private let width: CGFloat?
    private let dateFormat: ShadDateFormat
    private let options: ShadDatePickerOptions
    private let externalIsOpen: Binding<Bool>?

    @State private var internalIsOpen = false
    @State private var visibleMonth: Date

    public init(
        selection: Binding<Date?>,
        placeholder: String = "Select date",
        icon: ShadDatePickerIcon = .chevron,
        width: CGFloat? = 176,
        format: ShadDateFormat = .medium,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil,
        isOpen: Binding<Bool>? = nil
    ) {
        self._selection = selection
        self.placeholder = placeholder
        self.icon = icon
        self.width = width
        self.dateFormat = format
        self.options = ShadDatePickerOptions(
            captionLayout: captionLayout,
            startMonth: startMonth,
            endMonth: endMonth,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone,
            isDateDisabled: isDateDisabled,
            showsOutsideDays: showsOutsideDays
        )
        self.externalIsOpen = isOpen
        var working = calendar
        working.timeZone = timeZone
        _visibleMonth = State(initialValue: working.startOfMonth(selection.wrappedValue ?? Date()))
    }

    private var isOpen: Binding<Bool> { externalIsOpen ?? $internalIsOpen }

    public var body: some View {
        ShadDatePickerTrigger(
            title: title,
            isPlaceholder: selection == nil,
            icon: icon,
            width: width,
            isOpen: isOpen.wrappedValue
        ) {
            if let selection { visibleMonth = options.calendar.startOfMonth(selection) }
            isOpen.wrappedValue.toggle()
        }
        .shadPopover(
            isPresented: isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomLeading, gap: 4, maxHeight: 420)
        ) {
            ShadPopoverSurface(padding: 0) {
                ShadCalendar(
                    selection: Binding(
                        get: { selection },
                        set: { newValue in
                            selection = newValue
                            if newValue != nil { isOpen.wrappedValue = false }
                        }
                    ),
                    month: $visibleMonth,
                    captionLayout: options.captionLayout,
                    showsOutsideDays: options.showsOutsideDays,
                    startMonth: options.startMonth,
                    endMonth: options.endMonth,
                    calendar: options.calendar,
                    locale: options.locale,
                    timeZone: options.timeZone,
                    isDateDisabled: options.isDateDisabled
                )
            }
        }
    }

    private var title: String {
        guard let selection else { return placeholder }
        return dateFormat(selection, locale: options.locale, calendar: options.calendar, timeZone: options.timeZone)
    }
}

// MARK: - Range picker

/// A button that opens a two-month calendar to pick a span of days.
///
/// ```swift
/// @State private var stay: ShadDateRange?
///
/// ShadDateRangePicker(range: $stay, width: 240)
/// ```
public struct ShadDateRangePicker: View {
    @Environment(\.shadTheme) private var theme

    @Binding private var range: ShadDateRange?
    private let placeholder: String
    private let icon: ShadDatePickerIcon
    private let width: CGFloat?
    private let numberOfMonths: Int
    private let dateFormat: ShadDateFormat
    private let options: ShadDatePickerOptions
    private let externalIsOpen: Binding<Bool>?

    @State private var internalIsOpen = false
    @State private var visibleMonth: Date

    public init(
        range: Binding<ShadDateRange?>,
        placeholder: String = "Pick a date range",
        icon: ShadDatePickerIcon = .calendar,
        width: CGFloat? = 240,
        numberOfMonths: Int = 2,
        format: ShadDateFormat = .medium,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil,
        isOpen: Binding<Bool>? = nil
    ) {
        self._range = range
        self.placeholder = placeholder
        self.icon = icon
        self.width = width
        self.numberOfMonths = numberOfMonths
        self.dateFormat = format
        self.options = ShadDatePickerOptions(
            captionLayout: captionLayout,
            startMonth: startMonth,
            endMonth: endMonth,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone,
            isDateDisabled: isDateDisabled,
            showsOutsideDays: showsOutsideDays
        )
        self.externalIsOpen = isOpen
        var working = calendar
        working.timeZone = timeZone
        _visibleMonth = State(initialValue: working.startOfMonth(range.wrappedValue?.from ?? Date()))
    }

    private var isOpen: Binding<Bool> { externalIsOpen ?? $internalIsOpen }

    public var body: some View {
        ShadDatePickerTrigger(
            title: title,
            isPlaceholder: range == nil,
            icon: icon,
            width: width,
            isOpen: isOpen.wrappedValue
        ) {
            if let from = range?.from { visibleMonth = options.calendar.startOfMonth(from) }
            isOpen.wrappedValue.toggle()
        }
        .shadPopover(
            isPresented: isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomLeading, gap: 4, maxHeight: 420)
        ) {
            ShadPopoverSurface(padding: 0) {
                ShadCalendar(
                    range: Binding(
                        get: { range },
                        set: { newValue in
                            range = newValue
                            // Stay open until both ends are picked.
                            if newValue?.isComplete == true { isOpen.wrappedValue = false }
                        }
                    ),
                    numberOfMonths: numberOfMonths,
                    month: $visibleMonth,
                    captionLayout: options.captionLayout,
                    showsOutsideDays: options.showsOutsideDays,
                    startMonth: options.startMonth,
                    endMonth: options.endMonth,
                    calendar: options.calendar,
                    locale: options.locale,
                    timeZone: options.timeZone,
                    isDateDisabled: options.isDateDisabled
                )
            }
        }
    }

    private var title: String {
        guard let range else { return placeholder }
        let from = format(range.from)
        guard let to = range.to else { return from }
        return "\(from) - \(format(to))"
    }

    private func format(_ date: Date) -> String {
        dateFormat(date, locale: options.locale, calendar: options.calendar, timeZone: options.timeZone)
    }
}

// MARK: - Shared trigger

/// The outline button both pickers open from.
struct ShadDatePickerTrigger: View {
    @Environment(\.shadTheme) private var theme

    let title: String
    let isPlaceholder: Bool
    let icon: ShadDatePickerIcon
    let width: CGFloat?
    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        ShadButton(variant: .outline, size: .default, fillsWidth: width != nil, action: action) {
            HStack(spacing: 6) {
                if icon == .calendar {
                    ShadIconView(.calendar, size: 16)
                        .foregroundStyle(theme.colors.mutedForeground)
                }
                Text(title)
                    .font(theme.font(theme.typography.sm))
                    .foregroundStyle(isPlaceholder ? theme.colors.mutedForeground : theme.colors.foreground)
                    .lineLimit(1)
                if icon == .chevron {
                    Spacer(minLength: 4)
                    ShadIconView(.chevronDown, size: 16)
                        .foregroundStyle(theme.colors.mutedForeground)
                } else {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: width)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isOpen ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Date input

/// A text field you can type a date into, with a calendar in the trailing
/// button — shadcn's "Input" date picker.
///
/// Typing is authoritative: whatever parses becomes the date, and the calendar
/// follows along as you type.
///
/// ```swift
/// @State private var date: Date? = Date()
///
/// ShadField {
///     ShadFieldLabel("Subscription Date")
///     ShadDateInput(selection: $date)
/// }
/// ```
public struct ShadDateInput: View {
    @Environment(\.shadTheme) private var theme

    @Binding private var selection: Date?
    private let placeholder: String
    private let dateFormat: ShadDateFormat
    private let options: ShadDatePickerOptions
    private let isInvalid: Bool

    @State private var text: String
    @State private var isOpen = false
    @State private var visibleMonth: Date

    public init(
        selection: Binding<Date?>,
        placeholder: String = "June 01, 2025",
        format: ShadDateFormat = .template("MMMM dd, yyyy"),
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil,
        isInvalid: Bool = false
    ) {
        self._selection = selection
        self.placeholder = placeholder
        self.dateFormat = format
        self.isInvalid = isInvalid
        self.options = ShadDatePickerOptions(
            captionLayout: captionLayout,
            startMonth: startMonth,
            endMonth: endMonth,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone,
            isDateDisabled: isDateDisabled,
            showsOutsideDays: showsOutsideDays
        )
        var working = calendar
        working.timeZone = timeZone
        let initial = selection.wrappedValue
        _text = State(initialValue: initial.map {
            format($0, locale: locale, calendar: calendar, timeZone: timeZone)
        } ?? "")
        _visibleMonth = State(initialValue: working.startOfMonth(initial ?? Date()))
    }

    public var body: some View {
        ShadInput(
            placeholder,
            text: $text,
            isInvalid: isInvalid,
            leading: { EmptyView() },
            trailing: {
                ShadDateInputButton(isOpen: isOpen) {
                    isOpen.toggle()
                }
            }
        )
        .onChange(of: text) { _, newValue in
            guard let parsed = parse(newValue) else { return }
            selection = parsed
            visibleMonth = options.calendar.startOfMonth(parsed)
        }
        .shadPopover(
            isPresented: $isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomTrailing, gap: 4, maxHeight: 420)
        ) {
            ShadPopoverSurface(padding: 0) {
                ShadCalendar(
                    selection: Binding(
                        get: { selection },
                        set: { newValue in
                            selection = newValue
                            if let newValue {
                                text = dateFormat(
                                    newValue,
                                    locale: options.locale,
                                    calendar: options.calendar,
                                    timeZone: options.timeZone
                                )
                                isOpen = false
                            }
                        }
                    ),
                    month: $visibleMonth,
                    captionLayout: options.captionLayout,
                    showsOutsideDays: options.showsOutsideDays,
                    startMonth: options.startMonth,
                    endMonth: options.endMonth,
                    calendar: options.calendar,
                    locale: options.locale,
                    timeZone: options.timeZone,
                    isDateDisabled: options.isDateDisabled
                )
            }
        }
    }

    /// Accepts anything `DateFormatter` recognises for the reader's locale,
    /// so "1 Aug 2026" works as well as the format the field writes back.
    private func parse(_ value: String) -> Date? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = options.calendar
        formatter.locale = options.locale
        formatter.timeZone = options.timeZone
        for style in [DateFormatter.Style.long, .medium, .short] {
            formatter.dateStyle = style
            if let date = formatter.date(from: trimmed) { return date }
        }
        formatter.dateStyle = .none
        formatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
        return formatter.date(from: trimmed)
    }
}

/// The 24pt calendar button that lives inside a ``ShadDateInput``.
struct ShadDateInputButton: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ShadIconView(.calendar, size: 16)
                .foregroundStyle(theme.colors.mutedForeground)
                .frame(width: 24, height: 24)
                .background(
                    ShadRoundedRectangle(cornerRadius: max(0, theme.radius.base - 3))
                        .fill(isHovering || isOpen ? theme.colors.muted : .clear)
                )
        }
        .buttonStyle(.shadPlain)
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .accessibilityLabel("Select date")
    }
}

// MARK: - Date and time

/// Whether a time reads on a 12-hour or a 24-hour clock.
public enum ShadClockStyle: String, CaseIterable, Sendable {
    /// 12-hour with a day period — "10:30 PM".
    case twelveHour
    /// 24-hour — "22:30".
    case twentyFourHour

    /// The pattern this clock writes back.
    func pattern(showsSeconds: Bool) -> String {
        switch self {
        case .twelveHour: return showsSeconds ? "h:mm:ss a" : "h:mm a"
        case .twentyFourHour: return showsSeconds ? "HH:mm:ss" : "HH:mm"
        }
    }

    /// What the field will read, most likely first.
    ///
    /// Each clock also accepts the other's notation, so "22:30" is understood
    /// in a 12-hour field and "10:30 PM" in a 24-hour one — the clock decides
    /// how a time is written, not what a person is allowed to type.
    var acceptedPatterns: [String] {
        let twelve = ["h:mm:ss a", "h:mm a"]
        let twentyFour = ["H:mm:ss", "H:mm"]
        return self == .twelveHour ? twelve + twentyFour : twentyFour + twelve
    }

    func placeholder(showsSeconds: Bool) -> String {
        switch self {
        case .twelveHour: return showsSeconds ? "10:30:00 PM" : "10:30 PM"
        case .twentyFourHour: return showsSeconds ? "22:30:00" : "22:30"
        }
    }

    /// Room for the longest time this clock writes.
    func fieldWidth(showsSeconds: Bool) -> CGFloat {
        switch self {
        case .twelveHour: return showsSeconds ? 132 : 112
        case .twentyFourHour: return showsSeconds ? 108 : 88
        }
    }

    /// Writes `date` in this clock's notation.
    ///
    /// ```swift
    /// ShadClockStyle.twelveHour.string(from: date)        // "10:30:00 PM"
    /// ShadClockStyle.twentyFourHour.string(from: date)    // "22:30:00"
    /// ```
    public func string(
        from date: Date,
        showsSeconds: Bool = true,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = pattern(showsSeconds: showsSeconds)
        return formatter.string(from: date)
    }

    /// Reads a time written in either clock's notation, tolerating a lower-case
    /// day period and a missing space before it.
    ///
    /// ```swift
    /// ShadClockStyle.twelveHour.time(from: "10:30 pm")   // 22:30:00
    /// ShadClockStyle.twelveHour.time(from: "22:30")      // 22:30:00
    /// ShadClockStyle.twelveHour.time(from: "half four")  // nil
    /// ```
    ///
    /// - Returns: The hour, minute and second, or `nil` if nothing read.
    public func time(
        from text: String,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> DateComponents? {
        let candidates = Self.readingCandidates(text)
        guard !candidates.isEmpty else { return nil }

        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone

        for pattern in acceptedPatterns {
            for locale in [locale, Locale(identifier: "en_US_POSIX")] {
                let formatter = DateFormatter()
                formatter.calendar = gregorian
                formatter.locale = locale
                formatter.timeZone = timeZone
                formatter.dateFormat = pattern
                for candidate in candidates {
                    if let parsed = formatter.date(from: candidate) {
                        return gregorian.dateComponents([.hour, .minute, .second], from: parsed)
                    }
                }
            }
        }
        return nil
    }

    /// The spellings of `value` worth trying, widest net last.
    private static func readingCandidates(_ value: String) -> [String] {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        var candidates = [trimmed]
        let upper = trimmed.uppercased()
        if upper != trimmed { candidates.append(upper) }
        // "10:30PM" — the space is easy to leave out.
        if let range = upper.range(of: "(?<=[0-9])(AM|PM)$", options: .regularExpression) {
            candidates.append(upper.replacingCharacters(in: range, with: " " + upper[range]))
        }
        return candidates
    }
}

/// A date picker beside a time field, both writing to one `Date`.
///
/// ```swift
/// @State private var appointment: Date? = Date()
///
/// ShadDateTimePicker(selection: $appointment)                       // 10:30:00 PM
/// ShadDateTimePicker(selection: $appointment, clock: .twentyFourHour) // 22:30:00
/// ```
public struct ShadDateTimePicker: View {
    @Environment(\.shadTheme) private var theme

    @Binding private var selection: Date?
    private let dateLabel: String
    private let timeLabel: String
    private let clock: ShadClockStyle
    private let showsSeconds: Bool
    private let dateWidth: CGFloat?
    private let timeWidth: CGFloat?
    private let dateFormat: ShadDateFormat
    private let options: ShadDatePickerOptions

    @State private var timeText: String

    public init(
        selection: Binding<Date?>,
        dateLabel: String = "Date",
        timeLabel: String = "Time",
        clock: ShadClockStyle = .twelveHour,
        showsSeconds: Bool = true,
        dateWidth: CGFloat? = 176,
        timeWidth: CGFloat? = nil,
        format: ShadDateFormat = .medium,
        captionLayout: ShadCalendarCaptionLayout = .label,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil
    ) {
        self._selection = selection
        self.dateLabel = dateLabel
        self.timeLabel = timeLabel
        self.clock = clock
        self.showsSeconds = showsSeconds
        self.dateWidth = dateWidth
        self.timeWidth = timeWidth ?? clock.fieldWidth(showsSeconds: showsSeconds)
        self.dateFormat = format
        self.options = ShadDatePickerOptions(
            captionLayout: captionLayout,
            startMonth: startMonth,
            endMonth: endMonth,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone,
            isDateDisabled: isDateDisabled
        )
        _timeText = State(initialValue: Self.timeString(
            for: selection.wrappedValue,
            clock: clock,
            showsSeconds: showsSeconds,
            locale: locale,
            timeZone: timeZone
        ))
    }

    public var body: some View {
        ShadFieldGroup(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                ShadField {
                    ShadFieldLabel(dateLabel)
                    ShadDatePicker(
                        selection: $selection,
                        icon: .chevron,
                        width: dateWidth,
                        format: dateFormat,
                        captionLayout: options.captionLayout,
                        startMonth: options.startMonth,
                        endMonth: options.endMonth,
                        calendar: options.calendar,
                        locale: options.locale,
                        timeZone: options.timeZone,
                        isDateDisabled: options.isDateDisabled
                    )
                }
                ShadField {
                    ShadFieldLabel(timeLabel)
                    ShadInput(clock.placeholder(showsSeconds: showsSeconds), text: $timeText)
                        .frame(width: timeWidth)
                        .onChange(of: timeText) { _, newValue in applyTime(newValue) }
                }
            }
        }
        .onChange(of: selection) { _, newValue in syncTimeText(with: newValue) }
        // Switching the clock has to rewrite the field: "10:30:05 PM" left
        // sitting in a 24-hour field would read as half past ten in the morning.
        .onChange(of: clock) { _, _ in retypeTime() }
        .onChange(of: showsSeconds) { _, _ in retypeTime() }
    }

    private var workingCalendar: Calendar {
        var working = options.calendar
        working.timeZone = options.timeZone
        working.locale = options.locale
        return working
    }

    /// Folds the typed time into the selected day, leaving the date alone.
    private func applyTime(_ value: String) {
        guard let parts = parseTime(value) else { return }
        let calendar = workingCalendar
        let day = selection ?? Date()
        guard let updated = calendar.date(
            bySettingHour: parts.hour ?? 0,
            minute: parts.minute ?? 0,
            second: parts.second ?? 0,
            of: day
        ) else { return }
        if selection != updated { selection = updated }
    }

    /// Rewrites the field when the date changes underneath it — but never while
    /// what is typed already means the same time.
    ///
    /// Without that guard, typing "10:30" in a 12-hour field would be read as
    /// morning and rewritten to "10:30 AM" before " PM" could be typed.
    private func syncTimeText(with date: Date?) {
        let canonical = Self.timeString(
            for: date,
            clock: clock,
            showsSeconds: showsSeconds,
            locale: options.locale,
            timeZone: options.timeZone
        )
        guard !canonical.isEmpty, canonical != timeText else { return }
        if let date, let typed = parseTime(timeText), matches(typed, date) { return }
        timeText = canonical
    }

    /// Rewrites the field in the current notation, whatever is in it.
    private func retypeTime() {
        let canonical = Self.timeString(
            for: selection,
            clock: clock,
            showsSeconds: showsSeconds,
            locale: options.locale,
            timeZone: options.timeZone
        )
        if !canonical.isEmpty, canonical != timeText { timeText = canonical }
    }

    private func parseTime(_ value: String) -> DateComponents? {
        clock.time(from: value, locale: options.locale, timeZone: options.timeZone)
    }

    private func matches(_ components: DateComponents, _ date: Date) -> Bool {
        let parts = workingCalendar.dateComponents([.hour, .minute, .second], from: date)
        return components.hour == parts.hour
            && components.minute == parts.minute
            && (components.second ?? 0) == (parts.second ?? 0)
    }

    private static func timeString(
        for date: Date?,
        clock: ShadClockStyle,
        showsSeconds: Bool,
        locale: Locale,
        timeZone: TimeZone
    ) -> String {
        guard let date else { return "" }
        return clock.string(from: date, showsSeconds: showsSeconds, locale: locale, timeZone: timeZone)
    }
}
