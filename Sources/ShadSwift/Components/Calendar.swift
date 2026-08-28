import SwiftUI

// MARK: - Range

/// A span of days, as selected by a range calendar.
///
/// `to` is `nil` between the two clicks that make a range, which is how the
/// calendar knows a selection is still in progress.
public struct ShadDateRange: Hashable, Sendable {
    public var from: Date
    public var to: Date?

    public init(from: Date, to: Date? = nil) {
        self.from = from
        self.to = to
    }

    /// True once both ends have been picked.
    public var isComplete: Bool { to != nil }

    /// The later end, falling back to `from` while the range is half-made.
    public var end: Date { to ?? from }

    /// Whether `day` falls inside the range, both ends included.
    public func contains(_ day: Date, in calendar: Calendar) -> Bool {
        let start = calendar.startOfDay(for: from)
        let finish = calendar.startOfDay(for: end)
        let target = calendar.startOfDay(for: day)
        return target >= start && target <= finish
    }
}

// MARK: - Configuration

/// How a calendar labels the month it is showing.
public enum ShadCalendarCaptionLayout: String, CaseIterable, Sendable {
    /// "August 2026", with arrows either side.
    case label
    /// Month and year both become dropdowns.
    case dropdown
    /// Only the month becomes a dropdown.
    case dropdownMonths
    /// Only the year becomes a dropdown.
    case dropdownYears

    var hasMonthDropdown: Bool { self == .dropdown || self == .dropdownMonths }
    var hasYearDropdown: Bool { self == .dropdown || self == .dropdownYears }
    var isDropdown: Bool { self != .label }
}

/// The measurements shadcn's calendar is built from.
///
/// shadcn drives these from `--cell-size` and `--cell-radius`; the sizes here
/// are the defaults those variables resolve to.
enum ShadCalendarMetrics {
    /// `--cell-size: --spacing(7)`
    static let cellSize: CGFloat = 28
    /// `gap-4` between the caption and the grid, and between months.
    static let sectionGap: CGFloat = 16
    /// `mt-2` above every week row.
    static let weekGap: CGFloat = 8
    /// The weekday header's line box.
    static let weekdayHeight: CGFloat = 22.4
    /// `p-2` around the whole calendar.
    static let padding: CGFloat = 8
    /// `[&>svg]:size-4` on the navigation buttons.
    static let navIconSize: CGFloat = 16
    /// `[&>svg]:size-3.5` beside a dropdown's label.
    static let dropdownIconSize: CGFloat = 14
}

// MARK: - Calendar

/// A month grid for picking a day, a set of days or a range.
///
/// ```swift
/// @State private var date: Date? = Date()
///
/// ShadCalendar(selection: $date, bordered: true)
/// ```
///
/// Range selection takes a ``ShadDateRange`` binding instead, and multiple
/// selection an array of dates:
///
/// ```swift
/// ShadCalendar(range: $stay, numberOfMonths: 2)
/// ShadCalendar(selection: $days)
/// ```
///
/// The grid follows the `Calendar`, `Locale` and `TimeZone` it is given, so a
/// Persian, Hijri or Japanese calendar needs nothing more than passing one:
///
/// ```swift
/// ShadCalendar(selection: $date, calendar: Calendar(identifier: .persian))
/// ```
public struct ShadCalendar: View {
    /// What the calendar writes back to when a day is clicked.
    enum Selection {
        case none
        case single(Binding<Date?>)
        case multiple(Binding<[Date]>)
        case range(Binding<ShadDateRange?>)
    }

    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let selection: Selection
    private let numberOfMonths: Int
    private let externalMonth: Binding<Date>?
    private let captionLayout: ShadCalendarCaptionLayout
    private let showsOutsideDays: Bool
    private let bordered: Bool
    private let axis: Axis
    private let startMonth: Date?
    private let endMonth: Date?
    private let baseCalendar: Calendar
    private let locale: Locale
    private let timeZone: TimeZone
    private let isDateDisabled: ((Date) -> Bool)?

    @State private var internalMonth: Date
    @State private var hoveredDay: Date?
    @State private var focusedDay: Date?

