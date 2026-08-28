import SwiftUI
import ShadSwift

// MARK: - Input

struct InputPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var query = ""
    @State private var invalid = "sh"
    @State private var file: URL?

    var body: some View {
        DemoPage(title: "Input", subtitle: "A text input component for forms and user data entry.") {
            DemoSection("Sizes") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadInput("Small", text: $email, size: .sm)
                    ShadInput("Default", text: $email)
                    ShadInput("Large", text: $email, size: .lg)
                }
                .frame(width: 320)
            }

            DemoSection("States") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadInput("Email", text: $email)
                    ShadInput("Password", text: $password, isSecure: true)
                    ShadInput("Disabled", text: .constant("")).disabled(true)
                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Username")
                        ShadInput("shadcn", text: $invalid, isInvalid: true)
                        ShadFieldError("Username must be at least 3 characters.")
                    }
                }
                .frame(width: 320)
            }

            DemoSection("With addons", description: "A leading icon, or any view in the leading/trailing slots.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadInput("Search components…", text: $query, icon: .search)
                    ShadInput("Amount", text: $query, leading: { Text("$") }, trailing: { Text("USD") })
                    ShadInput("you@example.com", text: $email, leading: { ShadIconView(.mail, size: 16) }, trailing: {
                        ShadSpinner(size: 14)
                    })
                }
                .frame(width: 340)
            }

            DemoSection("File input", description: "The type=\"file\" flavour, wired to NSOpenPanel.") {
                ShadFileInput(url: $file, prompt: "Choose file")
                    .frame(width: 340)
            }

            DemoSection("Field group", description: "Titles, helper text and an optional label, spaced the way shadcn spaces a form.") {
                ShadFieldGroup {
                    ShadField {
                        ShadFieldLabel("Username", isRequired: true)
                        ShadInput("shadcn", text: $email)
                        ShadFieldDescription("Choose a unique username for your account.")
                    }
                    ShadField {
                        ShadFieldLabel("Password", isRequired: true)
                        ShadInput("", text: $password, isSecure: true)
                        ShadFieldDescription("Must be at least 8 characters long.")
                    }
                    ShadField {
                        HStack {
                            ShadFieldLabel("Company")
                            Spacer()
                            ShadBadge("Optional", variant: .secondary)
                        }
                        ShadInput("Acme Inc.", text: $query)
                    }
                }
                .frame(width: 420)
            }

            DemoSection("In a grid") {
                HStack(spacing: 12) {
                    ShadField {
                        ShadFieldLabel("First name")
                        ShadInput("Evil", text: $email)
                    }
                    ShadField {
                        ShadFieldLabel("Last name")
                        ShadInput("Rabbit", text: $password)
                    }
                }
                .frame(width: 420)
            }
        }
    }
}

// MARK: - Textarea

struct TextareaPage: View {
    @State private var message = ""
    @State private var bio = "I build Mac apps."
    @State private var broken = ""

    var body: some View {
        DemoPage(title: "Textarea", subtitle: "Displays a form textarea or a component that looks like a textarea.") {
            DemoSection("Default") {
                ShadTextarea("Type your message here.", text: $message)
                    .frame(width: 420)
            }

            DemoSection("States") {
                VStack(alignment: .leading, spacing: 14) {
                    ShadTextarea("Disabled", text: .constant("")).disabled(true)
                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Bio")
                        ShadTextarea("Tell us a little bit about yourself", text: $broken, isInvalid: true)
                        ShadFieldError("Bio must be at least 10 characters.")
                    }
                }
                .frame(width: 420)
            }

            DemoSection("Resizable", description: "Drag the grip in the bottom-right corner.") {
                ShadTextarea("Drag the corner to make me taller.", text: $message, isResizable: true)
                    .frame(width: 420)
            }

            DemoSection("With a label, description and button") {
                ShadField {
                    ShadFieldLabel("Your message")
                    ShadTextarea("Type your message here.", text: $bio, minHeight: 110)
                    ShadFieldDescription("Your message will be copied to the support team.")
                    HStack {
                        Spacer()
                        ShadButton("Send message", size: .sm, icon: .send) {}
                    }
                }
                .frame(width: 420)
            }
        }
    }
}

