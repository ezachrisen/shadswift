import SwiftUI

/// A value held by a form field.
public enum ShadFormValue: Equatable {
    case text(String)
    case flag(Bool)
    case number(Double)
    case option(AnyHashable?)
    case options(Set<AnyHashable>)

    public var stringValue: String {
        if case .text(let value) = self { return value }
        return ""
    }

    public var boolValue: Bool {
        if case .flag(let value) = self { return value }
        return false
    }

    public var numberValue: Double {
        if case .number(let value) = self { return value }
        return 0
    }

    public var optionValue: AnyHashable? {
        if case .option(let value) = self { return value }
        return nil
    }

    public var optionsValue: Set<AnyHashable> {
        if case .options(let value) = self { return value }
        return []
    }

    /// True when the field has nothing meaningful in it.
    public var isEmpty: Bool {
        switch self {
        case .text(let value): return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .flag(let value): return !value
        case .number: return false
        case .option(let value): return value == nil
        case .options(let value): return value.isEmpty
        }
    }
}

/// A validation rule. Return `nil` when the value passes.
public struct ShadFormRule {
    public let validate: @MainActor (ShadFormValue) -> String?

    public init(_ validate: @escaping @MainActor (ShadFormValue) -> String?) {
        self.validate = validate
    }

    /// The value must not be empty.
    public static func required(_ message: String = "This field is required.") -> ShadFormRule {
        ShadFormRule { $0.isEmpty ? message : nil }
    }

    /// Minimum number of characters.
    public static func minLength(_ length: Int, message: String? = nil) -> ShadFormRule {
        ShadFormRule { value in
            value.stringValue.count >= length
                ? nil
                : (message ?? "Must be at least \(length) characters.")
        }
    }

    /// Maximum number of characters.
    public static func maxLength(_ length: Int, message: String? = nil) -> ShadFormRule {
        ShadFormRule { value in
            value.stringValue.count <= length
                ? nil
                : (message ?? "Must be at most \(length) characters.")
        }
    }

    /// A plausible email address.
    public static func email(_ message: String = "Enter a valid email address.") -> ShadFormRule {
        ShadFormRule { value in
            let text = value.stringValue
            if text.isEmpty { return nil }
            let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]{2,}$"#
            return text.range(of: pattern, options: .regularExpression) != nil ? nil : message
        }
    }

    /// The value must equal the value of another field.
    public static func matches(_ otherField: String, in model: ShadFormModel, message: String = "Values do not match.") -> ShadFormRule {
        ShadFormRule { [weak model] value in
            guard let model else { return nil }
            return value.stringValue == model.value(otherField).stringValue ? nil : message
        }
    }

    /// A checkbox that must be ticked.
    public static func mustAccept(_ message: String = "You must accept to continue.") -> ShadFormRule {
        ShadFormRule { $0.boolValue ? nil : message }
    }

    /// Anything else.
    public static func custom(_ validate: @escaping @MainActor (ShadFormValue) -> String?) -> ShadFormRule {
        ShadFormRule(validate)
    }
}

/// When a field re-validates.
public enum ShadFormValidationMode: String, CaseIterable, Sendable {
    /// Only when the form is submitted.
    case onSubmit
    /// On every keystroke, once the field has been touched.
    case onChange
    /// Whenever a field is submitted or the form is.
    case onTouched
}

/// Holds values, rules and errors for a form.
///
/// ```swift
/// @StateObject private var form = ShadFormModel(fields: [
///     ShadFormField("username", value: .text(""), rules: [.required(), .minLength(2)]),
///     ShadFormField("email", value: .text(""), rules: [.required(), .email()]),
/// ])
/// ```
@MainActor
public final class ShadFormModel: ObservableObject {
    @Published public private(set) var values: [String: ShadFormValue] = [:]
    @Published public private(set) var errors: [String: [String]] = [:]
    @Published public private(set) var touched: Set<String> = []
    @Published public private(set) var isSubmitting = false
    @Published public private(set) var didSubmit = false

    public var validationMode: ShadFormValidationMode

    private var rules: [String: [ShadFormRule]] = [:]
    private var initialValues: [String: ShadFormValue] = [:]

    public init(fields: [ShadFormFieldDefinition], validationMode: ShadFormValidationMode = .onTouched) {
        self.validationMode = validationMode
        for field in fields {
            values[field.name] = field.value
            initialValues[field.name] = field.value
            rules[field.name] = field.rules
        }
    }

    // MARK: Access

    public func value(_ name: String) -> ShadFormValue {
        values[name] ?? .text("")
    }

    public func error(_ name: String) -> String? {
        errors[name]?.first
    }

    public func allErrors(_ name: String) -> [String] {
        errors[name] ?? []
    }

    public var isValid: Bool { errors.values.allSatisfy(\.isEmpty) }

    public func setValue(_ name: String, _ value: ShadFormValue) {
        values[name] = value
        switch validationMode {
        case .onChange:
            validateField(name)
        case .onTouched:
            if touched.contains(name) || didSubmit { validateField(name) }
        case .onSubmit:
            if didSubmit { validateField(name) }
        }
    }

    public func markTouched(_ name: String) {
        touched.insert(name)
        if validationMode != .onSubmit { validateField(name) }
    }

    // MARK: Bindings

    public func text(_ name: String) -> Binding<String> {
        Binding(
            get: { self.value(name).stringValue },
            set: { self.setValue(name, .text($0)) }
        )
    }

