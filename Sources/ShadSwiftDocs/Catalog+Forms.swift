import SwiftUI
import ShadSwift

@MainActor
extension DocCatalog {
    static var forms: [DocComponent] {
        [input, textarea, field, form, calendar, datePicker]
    }

    // MARK: - Input

    static var input: DocComponent {
        DocComponent(
            slug: "input",
            title: "Input",
            summary: "A text input for forms and user data entry.",
            group: "Forms",
            examples: [
                DocExample(
                    "Sizes",
                    description: "sm (32pt), default (36pt) and lg (40pt).",
                    width: 520,
                    code: #"""
                    ShadInput("Small", text: $text, size: .sm)
                    ShadInput("Default", text: $text)
                    ShadInput("Large", text: $text, size: .lg)
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadInput("Small", text: .constant(""), size: .sm)
                        ShadInput("Default", text: .constant(""))
                        ShadInput("Large", text: .constant(""), size: .lg)
                    }
                    .frame(width: 320)
                },

                DocExample(
                    "States",
                    description: "Secure entry, disabled, and the invalid state paired with a field error.",
                    width: 520,
                    code: #"""
                    ShadInput("Email", text: $email)
                    ShadInput("Password", text: $password, isSecure: true)
                    ShadInput("Disabled", text: $text).disabled(true)

                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Username")
                        ShadInput("shadcn", text: $username, isInvalid: true)
                        ShadFieldError("Username must be at least 3 characters.")
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadInput("Email", text: .constant(""))
                        ShadInput("Password", text: .constant("hunter2"), isSecure: true)
                        ShadInput("Disabled", text: .constant("")).disabled(true)
                        ShadField(isInvalid: true) {
                            ShadFieldLabel("Username")
                            ShadInput("shadcn", text: .constant("sh"), isInvalid: true)
                            ShadFieldError("Username must be at least 3 characters.")
                        }
                    }
                    .frame(width: 320)
                },

                DocExample(
                    "Addons",
                    description: "A leading icon, or arbitrary views in the leading and trailing slots — the input-group pattern.",
                    width: 540,
                    code: #"""
                    ShadInput("Search components…", text: $query, icon: .search)

                    ShadInput("Amount", text: $amount,
                              leading: { Text("$") },
                              trailing: { Text("USD") })

                    ShadInput("you@example.com", text: $email,
                              leading: { ShadIconView(.mail, size: 16) },
                              trailing: { ShadSpinner(size: 14) })
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ShadInput("Search components…", text: .constant(""), icon: .search)
                        ShadInput("Amount", text: .constant(""), leading: { Text("$") }, trailing: { Text("USD") })
                        ShadInput("you@example.com", text: .constant(""),
                                  leading: { ShadIconView(.mail, size: 16) },
                                  trailing: { ShadSpinner(size: 14) })
                    }
                    .frame(width: 340)
                },