    init(
        selection: Selection,
        numberOfMonths: Int,
        month: Binding<Date>?,
        defaultMonth: Date?,
        captionLayout: ShadCalendarCaptionLayout,
        showsOutsideDays: Bool,
        bordered: Bool,
        axis: Axis,
        startMonth: Date?,
        endMonth: Date?,
        calendar: Calendar,
        locale: Locale,
        timeZone: TimeZone,
        isDateDisabled: ((Date) -> Bool)?
    ) {
        self.selection = selection
        self.numberOfMonths = max(1, numberOfMonths)
        self.externalMonth = month
        self.captionLayout = captionLayout
        self.showsOutsideDays = showsOutsideDays
        self.bordered = bordered
        self.axis = axis
        self.startMonth = startMonth
        self.endMonth = endMonth
        self.baseCalendar = calendar
        self.locale = locale
        self.timeZone = timeZone
        self.isDateDisabled = isDateDisabled

        var working = calendar
        working.timeZone = timeZone
        working.locale = locale
        let anchor = defaultMonth
            ?? month?.wrappedValue
            ?? Self.firstSelectedDate(in: selection)
            ?? Date()
        _internalMonth = State(initialValue: working.startOfMonth(anchor))
    }

    // MARK: Public initialisers

    /// A calendar that selects one day.
    public init(
        selection: Binding<Date?>,
        numberOfMonths: Int = 1,
        month: Binding<Date>? = nil,
        defaultMonth: Date? = nil,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        bordered: Bool = false,
        axis: Axis = .horizontal,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil
    ) {
        self.init(
            selection: .single(selection), numberOfMonths: numberOfMonths, month: month,
            defaultMonth: defaultMonth, captionLayout: captionLayout,
            showsOutsideDays: showsOutsideDays, bordered: bordered, axis: axis,
            startMonth: startMonth, endMonth: endMonth, calendar: calendar,
            locale: locale, timeZone: timeZone, isDateDisabled: isDateDisabled
        )
    }

    /// A calendar that selects any number of days.
    public init(
        selection: Binding<[Date]>,
        numberOfMonths: Int = 1,
        month: Binding<Date>? = nil,
        defaultMonth: Date? = nil,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        bordered: Bool = false,
        axis: Axis = .horizontal,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil
    ) {
        self.init(
            selection: .multiple(selection), numberOfMonths: numberOfMonths, month: month,
            defaultMonth: defaultMonth, captionLayout: captionLayout,
            showsOutsideDays: showsOutsideDays, bordered: bordered, axis: axis,
            startMonth: startMonth, endMonth: endMonth, calendar: calendar,
            locale: locale, timeZone: timeZone, isDateDisabled: isDateDisabled
        )
    }

    /// A calendar that selects a span of days.
    public init(
        range: Binding<ShadDateRange?>,
        numberOfMonths: Int = 1,
        month: Binding<Date>? = nil,
        defaultMonth: Date? = nil,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        bordered: Bool = false,
        axis: Axis = .horizontal,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil
    ) {
        self.init(
            selection: .range(range), numberOfMonths: numberOfMonths, month: month,
            defaultMonth: defaultMonth, captionLayout: captionLayout,
            showsOutsideDays: showsOutsideDays, bordered: bordered, axis: axis,
            startMonth: startMonth, endMonth: endMonth, calendar: calendar,
            locale: locale, timeZone: timeZone, isDateDisabled: isDateDisabled
        )
    }

    /// A calendar that shows dates without selecting any.
    public init(
        numberOfMonths: Int = 1,
        month: Binding<Date>? = nil,
        defaultMonth: Date? = nil,
        captionLayout: ShadCalendarCaptionLayout = .label,
        showsOutsideDays: Bool = true,
        bordered: Bool = false,
        axis: Axis = .horizontal,
        startMonth: Date? = nil,
        endMonth: Date? = nil,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        isDateDisabled: ((Date) -> Bool)? = nil
    ) {
        self.init(
            selection: .none, numberOfMonths: numberOfMonths, month: month,
            defaultMonth: defaultMonth, captionLayout: captionLayout,
            showsOutsideDays: showsOutsideDays, bordered: bordered, axis: axis,
            startMonth: startMonth, endMonth: endMonth, calendar: calendar,
            locale: locale, timeZone: timeZone, isDateDisabled: isDateDisabled
        )
    }