    public func flag(_ name: String) -> Binding<Bool> {
        Binding(
            get: { self.value(name).boolValue },
            set: { self.setValue(name, .flag($0)) }
        )
    }

    public func number(_ name: String) -> Binding<Double> {
        Binding(
            get: { self.value(name).numberValue },
            set: { self.setValue(name, .number($0)) }
        )
    }

    public func option<Value: Hashable>(_ name: String, as type: Value.Type = Value.self) -> Binding<Value?> {
        Binding(
            get: { self.value(name).optionValue?.base as? Value },
            set: { self.setValue(name, .option($0.map { AnyHashable($0) })) }
        )
    }

    public func options<Value: Hashable>(_ name: String, as type: Value.Type = Value.self) -> Binding<Set<Value>> {
        Binding(
            get: { Set(self.value(name).optionsValue.compactMap { $0.base as? Value }) },
            set: { self.setValue(name, .options(Set($0.map { AnyHashable($0) }))) }
        )
    }

    // MARK: Validation

    @discardableResult
    public func validateField(_ name: String) -> Bool {
        let value = self.value(name)
        let messages = (rules[name] ?? []).compactMap { $0.validate(value) }
        errors[name] = messages
        return messages.isEmpty
    }

    @discardableResult
    public func validate() -> Bool {
        var valid = true
        for name in values.keys {
            if !validateField(name) { valid = false }
        }
        return valid
    }

    /// Validates, then runs `handler` when everything passes.
    public func submit(_ handler: ([String: ShadFormValue]) -> Void) {
        didSubmit = true
        touched = Set(values.keys)
        guard validate() else { return }
        handler(values)
    }

    /// The async flavour, which flips `isSubmitting` around the call.
    public func submit(_ handler: @escaping ([String: ShadFormValue]) async -> Void) {
        didSubmit = true
        touched = Set(values.keys)
        guard validate() else { return }
        isSubmitting = true
        Task { @MainActor in
            await handler(values)
            isSubmitting = false
        }
    }

    /// Restores the values the form was created with.
    public func reset() {
        values = initialValues
        errors = [:]
        touched = []
        didSubmit = false
    }

    /// Sets an error from outside, e.g. one returned by a server.
    public func setError(_ name: String, _ message: String?) {
        errors[name] = message.map { [$0] } ?? []
    }
}

/// Declares one field when building a ``ShadFormModel``.
public struct ShadFormFieldDefinition {
    public let name: String
    public let value: ShadFormValue
    public let rules: [ShadFormRule]

    public init(_ name: String, value: ShadFormValue, rules: [ShadFormRule] = []) {
        self.name = name
        self.value = value
        self.rules = rules
    }
}

/// Shorthand so field lists read well at the call site.
public typealias ShadFormField = ShadFormFieldDefinition

private struct ShadFormModelKey: EnvironmentKey {
    @MainActor static var defaultValue: ShadFormModel? { nil }
}

extension EnvironmentValues {
    /// The enclosing form's model.
    public var shadForm: ShadFormModel? {
        get { self[ShadFormModelKey.self] }
        set { self[ShadFormModelKey.self] = newValue }
    }
}

/// The form container: injects the model and stacks its rows.
///
/// ```swift
/// ShadForm(form) {
///     ShadFormRow("username") { field in
///         ShadFieldLabel("Username")
///         ShadInput("shadcn", text: field.text, isInvalid: field.hasError)
///         ShadFieldDescription("This is your public display name.")
///     }
///     ShadButton("Submit") { form.submit { values in … } }
/// }
/// ```
public struct ShadForm<Content: View>: View {
    @ObservedObject private var model: ShadFormModel
    private let spacing: CGFloat
    private let content: Content

    public init(_ model: ShadFormModel, spacing: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.model = model
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .environment(\.shadForm, model)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// What a ``ShadFormRow`` hands to its content: bindings plus error state.
@MainActor
public struct ShadFormFieldProxy {
    public let name: String
    private let model: ShadFormModel

    init(name: String, model: ShadFormModel) {
        self.name = name
        self.model = model
    }

    public var text: Binding<String> { model.text(name) }
    public var flag: Binding<Bool> { model.flag(name) }
    public var number: Binding<Double> { model.number(name) }
    public func option<Value: Hashable>(_ type: Value.Type = Value.self) -> Binding<Value?> { model.option(name) }
    public func options<Value: Hashable>(_ type: Value.Type = Value.self) -> Binding<Set<Value>> { model.options(name) }

    public var error: String? { model.error(name) }
    public var errors: [String] { model.allErrors(name) }
    public var hasError: Bool { !(model.allErrors(name).isEmpty) }
}

/// One row of a form: wires a named field to a ``ShadField`` and appends the
/// error message automatically.
public struct ShadFormRow<Content: View>: View {
    @Environment(\.shadForm) private var model

    private let name: String
    private let orientation: ShadFieldOrientation
    private let content: (ShadFormFieldProxy) -> Content

    public init(
        _ name: String,
        orientation: ShadFieldOrientation = .vertical,
        @ViewBuilder content: @escaping (ShadFormFieldProxy) -> Content
    ) {
        self.name = name
        self.orientation = orientation
        self.content = content
    }

    public var body: some View {
        if let model {
            let proxy = ShadFormFieldProxy(name: name, model: model)
            ShadField(orientation: orientation, isInvalid: proxy.hasError) {
                content(proxy)
                ShadFieldError(proxy.errors)
            }
        }
    }
}