                DocExample(
                    "Field group",
                    description: "Titles, helper text and an optional-label chip, spaced the way shadcn spaces a form.",
                    width: 560,
                    code: #"""
                    ShadFieldGroup {
                        ShadField {
                            ShadFieldLabel("Username", isRequired: true)
                            ShadInput("shadcn", text: $username)
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
                            ShadInput("Acme Inc.", text: $company)
                        }
                    }
                    """#
                ) {
                    ShadFieldGroup {
                        ShadField {
                            ShadFieldLabel("Username", isRequired: true)
                            ShadInput("shadcn", text: .constant(""))
                            ShadFieldDescription("Choose a unique username for your account.")
                        }
                        ShadField {
                            ShadFieldLabel("Password", isRequired: true)
                            ShadInput("", text: .constant("hunter2"), isSecure: true)
                            ShadFieldDescription("Must be at least 8 characters long.")
                        }
                        ShadField {
                            HStack {
                                ShadFieldLabel("Company")
                                Spacer()
                                ShadBadge("Optional", variant: .secondary)
                            }
                            ShadInput("Acme Inc.", text: .constant(""))
                        }
                    }
                    .frame(width: 420)
                },

                DocExample(
                    "File input",
                    description: "shadcn's type=\"file\" variant, wired to NSOpenPanel.",
                    width: 520,
                    code: #"""
                    @State private var file: URL?

                    ShadFileInput(url: $file,
                                  prompt: "Choose file",
                                  allowedExtensions: ["png", "jpg"])
                    """#
                ) {
                    ShadFileInput(url: .constant(nil), prompt: "Choose file")
                        .frame(width: 340)
                },
            ],
            notes: [
                "Inputs are 32pt tall with a 10pt radius and no shadow — measured from shadcn, where the shadow resolves to nothing.",
                "An invalid input keeps its 3pt destructive halo whether or not it has focus.",
            ],
            api: [
                DocAPI("ShadInput", [
                    DocProperty("placeholder", "String", default: "\"\"", "Prompt shown when empty."),
                    DocProperty("text", "Binding<String>", "The value."),
                    DocProperty("isSecure", "Bool", default: "false", "Renders a SecureField."),
                    DocProperty("size", "ShadInputSize", default: ".default", "sm, default or lg."),
                    DocProperty("isInvalid", "Bool", default: "false", "Destructive border and ring."),
                    DocProperty("icon", "ShadIcon", "Convenience for a leading icon."),
                    DocProperty("leading / trailing", "() -> View", "Arbitrary addon slots."),
                    DocProperty("onSubmit", "(() -> Void)?", default: "nil", "Called on Return."),
                ]),
            ]
        )
    }

    // MARK: - Textarea

    static var textarea: DocComponent {
        DocComponent(
            slug: "textarea",
            title: "Textarea",
            summary: "Displays a form textarea, or a component that looks like a textarea.",
            group: "Forms",
            examples: [
                DocExample(
                    "Default",
                    width: 560,
                    code: #"""
                    ShadTextarea("Type your message here.", text: $message)
                    """#
                ) {
                    ShadTextarea("Type your message here.", text: .constant(""))
                        .frame(width: 420)
                },

                DocExample(
                    "States",
                    width: 560,
                    code: #"""
                    ShadTextarea("Disabled", text: $text).disabled(true)

                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Bio")
                        ShadTextarea("Tell us about yourself", text: $bio, isInvalid: true)
                        ShadFieldError("Bio must be at least 10 characters.")
                    }
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        ShadTextarea("Disabled", text: .constant("")).disabled(true)
                        ShadField(isInvalid: true) {
                            ShadFieldLabel("Bio")
                            ShadTextarea("Tell us a little bit about yourself", text: .constant(""), isInvalid: true)
                            ShadFieldError("Bio must be at least 10 characters.")
                        }
                    }
                    .frame(width: 420)
                },

                DocExample(
                    "Resizable",
                    description: "Pass isResizable and a grip appears in the bottom-right corner.",
                    width: 560,
                    code: #"""
                    ShadTextarea("Drag the corner to make me taller.",
                                 text: $message, isResizable: true)
                    """#
                ) {
                    ShadTextarea("Drag the corner to make me taller.", text: .constant(""), isResizable: true)
                        .frame(width: 420)
                },

                DocExample(
                    "With a label and a button",
                    width: 560,
                    code: #"""
                    ShadField {
                        ShadFieldLabel("Your message")
                        ShadTextarea("Type your message here.", text: $message, minHeight: 110)
                        ShadFieldDescription("Your message will be copied to the support team.")
                        HStack {
                            Spacer()
                            ShadButton("Send message", size: .sm, icon: .send) {}
                        }
                    }
                    """#
                ) {
                    ShadField {
                        ShadFieldLabel("Your message")
                        ShadTextarea("Type your message here.", text: .constant("I build Mac apps."), minHeight: 110)
                        ShadFieldDescription("Your message will be copied to the support team.")
                        HStack {
                            Spacer()
                            ShadButton("Send message", size: .sm, icon: .send) {}
                        }
                    }
                    .frame(width: 420)
                },
            ],
            notes: [
                "Like Input, a textarea carries no shadow.",
            ],
            api: [
                DocAPI("ShadTextarea", [
                    DocProperty("isResizable", "Bool", default: "false", "Adds a drag grip in the bottom-right corner."),
                    DocProperty("placeholder", "String", default: "\"\"", "Prompt shown when empty."),
                    DocProperty("text", "Binding<String>", "The value."),
                    DocProperty("minHeight", "CGFloat", default: "64", "Matches shadcn's min-h-16."),
                    DocProperty("maxHeight", "CGFloat?", default: "nil", "Caps the height; content then scrolls."),
                    DocProperty("isInvalid", "Bool", default: "false", "Destructive border and ring."),
                ]),
            ]
        )
    }

    // MARK: - Field

    static var field: DocComponent {
        DocComponent(
            slug: "field",
            title: "Field",
            summary: "Accessible, composable form layouts: labels, descriptions, errors, groups and sets.",
            group: "Forms",
            anatomy: #"""
            ShadFieldSet
            ├── ShadFieldLegend
            ├── ShadFieldDescription
            └── ShadFieldGroup
                ├── ShadField
                │   ├── ShadFieldLabel
                │   ├── <control>
                │   ├── ShadFieldDescription
                │   └── ShadFieldError
                ├── ShadFieldSeparator
                └── ShadField(orientation: .horizontal)
                    ├── ShadFieldContent
                    │   ├── ShadFieldTitle
                    │   └── ShadFieldDescription
                    └── <control>
            """#,
            examples: [
                DocExample(
                    "Payment method",
                    description: "The first example on the shadcn Field page, field for field.",
                    width: 560,
                    code: #"""
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
                                    ShadField { ShadFieldLabel("Month"); ShadSelect(…) }
                                    ShadField { ShadFieldLabel("Year");  ShadSelect(…) }
                                    ShadField { ShadFieldLabel("CVV");   ShadInput("123", text: $cvv) }
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
                        ShadField(orientation: .horizontal) {
                            ShadButton("Submit") {}
                            ShadButton("Cancel", variant: .outline) {}
                        }
                    }
                    """#
                ) {
                    DocPaymentMethod()
                },

                DocExample(
                    "Choice card",
                    description: "A radio group where the whole card is the control.",
                    width: 560,
                    code: #"""
                    ShadChoiceCard(isSelected: compute == .k8s) { compute = .k8s } content: {
                        ShadFieldContent {
                            ShadFieldTitle("Kubernetes")
                            ShadFieldDescription("Run GPU workloads on a K8s cluster.")
                        }
                        ShadRadioIndicator(isSelected: compute == .k8s)
                    }
                    """#
                ) {
                    ShadFieldSet {
                        ShadFieldLegend("Compute Environment")
                        ShadFieldDescription("Select the compute environment for your cluster.")
                        ShadFieldGroup(spacing: 12) {
                            ShadChoiceCard(isSelected: true) {} content: {
                                ShadFieldContent {
                                    ShadFieldTitle("Kubernetes")
                                    ShadFieldDescription("Run GPU workloads on a K8s cluster.")
                                }
                                ShadRadioIndicator(isSelected: true)
                            }
                            ShadChoiceCard(isSelected: false) {} content: {
                                ShadFieldContent {
                                    ShadFieldTitle("Virtual Machine")
                                    ShadFieldDescription("Access a cluster to run GPU workloads.")
                                }
                                ShadRadioIndicator(isSelected: false)
                            }
                        }
                    }
                    .frame(width: 440)
                },

                DocExample(
                    "Vertical",
                    description: "The default: label, control, then helper text.",
                    width: 520,
                    code: #"""
                    ShadField {
                        ShadFieldLabel("Full name", isRequired: true)
                        ShadInput("Evil Rabbit", text: $name)
                        ShadFieldDescription("Shown on invoices and emails.")
                    }
                    """#
                ) {
                    ShadField {
                        ShadFieldLabel("Full name", isRequired: true)
                        ShadInput("Evil Rabbit", text: .constant(""))
                        ShadFieldDescription("Shown on invoices and emails.")
                    }
                    .frame(width: 360)
                },

                DocExample(
                    "Horizontal",
                    description: "ShadFieldContent groups the copy so the control can sit beside it.",
                    width: 620,
                    code: #"""
                    ShadField(orientation: .horizontal) {
                        ShadFieldContent {
                            ShadFieldTitle("Multi-factor authentication")
                            ShadFieldDescription("Adds an extra layer of security.")
                        }
                        ShadSwitch(isOn: $mfa)
                    }
                    """#
                ) {
                    ShadField(orientation: .horizontal) {
                        ShadFieldContent {
                            ShadFieldTitle("Multi-factor authentication")
                            ShadFieldDescription("Adds an extra layer of security to your account.")
                        }
                        ShadSwitch(isOn: .constant(true))
                    }
                    .frame(width: 460)
                },

                DocExample(
                    "Invalid",
                    description: "isInvalid tints the label and reveals ShadFieldError.",
                    width: 520,
                    code: #"""
                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Username")
                        ShadInput("shadcn", text: $username, isInvalid: true)
                        ShadFieldError("Choose another username.")
                    }
                    """#
                ) {
                    ShadField(isInvalid: true) {
                        ShadFieldLabel("Username")
                        ShadInput("shadcn", text: .constant(""), isInvalid: true)
                        ShadFieldError("Choose another username.")
                    }
                    .frame(width: 360)
                },

                DocExample(
                    "FieldSet, legend and separator",
                    description: "A complete form section. Disabling the field dims the label, the control and the description together.",
                    width: 620,
                    code: #"""
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
                                ShadSelect(selection: $plan, options: plans,
                                           placeholder: "Choose a plan")
                                ShadFieldDescription("You can change this at any time.")
                            }
                        }
                    }
                    """#
                ) {
                    ShadFieldSet {
                        ShadFieldLegend("Profile")
                        ShadFieldDescription("Appears on invoices and emails.")
                        ShadFieldGroup(spacing: 16) {
                            ShadField {
                                ShadFieldLabel("Full name")
                                ShadInput("Evil Rabbit", text: .constant(""))
                            }
                            ShadFieldSeparator("Billing")
                            ShadField {
                                ShadFieldLabel("Plan")
                                ShadSelect(selection: .constant("pro"), options: [
                                    ShadSelectOption("Hobby", value: "hobby"),
                                    ShadSelectOption("Pro", value: "pro"),
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
                },
            ],
            notes: [
                "orientation: .responsive uses ViewThatFits — horizontal above 440pt of available width, vertical below it.",
            ],
            api: [
                DocAPI("ShadField", [
                    DocProperty("orientation", "ShadFieldOrientation", default: ".vertical", "vertical, horizontal or responsive."),
                    DocProperty("isInvalid", "Bool", default: "false", "Propagates to labels and errors below."),
                    DocProperty("spacing", "CGFloat?", default: "nil", "Overrides the default gap."),
                ]),
                DocAPI("ShadFieldLegend", [
                    DocProperty("variant", "Variant", default: ".legend", "legend (section heading) or label."),
                ]),
                DocAPI("ShadFieldError", [
                    DocProperty("message", "String?", "Renders nothing when nil."),
                    DocProperty("messages", "[String]", "Renders one row per message."),
                ]),
            ]
        )
    }

    // MARK: - Form

    static var form: DocComponent {
        DocComponent(
            slug: "form",
            title: "Form",
            summary: "Fields, validation rules and submission, wired through one observable model.",
            group: "Forms",
            examples: [
                DocExample(
                    "Declaring the model",
                    description: "Each field carries a name, a starting value and its rules.",
                    code: #"""
                    @StateObject private var form = ShadFormModel(fields: [
                        ShadFormField("username", value: .text(""),
                                      rules: [.required(), .minLength(2), .maxLength(20)]),
                        ShadFormField("email", value: .text(""),
                                      rules: [.required(), .email()]),
                        ShadFormField("plan", value: .option(nil),
                                      rules: [.required("Pick a plan.")]),
                        ShadFormField("terms", value: .flag(false),
                                      rules: [.mustAccept("You must accept the terms.")]),
                    ])
                    """#
                ),

                DocExample(
                    "Validated form",
                    description: "ShadFormRow binds a named field and appends its error automatically.",
                    width: 640,
                    code: #"""
                    ShadForm(form) {
                        ShadFormRow("username") { field in
                            ShadFieldLabel("Username", isRequired: true)
                            ShadInput("shadcn", text: field.text, isInvalid: field.hasError)
                            ShadFieldDescription("This is your public display name.")
                        }

                        ShadFormRow("email") { field in
                            ShadFieldLabel("Email", isRequired: true)
                            ShadInput("m@example.com", text: field.text,
                                      icon: .mail, isInvalid: field.hasError)
                        }

                        ShadFormRow("plan") { field in
                            ShadFieldLabel("Plan", isRequired: true)
                            ShadSelect(selection: field.option(String.self),
                                       options: plans,
                                       placeholder: "Select a plan",
                                       isInvalid: field.hasError)
                        }

                        ShadFormRow("terms") { field in
                            ShadCheckbox("I accept the terms and conditions",
                                         isOn: field.flag, isInvalid: field.hasError)
                        }

                        ShadButton("Submit", isLoading: form.isSubmitting) {
                            form.submit { values in
                                await save(values)
                            }
                        }
                    }
                    """#
                ) {
                    DocFormPreview()
                },

                DocExample(
                    "Validation rules",
                    description: "Built-in rules, plus .custom for anything else.",
                    code: #"""
                    .required("This field is required.")
                    .minLength(2)
                    .maxLength(160)
                    .email()
                    .mustAccept("You must accept to continue.")
                    .matches("password", in: form)
                    .custom { value in
                        value.stringValue.hasPrefix("@") ? nil : "Handles start with @."
                    }
                    """#
                ),
            ],
            api: [
                DocAPI("ShadFormModel", [
                    DocProperty("init(fields:validationMode:)", "ShadFormModel", "onSubmit, onChange or onTouched (the default)."),
                    DocProperty("text / flag / number", "Binding<…>", "Bindings for a named field."),
                    DocProperty("option(_:) / options(_:)", "Binding<…>", "Bindings for single and multi selections."),
                    DocProperty("validate()", "Bool", "Runs every rule."),
                    DocProperty("submit(_:)", "Void", "Validates, then calls the handler. An async overload flips isSubmitting."),
                    DocProperty("reset()", "Void", "Restores the initial values."),
                    DocProperty("setError(_:_:)", "Void", "Injects a server-side error."),
                ]),
                DocAPI("ShadFormFieldProxy", summary: "What ShadFormRow hands to its content closure.", [
                    DocProperty("text / flag / number", "Binding<…>", "Bindings for this field."),
                    DocProperty("error / errors", "String? / [String]", "Current messages."),
                    DocProperty("hasError", "Bool", "Convenience for isInvalid arguments."),
                ]),
            ]
        )
    }
}

/// A pre-filled form used only for the documentation snapshot.
@MainActor
private struct DocFormPreview: View {
    @StateObject private var form = ShadFormModel(fields: [
        ShadFormField("username", value: .text("sh"), rules: [.required(), .minLength(3)]),
        ShadFormField("email", value: .text("m@example.com"), rules: [.required(), .email()]),
        ShadFormField("plan", value: .option("pro"), rules: [.required()]),
        ShadFormField("terms", value: .flag(false), rules: [.mustAccept("You must accept the terms.")]),
    ])

    var body: some View {
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
                    options: [
                        ShadSelectOption("Hobby — free", value: "hobby"),
                        ShadSelectOption("Pro — $20/mo", value: "pro"),
                    ],
                    placeholder: "Select a plan",
                    isInvalid: field.hasError
                )
            }
            ShadFormRow("terms") { field in
                ShadCheckbox("I accept the terms and conditions", isOn: field.flag, isInvalid: field.hasError)
            }
            HStack(spacing: 8) {
                ShadButton("Submit") {}
                ShadButton("Reset", variant: .outline) {}
            }
        }
        .frame(width: 460)
        .onAppear {
            // Show the validated state in the snapshot.
            form.submit { (_: [String: ShadFormValue]) in }
        }
    }
}


/// The Payment Method example, kept out of the catalogue literal so it can own
/// the handful of bindings it needs.
@MainActor
private struct DocPaymentMethod: View {
    var body: some View {
        ShadFieldGroup {
            ShadFieldSet {
                ShadFieldLegend("Payment Method")
                ShadFieldDescription("All transactions are secure and encrypted")
                ShadFieldGroup {
                    ShadField {
                        ShadFieldLabel("Name on Card")
                        ShadInput("Evil Rabbit", text: .constant(""))
                    }
                    ShadField {
                        ShadFieldLabel("Card Number")
                        ShadInput("1234 5678 9012 3456", text: .constant(""))
                        ShadFieldDescription("Enter your 16-digit card number")
                    }
                    HStack(alignment: .top, spacing: 16) {
                        ShadField {
                            ShadFieldLabel("Month")
                            ShadSelect(selection: .constant(nil), options: [ShadSelectOption("01", value: "01")], placeholder: "MM")
                        }
                        ShadField {
                            ShadFieldLabel("Year")
                            ShadSelect(selection: .constant(nil), options: [ShadSelectOption("2026", value: "2026")], placeholder: "YYYY")
                        }
                        ShadField {
                            ShadFieldLabel("CVV")
                            ShadInput("123", text: .constant(""))
                        }
                    }
                }
            }

            ShadFieldSeparator()

            ShadFieldSet {
                ShadFieldLegend("Billing Address")
                ShadFieldDescription("The billing address associated with your payment method")
                ShadFieldGroup(spacing: 12) {
                    ShadCheckbox("Same as shipping address", isOn: .constant(true))
                }
            }

            ShadField(orientation: .horizontal) {
                ShadButton("Submit") {}
                ShadButton("Cancel", variant: .outline) {}
            }
        }
        .frame(width: 440)
    }
}

// MARK: - Calendar

/// A fixed month so the documentation snapshots never drift with the clock.
@MainActor
enum DocCalendarDates {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()

    static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    static let month = day(2026, 6, 1)
    static let selected = day(2026, 6, 12)
    static let rangeStart = day(2026, 6, 8)
    static let rangeEnd = day(2026, 6, 19)
}

@MainActor
extension DocCatalog {
    static var calendar: DocComponent {
        DocComponent(
            slug: "calendar",
            title: "Calendar",
            summary: "A month grid for picking a day, a set of days or a range.",
            group: "Forms",
            anatomy: #"""
            ShadCalendar(selection:)          // one day        — Binding<Date?>
            ShadCalendar(selection:)          // several days   — Binding<[Date]>
            ShadCalendar(range:)              // a span of days — Binding<ShadDateRange?>
            ShadCalendar()                    // display only

              ├── caption          ShadCalendarCaptionLayout — a label or dropdowns
              ├── navigation       one pair of arrows, however many months are shown
              └── month grid       28pt cells, outside days, today, disabled days
            """#,
            examples: [
                DocExample(
                    "Basic",
                    description: "One day at a time. `bordered: true` is shadcn's `rounded-lg border` example.",
                    width: 480,
                    code: #"""
                    @State private var date: Date? = Date()

                    ShadCalendar(selection: $date, bordered: true)
                    """#
                ) {
                    DocCalendarPreview(selected: DocCalendarDates.selected)
                },

                DocExample(
                    "Range",
                    description: "The first click opens the range and the second closes it; the days between join into a band.",
                    width: 720,
                    code: #"""
                    @State private var stay: ShadDateRange?

                    ShadCalendar(range: $stay, numberOfMonths: 2, bordered: true)
                    """#
                ) {
                    DocCalendarPreview(
                        range: ShadDateRange(from: DocCalendarDates.rangeStart, to: DocCalendarDates.rangeEnd),
                        numberOfMonths: 2
                    )
                },

                DocExample(
                    "Month and year selector",
                    description: "`captionLayout: .dropdown` turns the caption into two menus, bounded by startMonth and endMonth.",
                    width: 480,
                    code: #"""
                    ShadCalendar(
                        selection: $birthday,
                        captionLayout: .dropdown,
                        bordered: true,
                        startMonth: Calendar.current.date(byAdding: .year, value: -100, to: Date()),
                        endMonth: Date()
                    )

                    // .dropdownMonths and .dropdownYears turn only one of the two
                    // into a menu.
                    """#
                ) {
                    DocCalendarPreview(selected: DocCalendarDates.selected, captionLayout: .dropdown)
                },

                DocExample(
                    "Disabled days",
                    description: "`isDateDisabled` rules days out — weekends here. They stay visible, struck back to half opacity.",
                    width: 480,
                    code: #"""
                    ShadCalendar(selection: $date, bordered: true) { date in
                        let weekday = Calendar.current.component(.weekday, from: date)
                        return weekday == 1 || weekday == 7
                    }
                    """#
                ) {
                    DocCalendarPreview(
                        selected: DocCalendarDates.selected,
                        isDateDisabled: { date in
                            let weekday = DocCalendarDates.calendar.component(.weekday, from: date)
                            return weekday == 1 || weekday == 7
                        }
                    )
                },

                DocExample(
                    "Outside days",
                    description: "`showsOutsideDays: false` leaves the neighbouring months blank instead of greying them in.",
                    width: 720,
                    code: #"""
                    ShadCalendar(selection: $date, showsOutsideDays: false, bordered: true)
                    """#
                ) {
                    HStack(spacing: 24) {
                        DocCalendarPreview(selected: DocCalendarDates.selected)
                        DocCalendarPreview(selected: DocCalendarDates.selected, showsOutsideDays: false)
                    }
                },

                DocExample(
                    "Calendar systems and time zones",
                    description: "The grid follows the Calendar, Locale and TimeZone it is given, so Persian, Hijri and the rest need nothing else.",
                    width: 720,
                    code: #"""
                    ShadCalendar(
                        selection: $date,
                        bordered: true,
                        calendar: Calendar(identifier: .persian),
                        locale: Locale(identifier: "fa_IR")
                    )

                    // Dates are read and written in the zone you name, so a day
                    // means the same thing to the reader as it does to the server.
                    ShadCalendar(selection: $date, timeZone: TimeZone(identifier: "Asia/Tokyo")!)
                    """#
                ) {
                    HStack(spacing: 24) {
                        DocCalendarPreview(
                            selected: DocCalendarDates.selected,
                            calendar: Calendar(identifier: .persian)
                        )
                        DocCalendarPreview(
                            selected: DocCalendarDates.selected,
                            calendar: Calendar(identifier: .islamicUmmAlQura)
                        )
                    }
                },
            ],
            notes: [
                "The cell is 28pt on a 28pt grid, matching shadcn's `--cell-size: --spacing(7)`; a range's ends are `--cell-radius` pills over a muted band.",
                "Today is a muted square, the selection a solid primary one — so a selected today reads as selected, not as today.",
                "One pair of arrows serves however many months are on screen, sitting at the outer edges as shadcn's absolutely-positioned nav does.",
                "The grid takes a single tab stop. Arrow keys move within it and page the month at the edges, rather than making 42 tab stops.",
                "shadcn's week numbers, custom cell sizes, booked-day modifiers and RTL are not implemented.",
            ],
            api: [
                DocAPI(
                    "ShadCalendar",
                    [
                        DocProperty("selection", "Binding<Date?>", "one day, or Binding<[Date]> for several"),
                        DocProperty("range", "Binding<ShadDateRange?>", "a span of days"),
                        DocProperty("numberOfMonths", "Int", default: "1", "how many months to show at once"),
                        DocProperty("month", "Binding<Date>?", default: "nil", "drive the visible month from outside"),
                        DocProperty("defaultMonth", "Date?", default: "nil", "the month to open on"),
                        DocProperty("captionLayout", "ShadCalendarCaptionLayout", default: ".label", "label, dropdown, dropdownMonths or dropdownYears"),
                        DocProperty("showsOutsideDays", "Bool", default: "true", "grey in the neighbouring months"),
                        DocProperty("bordered", "Bool", default: "false", "draw the background and border"),
                        DocProperty("axis", "Axis", default: ".horizontal", "how multiple months stack"),
                        DocProperty("startMonth", "Date?", default: "nil", "earliest month reachable"),
                        DocProperty("endMonth", "Date?", default: "nil", "latest month reachable"),
                        DocProperty("calendar", "Calendar", default: ".current", "any Foundation calendar system"),
                        DocProperty("locale", "Locale", default: ".current", "names the months and weekdays"),
                        DocProperty("timeZone", "TimeZone", default: ".current", "the zone days are measured in"),
                        DocProperty("isDateDisabled", "((Date) -> Bool)?", default: "nil", "rules individual days out"),
                    ]
                ),
                DocAPI(
                    "ShadDateRange",
                    summary: "`to` is nil between the two clicks that make a range.",
                    [
                        DocProperty("from", "Date", "the first day"),
                        DocProperty("to", "Date?", default: "nil", "the last day, once picked"),
                        DocProperty("isComplete", "Bool", "whether both ends are set"),
                        DocProperty("end", "Date", "the later end, falling back to from"),
                        DocProperty("contains(_:in:)", "(Date, Calendar) -> Bool", "whether a day is inside, ends included"),
                    ]
                ),
            ]
        )
    }

    // MARK: - Date Picker

    static var datePicker: DocComponent {
        DocComponent(
            slug: "date-picker",
            title: "Date Picker",
            summary: "A trigger that opens a calendar — as a button, a text field, or a date and a time together.",
            group: "Forms",
            anatomy: #"""
            ShadDatePicker(selection:)        // button  -> calendar
            ShadDateRangePicker(range:)       // button  -> two-month range calendar
            ShadDateInput(selection:)         // typing  + calendar button
            ShadDateTimePicker(selection:)    // a day and a clock time, one Date
            """#,
            examples: [
                DocExample(
                    "Basic",
                    description: "An outline trigger, 32pt tall like every other control, opening a calendar below.",
                    width: 560,
                    code: #"""
                    @State private var date: Date?

                    ShadField {
                        ShadFieldLabel("Date")
                        ShadDatePicker(selection: $date, placeholder: "Pick a date")
                    }
                    .frame(width: 176)
                    """#
                ) {
                    HStack(alignment: .top, spacing: 24) {
                        ShadField {
                            ShadFieldLabel("Date")
                            DocDatePickerPreview(date: nil, placeholder: "Pick a date")
                        }
                        .frame(width: 176)
                        ShadField {
                            ShadFieldLabel("Date")
                            DocDatePickerPreview(date: DocCalendarDates.selected)
                        }
                        .frame(width: 176)
                    }
                },

                DocExample(
                    "Trigger styles",
                    description: "`icon:` picks the affordance — a trailing chevron, a leading calendar, or neither.",
                    width: 720,
                    code: #"""
                    ShadDatePicker(selection: $date, icon: .chevron)     // default
                    ShadDatePicker(selection: $date, icon: .calendar)
                    ShadDatePicker(selection: $date, icon: .none)
                    """#
                ) {
                    HStack(spacing: 16) {
                        DocDatePickerPreview(date: DocCalendarDates.selected, icon: .chevron)
                        DocDatePickerPreview(date: DocCalendarDates.selected, icon: .calendar)
                        DocDatePickerPreview(date: DocCalendarDates.selected, icon: .none)
                    }
                },

                DocExample(
                    "Range picker",
                    description: "The trigger shows both ends; the panel holds two months.",
                    width: 560,
                    code: #"""
                    @State private var stay: ShadDateRange?

                    ShadField {
                        ShadFieldLabel("Date Picker Range")
                        ShadDateRangePicker(range: $stay)
                    }
                    .frame(width: 240)
                    """#
                ) {
                    ShadField {
                        ShadFieldLabel("Date Picker Range")
                        DocDateRangePickerPreview(
                            range: ShadDateRange(from: DocCalendarDates.rangeStart, to: DocCalendarDates.rangeEnd)
                        )
                    }
                    .frame(width: 240)
                },

                DocExample(
                    "Date of birth",
                    description: "Dropdown captions plus a bounded range: a hundred years is two clicks away, not twelve hundred.",
                    width: 560,
                    code: #"""
                    ShadDatePicker(
                        selection: $birthday,
                        icon: .none,
                        captionLayout: .dropdown,
                        startMonth: Calendar.current.date(byAdding: .year, value: -100, to: Date()),
                        endMonth: Date()
                    )
                    """#
                ) {
                    ShadField {
                        ShadFieldLabel("Date of birth")
                        DocDatePickerPreview(date: nil, placeholder: "Select date", icon: .none)
                    }
                    .frame(width: 176)
                },

                DocExample(
                    "Input",
                    description: "Type the date or pick it. Whatever parses wins, and the calendar follows the text.",
                    width: 560,
                    code: #"""
                    @State private var date: Date? = Date()

                    ShadField {
                        ShadFieldLabel("Subscription Date")
                        ShadDateInput(selection: $date)
                    }
                    .frame(width: 192)
                    """#
                ) {
                    ShadField {
                        ShadFieldLabel("Subscription Date")
                        DocDateInputPreview(text: "June 12, 2026")
                    }
                    .frame(width: 192)
                },

                DocExample(
                    "Date and time",
                    description: "One `Date`, edited as a day and a clock time. Twelve-hour by default; `clock: .twentyFourHour` for the other.",
                    width: 620,
                    code: #"""
                    @State private var appointment: Date? = Date()

                    ShadDateTimePicker(selection: $appointment)                          // 10:30:00 PM
                    ShadDateTimePicker(selection: $appointment, clock: .twentyFourHour)  // 22:30:00
                    ShadDateTimePicker(selection: $appointment, showsSeconds: false)     // 10:30 PM
                    """#
                ) {
                    VStack(alignment: .leading, spacing: 20) {
                        DocDateTimePreview(time: "10:30:00 PM", width: 132)
                        DocDateTimePreview(time: "22:30:00", width: 108)
                    }
                },

                DocExample(
                    "Formatting",
                    description: "How the trigger reads is a `ShadDateFormat`.",
                    code: #"""
                    ShadDatePicker(selection: $date, format: .medium)                  // Aug 27, 2026
                    ShadDatePicker(selection: $date, format: .style(.long))            // August 27, 2026
                    ShadDatePicker(selection: $date, format: .template("MMMM dd, yyyy"))

                    ShadDatePicker(selection: $date, format: ShadDateFormat { date, locale, _, _ in
                        date.formatted(.relative(presentation: .named))
                    })
                    """#
                ),
            ],
            notes: [
                "Picking a day closes the panel; a range stays open until both ends are set.",
                "ShadDateInput parses what you type against the reader's locale in long, medium and short forms, so \"1 Aug 2026\" works as well as the text it writes back.",
                "The time field reads both notations whichever clock it is set to, so \"22:30\" is understood in a twelve-hour field and \"10:30 pm\" in a twenty-four-hour one — with or without the space, in either case.",
                "Typing is not corrected until it means a different time, so \"10:30\" is not rewritten to \"10:30 AM\" before \" PM\" can be typed.",
                "shadcn's natural-language picker and its Today / Tomorrow / In 3 days presets are not implemented, nor is RTL.",
            ],
            api: [
                DocAPI(
                    "ShadDatePicker",
                    [
                        DocProperty("selection", "Binding<Date?>", "the chosen day"),
                        DocProperty("placeholder", "String", default: "\"Select date\"", "shown while nothing is picked, in muted-foreground"),
                        DocProperty("icon", "ShadDatePickerIcon", default: ".chevron", "chevron, calendar or none"),
                        DocProperty("width", "CGFloat?", default: "176", "trigger width; nil hugs the label"),
                        DocProperty("format", "ShadDateFormat", default: ".medium", "how the date reads on the trigger"),
                        DocProperty("captionLayout", "ShadCalendarCaptionLayout", default: ".label", "passed to the calendar"),
                        DocProperty("startMonth / endMonth", "Date?", default: "nil", "bounds the calendar"),
                        DocProperty("isDateDisabled", "((Date) -> Bool)?", default: "nil", "rules days out"),
                        DocProperty("isOpen", "Binding<Bool>?", default: "nil", "drive the panel from outside"),
                    ]
                ),
                DocAPI(
                    "ShadDateRangePicker",
                    [
                        DocProperty("range", "Binding<ShadDateRange?>", "the chosen span"),
                        DocProperty("numberOfMonths", "Int", default: "2", "months in the panel"),
                        DocProperty("icon", "ShadDatePickerIcon", default: ".calendar", "chevron, calendar or none"),
                        DocProperty("width", "CGFloat?", default: "240", "trigger width"),
                    ]
                ),
                DocAPI(
                    "ShadDateInput",
                    [
                        DocProperty("selection", "Binding<Date?>", "the parsed date"),
                        DocProperty("placeholder", "String", default: "\"June 01, 2025\"", "the shape of what to type"),
                        DocProperty("format", "ShadDateFormat", default: ".template(\"MMMM dd, yyyy\")", "how a picked date is written back"),
                        DocProperty("isInvalid", "Bool", default: "false", "destructive border and ring"),
                    ]
                ),
                DocAPI(
                    "ShadDateTimePicker",
                    [
                        DocProperty("selection", "Binding<Date?>", "the day and time together"),
                        DocProperty("dateLabel / timeLabel", "String", default: "\"Date\" / \"Time\"", "the two field labels"),
                        DocProperty("clock", "ShadClockStyle", default: ".twelveHour", "twelveHour writes 10:30:00 PM, twentyFourHour writes 22:30:00"),
                        DocProperty("showsSeconds", "Bool", default: "true", "seconds as well as hours and minutes"),
                        DocProperty("timeWidth", "CGFloat?", default: "nil", "nil sizes the field to the clock's longest time"),
                    ]
                ),
                DocAPI(
                    "ShadClockStyle",
                    summary: "Also usable on its own, for reading and writing times in your own fields.",
                    [
                        DocProperty("string(from:showsSeconds:locale:timeZone:)", "(Date, …) -> String", "writes a time in this clock's notation"),
                        DocProperty("time(from:locale:timeZone:)", "(String, …) -> DateComponents?", "reads a time in either clock's notation, or nil"),
                    ]
                ),
            ]
        )
    }
}

// MARK: - Snapshot helpers

/// A calendar pinned to a fixed month, so snapshots stay identical run to run.
@MainActor
struct DocCalendarPreview: View {
    var selected: Date?
    var range: ShadDateRange?
    var numberOfMonths: Int = 1
    var captionLayout: ShadCalendarCaptionLayout = .label
    var showsOutsideDays: Bool = true
    var calendar: Calendar = DocCalendarDates.calendar
    var isDateDisabled: ((Date) -> Bool)?

    var body: some View {
        Group {
            if let range {
                ShadCalendar(
                    range: .constant(range),
                    numberOfMonths: numberOfMonths,
                    defaultMonth: DocCalendarDates.month,
                    captionLayout: captionLayout,
                    showsOutsideDays: showsOutsideDays,
                    bordered: true,
                    calendar: calendar,
                    locale: Locale(identifier: "en_US"),
                    timeZone: TimeZone(identifier: "UTC") ?? .current,
                    isDateDisabled: isDateDisabled
                )
            } else {
                ShadCalendar(
                    selection: .constant(selected),
                    numberOfMonths: numberOfMonths,
                    defaultMonth: DocCalendarDates.month,
                    captionLayout: captionLayout,
                    showsOutsideDays: showsOutsideDays,
                    bordered: true,
                    calendar: calendar,
                    locale: Locale(identifier: "en_US"),
                    timeZone: TimeZone(identifier: "UTC") ?? .current,
                    isDateDisabled: isDateDisabled
                )
            }
        }
    }
}

@MainActor
struct DocDatePickerPreview: View {
    var date: Date?
    var placeholder: String = "Select date"
    var icon: ShadDatePickerIcon = .chevron

    var body: some View {
        ShadDatePicker(
            selection: .constant(date),
            placeholder: placeholder,
            icon: icon,
            locale: Locale(identifier: "en_US"),
            timeZone: TimeZone(identifier: "UTC") ?? .current
        )
    }
}

@MainActor
struct DocDateRangePickerPreview: View {
    var range: ShadDateRange?

    var body: some View {
        ShadDateRangePicker(
            range: .constant(range),
            locale: Locale(identifier: "en_US"),
            timeZone: TimeZone(identifier: "UTC") ?? .current
        )
    }
}

@MainActor
struct DocDateInputPreview: View {
    var text: String

    var body: some View {
        ShadInput(
            text: .constant(text),
            leading: { EmptyView() },
            trailing: { ShadIconView(.calendar, size: 16) }
        )
    }
}

/// The date-and-time pairing, in whichever notation the clock writes.
@MainActor
struct DocDateTimePreview: View {
    var time: String
    var width: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ShadField {
                ShadFieldLabel("Date")
                DocDatePickerPreview(date: DocCalendarDates.selected)
            }
            .frame(width: 176)
            ShadField {
                ShadFieldLabel("Time")
                DocTimeFieldPreview(text: time)
            }
            .frame(width: width)
        }
    }
}

@MainActor
struct DocTimeFieldPreview: View {
    var text: String

    var body: some View {
        ShadInput(text: .constant(text))
    }
}