    // MARK: Body

    public var body: some View {
        // An overlay rather than a ZStack: the nav row ends in a Spacer, which
        // inside a ZStack would stretch the whole calendar to the width on
        // offer instead of the width of the months.
        months
            .overlay(alignment: .top) { navigation }
            .padding(ShadCalendarMetrics.padding)
            .background(bordered ? theme.colors.background : .clear)
            .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
            .overlay {
                if bordered {
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .strokeBorder(theme.colors.border, lineWidth: 1)
                }
            }
            .fixedSize()
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Calendar")
    }

    @ViewBuilder
    private var months: some View {
        let layout = axis == .horizontal
            ? AnyLayout(HStackLayout(alignment: .top, spacing: ShadCalendarMetrics.sectionGap))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: ShadCalendarMetrics.sectionGap))
        layout {
            ForEach(visibleMonths, id: \.timeIntervalSinceReferenceDate) { month in
                monthColumn(month)
            }
        }
    }

    private func monthColumn(_ month: Date) -> some View {
        VStack(spacing: ShadCalendarMetrics.sectionGap) {
            caption(for: month)
            grid(for: month)
        }
        .frame(width: ShadCalendarMetrics.cellSize * 7)
    }

    // MARK: Caption

    @ViewBuilder
    private func caption(for month: Date) -> some View {
        Group {
            if captionLayout.isDropdown {
                HStack(spacing: 6) {
                    if captionLayout.hasMonthDropdown {
                        monthDropdown(for: month)
                    } else {
                        Text(monthName(month)).fixedSize()
                    }
                    if captionLayout.hasYearDropdown {
                        yearDropdown(for: month)
                    } else {
                        Text(yearName(month)).fixedSize()
                    }
                }
            } else {
                Text(captionTitle(month)).fixedSize()
            }
        }
        .font(theme.font(theme.typography.sm, theme.typography.medium))
        .foregroundStyle(theme.colors.foreground)
        .frame(height: ShadCalendarMetrics.cellSize)
        .frame(maxWidth: .infinity)
        // `px-(--cell-size)`: the label never runs under the arrows.
        .padding(.horizontal, ShadCalendarMetrics.cellSize)
    }

    private func monthDropdown(for month: Date) -> some View {
        let symbols = workingCalendar.shortMonthSymbols
        let range = monthRange(for: month)
        return ShadCalendarDropdown(
            label: monthName(month),
            options: range.map { ShadSelectOption(symbols[$0 - 1], value: $0) },
            value: workingCalendar.component(.month, from: month)
        ) { newMonth in
            setMonth(monthByReplacing(month: newMonth, in: month))
        }
    }

    private func yearDropdown(for month: Date) -> some View {
        let years = yearRange()
        return ShadCalendarDropdown(
            label: yearName(month),
            options: years.map { ShadSelectOption(String($0), value: $0) },
            value: workingCalendar.component(.year, from: month)
        ) { newYear in
            setMonth(monthByReplacing(year: newYear, in: month))
        }
    }

    // MARK: Navigation

    private var navigation: some View {
        HStack(spacing: 4) {
            navButton(.chevronLeft, enabled: canGoBack) { step(-1) }
            Spacer(minLength: 0)
            navButton(.chevronRight, enabled: canGoForward) { step(1) }
        }
        .frame(height: ShadCalendarMetrics.cellSize)
    }

    private func navButton(
        _ icon: ShadIcon,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        ShadCalendarNavButton(icon: icon, action: action)
            .disabled(!enabled)
            .accessibilityLabel(icon == .chevronLeft ? "Previous month" : "Next month")
    }

    // MARK: Grid

    private func grid(for month: Date) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(theme.font(theme.typography.base * 0.8))
                        .foregroundStyle(theme.colors.mutedForeground)
                        .frame(width: ShadCalendarMetrics.cellSize)
                }
            }
            .frame(height: ShadCalendarMetrics.weekdayHeight)

            ForEach(Array(weeks(for: month).enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.timeIntervalSinceReferenceDate) { day in
                        dayCell(day, in: month)
                    }
                }
                .frame(height: ShadCalendarMetrics.cellSize)
                .padding(.top, ShadCalendarMetrics.weekGap)
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Date, in month: Date) -> some View {
        let cal = workingCalendar
        let isOutside = !cal.isDate(day, equalTo: month, toGranularity: .month)
        if isOutside && !showsOutsideDays {
            Color.clear.frame(width: ShadCalendarMetrics.cellSize, height: ShadCalendarMetrics.cellSize)
        } else {
            ShadCalendarDay(
                day: day,
                label: dayNumber(day),
                state: state(for: day, isOutside: isOutside),
                hoveredDay: $hoveredDay,
                isFocusable: !isOutside && cal.isDate(day, inSameDayAs: rovingFocusDay),
                calendar: cal,
                action: { select(day) },
                move: { moveFocus(by: $0, from: day) }
            )
        }
    }

    // MARK: Keyboard focus

    /// The one day that takes part in the tab order.
    ///
    /// A grid of 42 tab stops would be unusable, so the calendar keeps a single
    /// one — the selection, today, or the first of the month — and moves it
    /// with the arrow keys, which is how a date grid is expected to behave.
    private var rovingFocusDay: Date {
        let cal = workingCalendar
        let fallback = visibleMonths.first ?? displayedMonth
        let candidates = [focusedDay, Self.firstSelectedDate(in: selection), Date()]
        for candidate in candidates.compactMap({ $0 }) where isVisible(candidate) {
            return candidate
        }
        return cal.startOfMonth(fallback)
    }

    private func isVisible(_ day: Date) -> Bool {
        let cal = workingCalendar
        return visibleMonths.contains { cal.isDate(day, equalTo: $0, toGranularity: .month) }
    }

    /// Moves keyboard focus by `days`, paging the month when it walks off.
    private func moveFocus(by days: Int, from day: Date) {
        let cal = workingCalendar
        guard let target = cal.date(byAdding: .day, value: days, to: day) else { return }
        focusedDay = target
        guard !isVisible(target) else { return }
        let first = visibleMonths.first ?? displayedMonth
        setMonth(days < 0
            ? cal.date(byAdding: .month, value: -1, to: first) ?? first
            : cal.date(byAdding: .month, value: 1, to: first) ?? first)
    }

    // MARK: State

    private func state(for day: Date, isOutside: Bool) -> ShadCalendarDayState {
        let cal = workingCalendar
        let disabled = !isEnabled || (isDateDisabled?(day) ?? false) || isOutOfBounds(day)
        var state = ShadCalendarDayState(
            isOutside: isOutside,
            isToday: cal.isDateInToday(day),
            isDisabled: disabled
        )
        switch selection {
        case .none:
            break
        case .single(let binding):
            if let value = binding.wrappedValue, cal.isDate(value, inSameDayAs: day) {
                state.isSelected = true
            }
        case .multiple(let binding):
            if binding.wrappedValue.contains(where: { cal.isDate($0, inSameDayAs: day) }) {
                state.isSelected = true
            }
        case .range(let binding):
            guard let range = binding.wrappedValue else { break }
            let start = cal.startOfDay(for: range.from)
            let finish = cal.startOfDay(for: range.end)
            let target = cal.startOfDay(for: day)
            if target == start { state.isRangeStart = true }
            if range.isComplete, target == finish { state.isRangeEnd = true }
            if target > start, target < finish { state.isRangeMiddle = true }
        }
        return state
    }

    private func select(_ day: Date) {
        let cal = workingCalendar
        let normalised = cal.startOfDay(for: day)
        switch selection {
        case .none:
            break
        case .single(let binding):
            if let value = binding.wrappedValue, cal.isDate(value, inSameDayAs: normalised) {
                binding.wrappedValue = nil
            } else {
                binding.wrappedValue = normalised
            }
        case .multiple(let binding):
            if let index = binding.wrappedValue.firstIndex(where: { cal.isDate($0, inSameDayAs: normalised) }) {
                binding.wrappedValue.remove(at: index)
            } else {
                binding.wrappedValue.append(normalised)
                binding.wrappedValue.sort()
            }
        case .range(let binding):
            binding.wrappedValue = extend(binding.wrappedValue, with: normalised, in: cal)
        }
    }

    /// react-day-picker's `addToRange`: the second click closes the range, and
    /// clicking before the start turns the existing start into the end.
    private func extend(_ range: ShadDateRange?, with day: Date, in cal: Calendar) -> ShadDateRange {
        guard let range, !range.isComplete else {
            return ShadDateRange(from: day)
        }
        let start = cal.startOfDay(for: range.from)
        if day < start {
            return ShadDateRange(from: day, to: start)
        }
        if day == start {
            return ShadDateRange(from: day)
        }
        return ShadDateRange(from: start, to: day)
    }

    // MARK: Month arithmetic

    private var workingCalendar: Calendar {
        var working = baseCalendar
        working.timeZone = timeZone
        working.locale = locale
        return working
    }

    private var displayedMonth: Date {
        externalMonth?.wrappedValue ?? internalMonth
    }

    private func setMonth(_ month: Date) {
        let normalised = workingCalendar.startOfMonth(month)
        if let externalMonth {
            externalMonth.wrappedValue = normalised
        } else {
            internalMonth = normalised
        }
    }

    private var visibleMonths: [Date] {
        let cal = workingCalendar
        return (0..<numberOfMonths).compactMap {
            cal.date(byAdding: .month, value: $0, to: displayedMonth)
        }
    }

    private func step(_ delta: Int) {
        guard let next = workingCalendar.date(byAdding: .month, value: delta, to: displayedMonth) else { return }
        setMonth(next)
    }

    private var canGoBack: Bool {
        guard let bound = effectiveStartMonth else { return true }
        return workingCalendar.startOfMonth(displayedMonth) > workingCalendar.startOfMonth(bound)
    }

    private var canGoForward: Bool {
        guard let bound = effectiveEndMonth else { return true }
        let cal = workingCalendar
        // The last visible month is the one that must stay in bounds.
        let last = cal.date(byAdding: .month, value: numberOfMonths - 1, to: displayedMonth) ?? displayedMonth
        return cal.startOfMonth(last) < cal.startOfMonth(bound)
    }

    /// Dropdown captions need a year range; react-day-picker defaults to the
    /// hundred years up to the end of the current one.
    private var effectiveStartMonth: Date? {
        if let startMonth { return startMonth }
        guard captionLayout.isDropdown else { return nil }
        return workingCalendar.date(byAdding: .year, value: -100, to: Date())
    }

    private var effectiveEndMonth: Date? {
        if let endMonth { return endMonth }
        guard captionLayout.isDropdown else { return nil }
        return Date()
    }

    private func isOutOfBounds(_ day: Date) -> Bool {
        let cal = workingCalendar
        if let start = effectiveStartMonth, cal.startOfDay(for: day) < cal.startOfMonth(start) { return true }
        if let end = effectiveEndMonth,
           let endOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: cal.startOfMonth(end)),
           cal.startOfDay(for: day) > cal.startOfDay(for: endOfMonth) { return true }
        return false
    }

    private func monthRange(for month: Date) -> [Int] {
        let cal = workingCalendar
        let all = cal.range(of: .month, in: .year, for: month) ?? 1..<13
        return all.filter { value in
            guard let candidate = monthByReplacingRaw(month: value, in: month) else { return false }
            if let start = effectiveStartMonth, cal.startOfMonth(candidate) < cal.startOfMonth(start) { return false }
            if let end = effectiveEndMonth, cal.startOfMonth(candidate) > cal.startOfMonth(end) { return false }
            return true
        }
    }

    private func yearRange() -> [Int] {
        let cal = workingCalendar
        let first = effectiveStartMonth.map { cal.component(.year, from: $0) }
            ?? cal.component(.year, from: displayedMonth) - 100
        let last = effectiveEndMonth.map { cal.component(.year, from: $0) }
            ?? cal.component(.year, from: displayedMonth) + 10
        guard first <= last else { return [cal.component(.year, from: displayedMonth)] }
        return Array(first...last)
    }

    private func monthByReplacing(month value: Int, in date: Date) -> Date {
        monthByReplacingRaw(month: value, in: date) ?? date
    }

    private func monthByReplacingRaw(month value: Int, in date: Date) -> Date? {
        let cal = workingCalendar
        var components = cal.dateComponents([.year, .month, .day], from: date)
        components.month = value
        components.day = 1
        return cal.date(from: components)
    }

    private func monthByReplacing(year value: Int, in date: Date) -> Date {
        let cal = workingCalendar
        var components = cal.dateComponents([.year, .month, .day], from: date)
        components.year = value
        components.day = 1
        return cal.date(from: components) ?? date
    }

    private func weeks(for month: Date) -> [[Date]] {
        let cal = workingCalendar
        guard let monthInterval = cal.dateInterval(of: .month, for: month),
              let firstWeek = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var cursor = cal.startOfDay(for: firstWeek.start)
        var rows: [[Date]] = []
        while cursor < monthInterval.end, rows.count < 6 {
            var row: [Date] = []
            for _ in 0..<7 {
                row.append(cursor)
                cursor = cal.date(byAdding: .day, value: 1, to: cursor).map(cal.startOfDay(for:)) ?? cursor
            }
            rows.append(row)
        }
        return rows
    }

    // MARK: Formatting

    private var weekdaySymbols: [String] {
        let cal = workingCalendar
        let symbols = cal.shortWeekdaySymbols
        guard symbols.count == 7 else { return symbols }
        let first = cal.firstWeekday - 1
        return (0..<7).map { String(symbols[(first + $0) % 7].prefix(2)) }
    }

    private func formatter(_ template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = workingCalendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    private func captionTitle(_ month: Date) -> String { formatter("MMMM yyyy").string(from: month) }
    private func monthName(_ month: Date) -> String { formatter("MMM").string(from: month) }
    private func yearName(_ month: Date) -> String { formatter("yyyy").string(from: month) }

    private func dayNumber(_ day: Date) -> String {
        String(workingCalendar.component(.day, from: day))
    }

    private static func firstSelectedDate(in selection: Selection) -> Date? {
        switch selection {
        case .none: return nil
        case .single(let binding): return binding.wrappedValue
        case .multiple(let binding): return binding.wrappedValue.first
        case .range(let binding): return binding.wrappedValue?.from
        }
    }
}