// MARK: - Field

struct FieldPage: View {
    @State private var name = ""
    @State private var username = ""
    @State private var mfa = true
    @State private var plan: String? = "pro"
    @State private var newsletter = false
    @State private var cardName = ""
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var comments = ""
    @State private var month: String? = nil
    @State private var year: String? = nil
    @State private var sameAddress = true
    @State private var compute = "k8s"

    private var months: [ShadSelectOption<String>] {
        (1...12).map { ShadSelectOption(String(format: "%02d", $0), value: String(format: "%02d", $0)) }
    }

    private var years: [ShadSelectOption<String>] {
        (2026...2032).map { ShadSelectOption("\($0)", value: "\($0)") }
    }

    var body: some View {
        DemoPage(title: "Field", subtitle: "Accessible, composable form layouts: labels, descriptions, errors and groups.") {
            DemoSection("Payment method", description: "The first example from the shadcn Field page, field for field.") {
                ShadFieldGroup {
                    ShadFieldSet {
                        ShadFieldLegend("Payment Method")
                        ShadFieldDescription("All transactions are secure and encrypted")
                        ShadFieldGroup {
                            ShadField {
                                ShadFieldLabel("Name on Card")
                                ShadInput("Evil Rabbit", text: $cardName)
                            }
                            ShadField {
                                ShadFieldLabel("Card Number")
                                ShadInput("1234 5678 9012 3456", text: $cardNumber)
                                ShadFieldDescription("Enter your 16-digit card number")
                            }
                            HStack(alignment: .top, spacing: 16) {
                                ShadField {
                                    ShadFieldLabel("Month")
                                    ShadSelect(selection: $month, options: months, placeholder: "MM")
                                }
                                ShadField {
                                    ShadFieldLabel("Year")
                                    ShadSelect(selection: $year, options: years, placeholder: "YYYY")
                                }
                                ShadField {
                                    ShadFieldLabel("CVV")
                                    ShadInput("123", text: $cvv)
                                }
                            }
                        }
                    }

                    ShadFieldSeparator()

                    ShadFieldSet {
                        ShadFieldLegend("Billing Address")
                        ShadFieldDescription("The billing address associated with your payment method")
                        ShadFieldGroup(spacing: 12) {
                            ShadCheckbox("Same as shipping address", isOn: $sameAddress)
                        }
                    }

                    ShadFieldSet {
                        ShadFieldGroup {
                            ShadField {
                                ShadFieldLabel("Comments")
                                ShadTextarea("Add any additional comments", text: $comments)
                            }
                        }
                    }

                    ShadField(orientation: .horizontal) {
                        ShadButton("Submit") {}
                        ShadButton("Cancel", variant: .outline) {}
                    }
                }
                .frame(width: 460)
            }

            DemoSection("Horizontal", description: "orientation: .horizontal puts the control beside the copy.") {
                ShadField(orientation: .horizontal) {
                    ShadFieldContent {
                        ShadFieldTitle("Multi-factor authentication")
                        ShadFieldDescription("Adds an extra layer of security to your account.")
                    }
                    ShadSwitch(isOn: $mfa)
                }
                .frame(width: 460)
            }

            DemoSection("Responsive", description: "Horizontal when there is room, vertical when there is not. Resize the window.") {
                ShadField(orientation: .responsive) {
                    ShadFieldContent {
                        ShadFieldTitle("Newsletter")
                        ShadFieldDescription("Monthly notes about what shipped.")
                    }
                    ShadSwitch(isOn: $newsletter)
                }
            }

            DemoSection("Invalid", description: "isInvalid tints the label and reveals FieldError.") {
                ShadField(isInvalid: true) {
                    ShadFieldLabel("Username")
                    ShadInput("shadcn", text: $username, isInvalid: true)
                    ShadFieldError("Choose another username.")
                }
                .frame(width: 360)
            }

            DemoSection("Choice card", description: "A radio group where the whole card is the control.") {
                ShadFieldSet {
                    ShadFieldLegend("Compute Environment")
                    ShadFieldDescription("Select the compute environment for your cluster.")
                    ShadFieldGroup(spacing: 12) {
                        ShadChoiceCard(isSelected: compute == "k8s") { compute = "k8s" } content: {
                            ShadFieldContent {
                                ShadFieldTitle("Kubernetes")
                                ShadFieldDescription("Run GPU workloads on a K8s cluster.")
                            }
                            ShadRadioIndicator(isSelected: compute == "k8s")
                        }
                        ShadChoiceCard(isSelected: compute == "vm") { compute = "vm" } content: {
                            ShadFieldContent {
                                ShadFieldTitle("Virtual Machine")
                                ShadFieldDescription("Access a cluster to run GPU workloads.")
                            }
                            ShadRadioIndicator(isSelected: compute == "vm")
                        }
                    }
                }
                .frame(width: 460)
            }

            DemoSection("FieldSet, FieldLegend and FieldSeparator") {
                ShadFieldSet {
                    ShadFieldLegend("Profile")
                    ShadFieldDescription("Appears on invoices and emails.")
                    ShadFieldGroup(spacing: 16) {
                        ShadField {
                            ShadFieldLabel("Full name")
                            ShadInput("Evil Rabbit", text: $name)
                        }
                        ShadFieldSeparator("Billing")
                        ShadField {
                            ShadFieldLabel("Plan")
                            ShadSelect(selection: $plan, options: [
                                ShadSelectOption("Hobby", value: "hobby"),
                                ShadSelectOption("Pro", value: "pro"),
                                ShadSelectOption("Enterprise", value: "enterprise"),
                            ], placeholder: "Choose a plan")
                            ShadFieldDescription("You can change this at any time.")
                        }
                        ShadFieldSeparator()
                        ShadField(orientation: .horizontal) {
                            ShadFieldContent {
                                ShadFieldTitle("Disabled field")
                                ShadFieldDescription("Everything dims together.")
                            }
                            ShadSwitch(isOn: .constant(false))
                        }
                        .disabled(true)
                    }
                }
                .frame(width: 460)
            }
        }
    }
}