// MARK: - Day

/// Everything the look of one day cell depends on.
struct ShadCalendarDayState {
    var isOutside = false
    var isToday = false
    var isDisabled = false
    var isSelected = false
    var isRangeStart = false
    var isRangeMiddle = false
    var isRangeEnd = false

    var isRangeEdge: Bool { isRangeStart || isRangeEnd }
    var isInRange: Bool { isRangeEdge || isRangeMiddle }
}

/// One day in the grid.
///
/// Hover lives in the parent so that moving between cells cannot leave two of
/// them lit at once.
struct ShadCalendarDay: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadStaticRendering) private var isStatic

    let day: Date
    let label: String
    let state: ShadCalendarDayState
    @Binding var hoveredDay: Date?
    let isFocusable: Bool
    let calendar: Calendar
    let action: () -> Void
    let move: (Int) -> Void

    @FocusState private var isFocused: Bool

    private var isHovering: Bool {
        guard let hoveredDay else { return false }
        return calendar.isDate(hoveredDay, inSameDayAs: day)
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(theme.font(theme.typography.sm))
                .foregroundStyle(foreground)
                .frame(width: ShadCalendarMetrics.cellSize, height: ShadCalendarMetrics.cellSize)
                .background(background)
                .opacity(state.isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.shadPlain)
        .disabled(state.isDisabled)
        .focusable(isFocusable && !state.isDisabled && !isStatic)
        .focused($isFocused)
        .focusEffectDisabled()
        .shadFocusRing(theme.radius.lg, isFocused: isFocused, keyboardOnly: true, theme: theme)
        .onKeyPress(.leftArrow) { move(-1); return .handled }
        .onKeyPress(.rightArrow) { move(1); return .handled }
        .onKeyPress(.upArrow) { move(-7); return .handled }
        .onKeyPress(.downArrow) { move(7); return .handled }
        .onKeyPress(.return) { action(); return .handled }
        .onHover { inside in
            guard !state.isDisabled else { return }
            if inside {
                hoveredDay = day
            } else if isHovering {
                hoveredDay = nil
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(state.isSelected || state.isRangeEdge ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            // The muted band that joins the two ends of a range.
            if state.isInRange {
                Rectangle().fill(theme.colors.muted)
            }
            if state.isRangeEdge {
                ShadRoundedRectangle(cornerRadius: theme.radius.md).fill(theme.colors.primary)
            } else if state.isSelected {
                ShadRoundedRectangle(cornerRadius: theme.radius.lg).fill(theme.colors.primary)
            } else if state.isToday, !state.isRangeMiddle {
                ShadRoundedRectangle(cornerRadius: theme.radius.md).fill(theme.colors.muted)
            } else if isHovering, !state.isRangeMiddle {
                ShadRoundedRectangle(cornerRadius: theme.radius.lg).fill(theme.colors.muted)
            }
        }
    }

    private var foreground: Color {
        if state.isSelected || state.isRangeEdge { return theme.colors.primaryForeground }
        if state.isRangeMiddle { return theme.colors.foreground }
        if state.isOutside || state.isDisabled { return theme.colors.mutedForeground }
        return theme.colors.foreground
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .full
        return formatter.string(from: day)
    }
}

// MARK: - Chrome

/// One of the two month arrows.
struct ShadCalendarNavButton: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    @FocusState private var isFocused: Bool

    let icon: ShadIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ShadIconView(icon, size: ShadCalendarMetrics.navIconSize)
                .foregroundStyle(theme.colors.foreground)
                .frame(width: ShadCalendarMetrics.cellSize, height: ShadCalendarMetrics.cellSize)
                .background(
                    ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                        .fill(isHovering && isEnabled ? theme.colors.muted : .clear)
                )
                .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.shadPlain)
        .focused($isFocused)
        .focusEffectDisabled()
        .shadFocusRing(theme.radius.lg, isFocused: isFocused, keyboardOnly: true, theme: theme)
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
    }
}

/// The month or year dropdown of a `captionLayout` calendar.
///
/// shadcn overlays a transparent `<select>` on the label; the macOS equivalent
/// is the library's own popover menu.
struct ShadCalendarDropdown<Value: Hashable>: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    let label: String
    let options: [ShadSelectOption<Value>]
    let value: Value
    let onSelect: (Value) -> Void

    @State private var isOpen = false
    @State private var isHovering = false
    @State private var highlighted: Value?

    var body: some View {
        Button {
            highlighted = value
            isOpen.toggle()
        } label: {
            HStack(spacing: 4) {
                Text(label)
                    .foregroundStyle(theme.colors.foreground)
                ShadIconView(.chevronDown, size: ShadCalendarMetrics.dropdownIconSize)
                    .foregroundStyle(theme.colors.mutedForeground)
            }
            .fixedSize()
            .padding(.horizontal, 4)
            .frame(height: 20)
            .background(
                ShadRoundedRectangle(cornerRadius: theme.radius.md)
                    .fill(isHovering && isEnabled ? theme.colors.muted : .clear)
            )
        }
        .buttonStyle(.shadPlain)
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .shadPopover(
            isPresented: $isOpen,
            configuration: ShadPopoverConfiguration(alignment: .bottomCenter, gap: 4, maxHeight: 280)
        ) {
            ShadPopoverSurface {
                ShadOptionList(
                    sections: [ShadSelectSection(nil, options: options)],
                    selection: value,
                    highlighted: $highlighted,
                    emptyMessage: "",
                    onSelect: { option in
                        onSelect(option.value)
                        isOpen = false
                    }
                )
                .frame(width: 96)
            }
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Calendar helpers

extension Calendar {
    /// The first instant of the month `date` falls in.
    func startOfMonth(_ date: Date) -> Date {
        dateInterval(of: .month, for: date)?.start ?? startOfDay(for: date)
    }
}