// MARK: - Form

struct FormPage: View {
    @EnvironmentObject private var toasts: ShadToastCenter
    @StateObject private var form = ShadFormModel(fields: [
        ShadFormField("username", value: .text(""), rules: [.required(), .minLength(2), .maxLength(20)]),
        ShadFormField("email", value: .text(""), rules: [.required(), .email()]),
        ShadFormField("bio", value: .text(""), rules: [.maxLength(160)]),
        ShadFormField("plan", value: .option(nil), rules: [.required("Pick a plan.")]),
        ShadFormField("marketing", value: .flag(false)),
        ShadFormField("terms", value: .flag(false), rules: [.mustAccept("You must accept the terms.")]),
    ])

    private let plans = [
        ShadSelectOption("Hobby — free", value: "hobby"),
        ShadSelectOption("Pro — $20/mo", value: "pro"),
        ShadSelectOption("Enterprise — talk to us", value: "enterprise"),
    ]

    var body: some View {
        DemoPage(title: "Form", subtitle: "Fields, validation rules and submission, wired through one observable model.") {
            DemoSection("Validated form", description: "Rules run as fields are touched, then again on submit.") {
                ShadForm(form) {
                    ShadFormRow("username") { field in
                        ShadFieldLabel("Username", isRequired: true)
                        ShadInput("shadcn", text: field.text, isInvalid: field.hasError)
                        ShadFieldDescription("This is your public display name.")
                    }

                    ShadFormRow("email") { field in
                        ShadFieldLabel("Email", isRequired: true)
                        ShadInput("m@example.com", text: field.text, icon: .mail, isInvalid: field.hasError)
                    }

                    ShadFormRow("plan") { field in
                        ShadFieldLabel("Plan", isRequired: true)
                        ShadSelect(
                            selection: field.option(String.self),
                            options: plans,
                            placeholder: "Select a plan",
                            isInvalid: field.hasError
                        )
                    }

                    ShadFormRow("bio") { field in
                        ShadFieldLabel("Bio")
                        ShadTextarea("Tell us a little bit about yourself", text: field.text, isInvalid: field.hasError)
                        ShadFieldDescription("Up to 160 characters.")
                    }

                    ShadFormRow("marketing", orientation: .horizontal) { field in
                        ShadFieldContent {
                            ShadFieldTitle("Marketing emails")
                            ShadFieldDescription("Receive product news and offers.")
                        }
                        ShadSwitch(isOn: field.flag)
                    }

                    ShadFormRow("terms") { field in
                        ShadCheckbox("I accept the terms and conditions", isOn: field.flag, isInvalid: field.hasError)
                    }

                    HStack(spacing: 8) {
                        ShadButton("Submit", isLoading: form.isSubmitting) {
                            form.submit { values in
                                await submit(values)
                            }
                        }
                        ShadButton("Reset", variant: .outline) { form.reset() }
                        Spacer()
                        if !form.isValid {
                            ShadBadge("\(form.errors.values.filter { !$0.isEmpty }.count) issues", variant: .destructive, icon: .circleAlert)
                        }
                    }
                }
                .frame(width: 460)
            }

            DemoSection("Live state", description: "The model exposes values, errors and touched fields.") {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(["username", "email", "plan", "terms"], id: \.self) { key in
                        HStack(spacing: 8) {
                            Text(key).frame(width: 90, alignment: .leading)
                            ShadBadge(describe(form.value(key)), variant: .outline)
                            if let error = form.error(key) {
                                ShadBadge(error, variant: .destructive)
                            }
                        }
                        .font(.system(size: 11, design: .monospaced))
                    }
                }
            }
        }
    }

    private func submit(_ values: [String: ShadFormValue]) async {
        try? await Task.sleep(nanoseconds: 900_000_000)
        toasts.success("Profile updated", description: "Signed up \(values["email"]?.stringValue ?? "") for the \(values["plan"]?.optionValue.map { "\($0.base)" } ?? "") plan.")
    }

    private func describe(_ value: ShadFormValue) -> String {
        switch value {
        case .text(let text): return text.isEmpty ? "\"\"" : "\"\(text)\""
        case .flag(let flag): return flag ? "true" : "false"
        case .number(let number): return String(format: "%.0f", number)
        case .option(let option): return option.map { "\($0.base)" } ?? "nil"
        case .options(let options): return "\(options.count) selected"
        }
    }
}

// MARK: - Calendar

struct CalendarPage: View {
    @State private var single: Date? = Date()
    @State private var multiple: [Date] = []
    @State private var range: ShadDateRange?
    @State private var dropdownDate: Date? = Date()
    @State private var weekdaysOnly: Date?
    @State private var zoned: Date? = Date()
    @State private var zoneID = "Asia/Tokyo"
    @State private var systemID = "gregorian"

    private var timeZone: TimeZone { TimeZone(identifier: zoneID) ?? .current }

    private var calendarSystem: Calendar {
        Calendar(identifier: Calendar.Identifier(shadIdentifier: systemID))
    }

    var body: some View {
        DemoPage(title: "Calendar", subtitle: "A date field component that allows users to enter and edit dates.") {
            DemoSection("Basic", description: "One day at a time. bordered: true matches shadcn's rounded-lg border example.") {
                DemoRow(spacing: 32) {
                    ShadCalendar(selection: $single, bordered: true)
                    VStack(alignment: .leading, spacing: 6) {
                        DemoCaption("selection")
                        Text(single.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "none")
                            .font(.system(size: 13, design: .monospaced))
                    }
                }
            }

            DemoSection("Range", description: "Two months side by side. The first click opens the range, the second closes it.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadCalendar(range: $range, numberOfMonths: 2, bordered: true)
                    DemoCaption(rangeSummary)
                }
            }

            DemoSection("Multiple", description: "Any number of days; clicking a selected day removes it.") {
                VStack(alignment: .leading, spacing: 12) {
                    ShadCalendar(selection: $multiple, bordered: true)
                    DemoCaption("\(multiple.count) selected")
                }
            }

            DemoSection("Month and year selector", description: "captionLayout: .dropdown turns the caption into two menus.") {
                DemoRow(spacing: 32) {
                    ShadCalendar(selection: $dropdownDate, captionLayout: .dropdown, bordered: true)
                    ShadCalendar(selection: $dropdownDate, captionLayout: .dropdownYears, bordered: true)
                }
            }

            DemoSection("Disabled dates", description: "isDateDisabled rules out days; weekends here.") {
                ShadCalendar(
                    selection: $weekdaysOnly,
                    bordered: true,
                    isDateDisabled: { date in
                        let weekday = Calendar.current.component(.weekday, from: date)
                        return weekday == 1 || weekday == 7
                    }
                )
            }

            DemoSection("Time zone", description: "The grid, today's highlight and the selection all follow the zone you give it.") {
                VStack(alignment: .leading, spacing: 12) {
                    DemoLabeled(label: "timeZone", width: 200) {
                        ShadSelect(selection: Binding(
                            get: { Optional(zoneID) }, set: { zoneID = $0 ?? "UTC" }
                        ), options: [
                            ShadSelectOption("Asia/Tokyo", value: "Asia/Tokyo"),
                            ShadSelectOption("Europe/Oslo", value: "Europe/Oslo"),
                            ShadSelectOption("America/New_York", value: "America/New_York"),
                            ShadSelectOption("UTC", value: "UTC"),
                        ])
                    }
                    ShadCalendar(selection: $zoned, bordered: true, timeZone: timeZone)
                }
            }

            DemoSection("Calendar systems", description: "Pass any Foundation Calendar — Persian, Hijri and the rest come for free.") {
                VStack(alignment: .leading, spacing: 12) {
                    DemoLabeled(label: "calendar", width: 200) {
                        ShadSelect(selection: Binding(
                            get: { Optional(systemID) }, set: { systemID = $0 ?? "gregorian" }
                        ), options: [
                            ShadSelectOption("gregorian", value: "gregorian"),
                            ShadSelectOption("persian", value: "persian"),
                            ShadSelectOption("islamicUmmAlQura", value: "islamicUmmAlQura"),
                            ShadSelectOption("hebrew", value: "hebrew"),
                            ShadSelectOption("japanese", value: "japanese"),
                        ])
                    }
                    ShadCalendar(selection: $single, bordered: true, calendar: calendarSystem)
                }
            }

            DemoSection("Without outside days", description: "showsOutsideDays: false leaves the neighbouring months blank.") {
                ShadCalendar(selection: $single, showsOutsideDays: false, bordered: true)
            }
        }
    }

    private var rangeSummary: String {
        guard let range else { return "no range" }
        let from = range.from.formatted(date: .abbreviated, time: .omitted)
        guard let to = range.to else { return "\(from) — pick the other end" }
        return "\(from) → \(to.formatted(date: .abbreviated, time: .omitted))"
    }
}

extension Calendar.Identifier {
    /// Maps the demo's picker values onto Foundation's calendar identifiers.
    init(shadIdentifier: String) {
        switch shadIdentifier {
        case "persian": self = .persian
        case "islamicUmmAlQura": self = .islamicUmmAlQura
        case "hebrew": self = .hebrew
        case "japanese": self = .japanese
        default: self = .gregorian
        }
    }
}

// MARK: - Date Picker

struct DatePickerPage: View {
    @State private var basic: Date?
    @State private var range: ShadDateRange?
    @State private var birthday: Date?
    @State private var subscription: Date? = Date()
    @State private var appointment: Date? = Date()
    @State private var futureOnly: Date?
    @State private var uses24Hour = false
    @State private var showsSeconds = true
    @State private var basicOpen = DemoLaunchOptions.opensMenu
    @State private var rangeOpen = DemoLaunchOptions.opensRangePicker

    private var hundredYears: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }

    var body: some View {
        DemoPage(title: "Date Picker", subtitle: "A date picker component with range and presets.") {
            DemoSection("Basic", description: "An outline trigger that opens a calendar.") {
                DemoRow(spacing: 32) {
                    ShadField {
                        ShadFieldLabel("Date")
                        ShadDatePicker(selection: $basic, placeholder: "Pick a date", isOpen: $basicOpen)
                    }
                    .frame(width: 176)
                    DemoCaption(basic.map { $0.formatted(date: .long, time: .omitted) } ?? "nothing picked")
                }
            }

            DemoSection("Trigger styles", description: "icon: .chevron, .calendar or .none.") {
                DemoRow(spacing: 16) {
                    ShadDatePicker(selection: $basic, icon: .chevron)
                    ShadDatePicker(selection: $basic, icon: .calendar)
                    ShadDatePicker(selection: $basic, icon: .none)
                }
            }

            DemoSection("Range picker", description: "Two months in the popover; the trigger shows both ends.") {
                ShadField {
                    ShadFieldLabel("Date Picker Range")
                    ShadDateRangePicker(range: $range, isOpen: $rangeOpen)
                }
                .frame(width: 240)
            }

            DemoSection("Date of birth", description: "captionLayout: .dropdown, bounded by startMonth and endMonth.") {
                ShadField {
                    ShadFieldLabel("Date of birth")
                    ShadDatePicker(
                        selection: $birthday,
                        icon: .none,
                        captionLayout: .dropdown,
                        startMonth: hundredYears,
                        endMonth: Date()
                    )
                }
                .frame(width: 176)
            }

            DemoSection("Input", description: "Type the date or pick it; the calendar follows what you type.") {
                DemoRow(spacing: 32) {
                    ShadField {
                        ShadFieldLabel("Subscription Date")
                        ShadDateInput(selection: $subscription)
                    }
                    .frame(width: 192)
                    DemoCaption(subscription.map { $0.formatted(date: .long, time: .omitted) } ?? "unparsed")
                }
            }

            DemoSection(
                "Date and time",
                description: "One Date, edited as a day and a clock time. Twelve-hour by default; the field reads either notation whichever clock it is set to."
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    ShadDateTimePicker(
                        selection: $appointment,
                        clock: uses24Hour ? .twentyFourHour : .twelveHour,
                        showsSeconds: showsSeconds
                    )
                    DemoRow(spacing: 20) {
                        ShadSwitch("24-hour clock", isOn: $uses24Hour)
                        ShadSwitch("Seconds", isOn: $showsSeconds)
                    }
                    DemoCaption(appointment.map { $0.formatted(date: .abbreviated, time: .standard) } ?? "nothing picked")
                }
            }

            DemoSection("Disabled dates", description: "Past days ruled out with isDateDisabled.") {
                ShadDatePicker(
                    selection: $futureOnly,
                    placeholder: "Pick a future date",
                    width: 208,
                    isDateDisabled: { $0 < Calendar.current.startOfDay(for: Date()) }
                )
            }
        }
    }
}
