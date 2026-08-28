# ShadSwift component reference

Every public initialiser, grouped by component. Generated from the source — if a
symbol is not here, it does not exist.

Conventions: `Value` is any `Hashable`. `Label`, `Content`, `Trailing` etc. are
`@ViewBuilder` closures. Every component reads its styling from
`@Environment(\.shadTheme)`.

---

## Buttons

```swift
enum ShadButtonVariant { case `default`, secondary, destructive, outline, ghost, link }
enum ShadButtonSize    { case xs, sm, `default`, lg, icon, iconXS, iconSM, iconLG }
enum ShadButtonShape   { case rounded, pill, square }
```

Heights: `xs`/`iconXS` 24, `sm`/`iconSM` 28, `default`/`icon` 32, `lg`/`iconLG` 36.

```swift
ShadButton(_ title: String, variant: = .default, size: = .default,
           shape: = .rounded, icon: ShadIcon? = nil, trailingIcon: ShadIcon? = nil,
           isLoading: Bool = false, fillsWidth: Bool = false, action: () -> Void)

ShadButton(icon: ShadIcon, variant: = .default, size: = .icon, shape: = .rounded,
           accessibilityLabel: String? = nil, isLoading: Bool = false, action: () -> Void)

ShadButton(variant: = .default, size: = .default, shape: = .rounded,
           isLoading: Bool = false, fillsWidth: Bool = false,
           action: () -> Void, label: () -> Label)
```

To style a plain SwiftUI `Button`:

```swift
Button("Save") { save() }.buttonStyle(.shad(.default, size: .sm))
// ShadButtonStyle(variant:size:shape:isLoading:fillsWidth:)
```

## Inputs

```swift
enum ShadInputSize { case sm, `default`, lg }   // the trigger height is 32pt at .default

ShadInput(_ placeholder: String = "", text: Binding<String>, isSecure: Bool = false,
          size: = .default, isInvalid: Bool = false, onSubmit: (() -> Void)? = nil)

ShadInput(_ placeholder: String = "", text: Binding<String>, icon: ShadIcon, …)

ShadInput(_ placeholder: String = "", text: Binding<String>, …,
          leading: () -> Leading, trailing: () -> Trailing)

ShadFileInput(url: Binding<URL?>, prompt: String = "Choose file",
              allowedExtensions: [String]? = nil, size: = .default, isInvalid: Bool = false)

ShadTextarea(_ placeholder: String = "", text: Binding<String>,
             minHeight: CGFloat = 64, maxHeight: CGFloat? = nil,
             isInvalid: Bool = false, isResizable: Bool = false)

ShadLabel(_ text: String, isRequired: Bool = false)
```

## Toggles and choice

```swift
enum ShadCheckboxState { case unchecked, checked, indeterminate }

ShadCheckbox(_ label: String? = nil, isOn: Binding<Bool>, isInvalid: Bool = false, size: CGFloat = 16)
ShadCheckbox(_ label: String? = nil, state: Binding<ShadCheckboxState>, …)   // indeterminate

enum ShadSwitchSize { case sm, `default` }
ShadSwitch(_ label: String? = nil, isOn: Binding<Bool>, size: = .default, isInvalid: Bool = false)

ShadRadioGroup(selection: Binding<Value?>, spacing: CGFloat = 12, content: () -> Content)
ShadRadioGroup(selection: Binding<Value>,  spacing: CGFloat = 12, content: () -> Content)
  ShadRadio(_ title: String, description: String? = nil, value: Value, isInvalid: Bool = false)
  ShadRadioCard(_ title: String, description: String? = nil, value: Value)
  ShadRadioGroupItem(value: Value, isInvalid: Bool = false, size: CGFloat = 16)

ShadSlider(value:  Binding<Double>,   in: 0...100, step: Double? = nil, orientation: Axis = .horizontal,
           trackThickness: CGFloat = 4, thumbSize: CGFloat = 12, onEditingChanged: ((Bool) -> Void)? = nil)
ShadSlider(values: Binding<[Double]>, …)    // multiple thumbs / a range
```

## Fields and forms

```swift
enum ShadFieldOrientation { case vertical, horizontal, responsive }

ShadField(orientation: = .vertical, isInvalid: Bool = false, spacing: CGFloat? = nil,
          alignment: VerticalAlignment = .center, content: () -> Content)
  ShadFieldLabel(_ text: String, isRequired: Bool = false)
  ShadFieldTitle(_ text: String)
  ShadFieldDescription(_ text: String)
  ShadFieldError(_ message: String?)      // also accepts [String]
  ShadFieldContent(content:)

ShadFieldGroup(spacing: CGFloat = 20, content:)     // stacks ShadFields
ShadFieldSet(spacing: CGFloat = 16, content:)
ShadFieldLegend(_ text: String, variant: = .legend)
ShadFieldSeparator(_ label: String? = nil)

ShadCheckboxCard(_ title: String, description: String? = nil, isOn: Binding<Bool>)
ShadSwitchCard(_ title: String, description: String? = nil, isOn: Binding<Bool>)
ShadChoiceCard(isSelected: Bool, alignment: = .center, action: () -> Void, content:)
```

Validated forms:

```swift
enum ShadFormValue { case text(String), flag(Bool), number(Double),
                     option(AnyHashable?), options(Set<AnyHashable>) }
// accessors: .stringValue .boolValue .numberValue .optionValue .optionsValue .isEmpty

enum ShadFormValidationMode { case onSubmit, onChange, onTouched }
```

Built-in rules — prefer these over a hand-written closure:

```swift
ShadFormRule.required(_ message: String = "This field is required.")
ShadFormRule.minLength(_ length: Int, message: String? = nil)
ShadFormRule.maxLength(_ length: Int, message: String? = nil)
ShadFormRule.email(_ message: String = "Enter a valid email address.")
ShadFormRule.matches(_ otherField: String, in: ShadFormModel, message: String = "Values do not match.")
ShadFormRule.mustAccept(_ message: String = "You must accept to continue.")
ShadFormRule.custom { (value: ShadFormValue) -> String? in … }   // nil == valid
```

Wiring it up:

```swift
@StateObject private var form = ShadFormModel(fields: [
    ShadFormFieldDefinition("email",    value: .text(""),   rules: [.required(), .email()]),
    ShadFormFieldDefinition("password", value: .text(""),   rules: [.required(), .minLength(8)]),
    ShadFormFieldDefinition("terms",    value: .flag(false), rules: [.mustAccept()]),
], validationMode: .onTouched)

ShadForm(form) {
    ShadFormRow("email") { field in
        ShadFieldLabel("Email", isRequired: true)
        ShadInput("you@example.com", text: field.text, isInvalid: field.hasError)
        ShadFieldError(field.error)
    }
    ShadFormRow("terms") { field in
        ShadCheckbox("I accept the terms", isOn: field.flag)
        ShadFieldError(field.error)
    }
    ShadButton("Create account") { if form.validate() { … } }
}
```

`ShadFormFieldProxy` (the `field` above) gives you `.text` `.flag` `.number`
bindings, `.option(_:)` / `.options(_:)` for `Hashable` values, and
`.error` `.errors` `.hasError`.

`ShadFormModel` also exposes `validate()`, `validateField(_:)`, `submit(_:)`,
`reset()`, `setValue(_:for:)`, `setError(_:for:)`, `markTouched(_:)` and
`value(_:)`.

## Selection popovers

```swift
ShadSelectOption(_ label: String, value: Value, description: String? = nil,
                 icon: ShadIcon? = nil, isDisabled: Bool = false, keywords: [String] = [])
ShadSelectSection(_ label: String? = nil, options: [ShadSelectOption<Value>])

ShadSelect(selection: Binding<Value?>, options: [ShadSelectOption<Value>],
           placeholder: String = "Select…", isInvalid: Bool = false,
           width: CGFloat? = nil, isOpen: Binding<Bool>? = nil)
ShadSelect(selection: Binding<Value?>, sections: [ShadSelectSection<Value>], …)

ShadCombobox(selection: Binding<Value?>, options: […],
             placeholder: String = "Search…", emptyMessage: String = "No results found.",
             size: = .default, isInvalid: Bool = false, showsClear: Bool = false,
             autoHighlight: Bool = true, icon: ShadIcon? = nil, width: CGFloat? = nil)
ShadComboboxMultiple(selection: Binding<Set<Value>>, options: […], …)
ShadComboboxButton(selection: Binding<Value?>, options: […],
                   placeholder: = "Select…", searchPlaceholder: = "Search…",
                   emptyMessage: = "No results found.", width: CGFloat = 220)
```

Panels handle ↑ ↓ Home End Return Escape. Options match on `label`, `description`
and `keywords`.

## Menus

```swift
ShadDropdownMenu(_ title: String, variant: = .outline, size: = .default,
                 icon: ShadIcon? = nil, showsChevron: Bool = false,
                 isOpen: Binding<Bool>? = nil, alignment: = .bottomLeading,
                 minWidth: CGFloat = 176, content: () -> Content)
ShadDropdownMenu(isOpen:alignment:minWidth:trigger: (Bool) -> Trigger, content:)

  ShadDropdownMenuItem(_ title: String, description: String? = nil, icon: ShadIcon? = nil,
                       variant: ShadMenuItemVariant = .default, isInset: Bool = false,
                       shortcut: String, dismissesMenu: Bool = true, action: () -> Void)
  ShadDropdownMenuCheckboxItem(_ title: String, isOn: Binding<Bool>, dismissesMenu: Bool = false)
  ShadDropdownMenuRadioGroup(selection: Binding<Value>, content:)
    ShadDropdownMenuRadioItem(_ title: String, value: Value, dismissesMenu: Bool = true)
  ShadDropdownMenuSub(_ title: String, icon: ShadIcon? = nil, minWidth: CGFloat = 176, content:)
  ShadDropdownMenuGroup(content:) · ShadDropdownMenuSeparator() · ShadMenuLabel(_:isInset:)
```

`ShadMenuItemVariant` is `.default` or `.destructive`.

## Overlays

```swift
.shadDialog(isPresented: Binding<Bool>, dismissOnBackdropTap: Bool = true, content:)
  ShadDialogContent(maxWidth: CGFloat = 512, showsCloseButton: Bool = true, content:)
  ShadDialogContent(maxWidth:showsCloseButton:content:footer:)
    ShadDialogHeader(content:) · ShadDialogTitle(_:) · ShadDialogDescription(_:)
    ShadDialogBody(maxHeight: CGFloat = 360, content:)     // scrolls
    ShadDialogFooter(content:)
    ShadDialogClose(_ title: String, variant: = .outline, size: = .default, action: = {})

.shadAlertDialog(isPresented: Binding<Bool>, content:)     // no backdrop dismiss
  ShadAlertDialogContent(maxWidth: CGFloat = 448, content:, actions:)
    ShadAlertDialogTitle(_:) · ShadAlertDialogDescription(_:)
    ShadAlertDialogCancel(_ title: String = "Cancel", action: = {})
    ShadAlertDialogAction(_ title: String, variant: = .default,
                          dismissesOnTap: Bool = true, action: () -> Void)

.shadPopover(isPresented: Binding<Bool>, configuration: ShadPopoverConfiguration = .init(),
             onKey: (ShadPopoverKey) -> Bool = { _ in false }, content:)
```

A dialog blurs the content beneath it rather than greying it out; tune with
`ShadMotion.dialogBackdropBlur`.

## Toasts

```swift
enum ShadToastType     { case normal, success, error, warning, info, loading }
enum ShadToastPosition { case topLeading, topCenter, topTrailing,
                         bottomLeading, bottomCenter, bottomTrailing }

@StateObject var toasts = ShadToastCenter(limit: 3, defaultDuration: 4)

.shadToaster(toasts, position: = .bottomTrailing, expandsOnHover: Bool = true)

toasts.add(title:description:type:duration:actionTitle:action:) -> UUID
toasts.success(_ title: String, description: String? = nil, duration: TimeInterval? = nil)
// …and .error / .warning / .info / .loading, each returning the toast's UUID

toasts.update(_ id: UUID, title:description:type:duration:)
toasts.promise(_ operation, loading:, success: (T) -> String, failure: (Error) -> String)
toasts.close(_ id: UUID) · toasts.closeAll()
toasts.pauseTimers() · toasts.resumeTimers()
```

`.loading` toasts have no duration — close them by id, or drive the whole
lifecycle with `promise(_:loading:success:failure:)`.

## Surfaces

```swift
enum ShadCardSize { case `default`, sm }

ShadCard(size: = .default, spacing: CGFloat? = nil, content: () -> Content)
  ShadCardHeader(showsSeparator: Bool = false, content:)          // + action: trailing slot
  ShadCardTitle(_:) · ShadCardDescription(_:)
  ShadCardContent(content:)
  ShadCardFooter(showsSeparator: Bool = false, content:)

enum ShadItemVariant { case `default`, outline, muted }
enum ShadItemSize    { case `default`, sm, xs }

ShadItem(variant: = .default, size: = .default, action: (() -> Void)? = nil, content:)
  ShadItemMedia(icon: ShadIcon, size: CGFloat = 40, iconSize: CGFloat = 16)
  ShadItemContent(content:) · ShadItemTitle(_:) · ShadItemDescription(_:)
  ShadItemActions(spacing: CGFloat = 8, content:)
ShadItemGroup(spacing: CGFloat = 0, isBordered: Bool = false, content:)
ShadItemSeparator()

ShadSeparator(_ axis: Axis = .horizontal, color: Color? = nil)
```

## Display

```swift
enum ShadBadgeVariant { case `default`, secondary, destructive, outline, ghost, link }

ShadBadge(_ title: String, variant: = .default, shape: = .pill,
          color: ShadBadgeColor? = nil, icon: ShadIcon? = nil, trailingIcon: ShadIcon? = nil)
ShadBadge(variant:shape:color:content:)
ShadBadgeDot(_ color: Color, size: CGFloat = 6) · ShadBadgeLink(_ title:action:)
// ShadBadgeColor.blue/.green/.sky/.purple/.red, or init(lightBackground:lightForeground:
//                                                        darkBackground:darkForeground:)

enum ShadAvatarSize  { case sm, `default`, lg }
enum ShadAvatarImage { case none, url(URL), resource(String), symbol(ShadIcon) }

ShadAvatar(image: = .none, fallback: String = "", size: = .default,
           customSize: CGFloat? = nil, shape: ShadButtonShape = .pill)
ShadAvatarBadge(color: Color, icon: ShadIcon? = nil, diameter: CGFloat = 10)
ShadAvatarGroup(overlap: CGFloat = 8, content:) · ShadAvatarGroupCount(_ count: Int, size:)

ShadSpinner(size: CGFloat = 16, style: Style = .arc, color: Color? = nil, lineWidth: CGFloat? = nil)
// Style: .arc (loader-circle), .spokes (loader), .dots
```

### Avatar editor

A pick / drag-to-reposition / zoom / crop flow, presented as a dialog.

```swift
ShadAvatarCrop(zoom: Double = 1, offset: CGSize = .zero)     // .fill
ShadAvatarPhoto(image: NSImage? = nil, crop: ShadAvatarCrop = .fill)   // .empty, .isEmpty

@State private var avatar = ShadAvatarEditorState(image: nil)   // or (photo:)

// The avatar itself — click it to start editing:
ShadEditableAvatar($avatar, fallback: "AB", size: = .default,
                   customSize: CGFloat? = nil, shape: ShadButtonShape = .pill)

// Attach the editing dialog at the root, as with any dialog:
.shadAvatarEditor($avatar,
                  title: String = "Profile picture",
                  description: String? = "Drag the picture to reposition it, …",
                  diameter: CGFloat = 196, shape: = .pill,
                  zoomRange: ClosedRange<Double> = 1...3,
                  saveTitle: String = "Save", cancelTitle: String = "Cancel",
                  onSave: ((ShadAvatarPhoto) -> Void)? = nil)

// Or drop the cropping stage into a layout of your own:
ShadAvatarCropper(photo: Binding<ShadAvatarPhoto>, diameter: CGFloat = 196,
                  shape: = .pill, zoomRange: ClosedRange<Double> = 1...3)
```

Escape, the close button and the backdrop all cancel. `ShadAvatarEditor` is the
panel itself if you would rather present it another way.


## Tables

```swift
enum ShadTableAlignment   { case leading, center, trailing }
enum ShadTableColumnWidth { case automatic, flexible(min: CGFloat = 0), fixed(CGFloat) }

ShadTableColumn(_ title: String, id: String? = nil, alignment: = .leading,
                width: = .automatic, canHide: Bool = true, isSearchable: Bool = true,
                value: (Row) -> String,
                style: ((Row) -> ShadTableCellStyle)? = nil,
                sortBy: ((Row, Row) -> Bool)? = nil)

ShadTable(_ rows: [Row], columns: [ShadTableColumn<Row>],
          selection: Binding<Set<Row.ID>>? = nil, sort: Binding<ShadTableSort?>? = nil,
          bordered: Bool = true, emptyMessage: String = "No results.")

ShadDataTable(_ rows: [Row], columns: [ShadTableColumn<Row>],
              selection: Binding<Set<Row.ID>>? = nil,
              filter: Binding<String>? = nil, filterPlaceholder: String = "Filter…",
              showsFilter: Bool = true, showsColumnPicker: Bool = true,
              showsSelectionCount: Bool? = nil,
              pageSize: Int? = 10, paginationStyle: = .simple,
              sort: ShadTableSort? = nil, emptyMessage: String = "No results.",
              bordered: Bool = true)

ShadTableCellStyle(color: Color? = nil, weight: Font.Weight? = nil,
                   isMonospaced: Bool = false, opacity: Double? = nil)
ShadTableSort(columnID: String, direction: .ascending | .descending)

ShadPagination(page: Binding<Int>, pageCount: Int, siblingCount: Int = 1, showsLabels: Bool = true)
```

`Row` must be `Identifiable`.

## Navigation

```swift
enum ShadTabsVariant { case `default`, line }

ShadTabs(selection: Binding<Value>, variant: = .default,
         orientation: Axis = .horizontal, spacing: CGFloat = 8, content:)
  ShadTabsList(content:)
    ShadTabsTrigger(_ title: String, value: Value, icon: ShadIcon? = nil)
    ShadTabsTrigger(value: Value, label: () -> Label)
  ShadTabsContent(value: Value, content:)

ShadBreadcrumb(content:)
  ShadBreadcrumbList(content:)
    ShadBreadcrumbItem(content:)
    ShadBreadcrumbLink(_ title: String, icon: ShadIcon? = nil, action: () -> Void)
    ShadBreadcrumbPage(_ title: String, icon: ShadIcon? = nil)     // the current page
    ShadBreadcrumbSeparator() · ShadBreadcrumbEllipsis()

// Data-driven alternative, with automatic collapsing:
ShadCrumb(_ title: String, icon: ShadIcon? = nil)
ShadBreadcrumbPath(_ crumbs: [ShadCrumb])
ShadBreadcrumbPath(path:maxVisible:onNavigate:)
```

## Sidebar

Everything must sit inside a provider:

```swift
enum ShadSidebarSide        { case left, right }
enum ShadSidebarVariant     { case sidebar, floating, inset }
enum ShadSidebarCollapsible { case offcanvas, icon, none }

@StateObject var sidebar = ShadSidebarState(isOpen: true, width: 256, iconWidth: 48)

ShadSidebarProvider(state: sidebar) {
    HStack(spacing: 0) {
        ShadSidebar(side: = .left, variant: = .sidebar, collapsible: = .icon) {
            ShadSidebarHeader { … }
            ShadSidebarContent {
                ShadSidebarGroup("Platform") {
                    ShadSidebarMenu {
                        ShadSidebarMenuItem {
                            ShadSidebarMenuButton("Inbox", icon: .mail, isActive: true) { … }
                        }
                    }
                }
            }
            ShadSidebarFooter { … }
        }
        ShadSidebarInset(variant: .sidebar) { … }
    }
}
```

Also: `ShadSidebarMenuBadge(_:)`, `ShadSidebarMenuAction(action:content:)`,
`ShadSidebarMenuSub` / `ShadSidebarMenuSubButton(_:isActive:action:)`,
`ShadSidebarTrigger()`, `ShadSidebarRail()`, and
`.shadSidebarHiddenWhenCollapsed()`.

## Dates

```swift
ShadCalendar(selection: Binding<Date?>, numberOfMonths: Int = 1, month: Binding<Date>? = nil,
             defaultMonth: Date? = nil, captionLayout: = .label, showsOutsideDays: Bool = true,
             bordered: Bool = false, axis: Axis = .horizontal,
             startMonth: Date? = nil, endMonth: Date? = nil,
             calendar: = .current, locale: = .current, timeZone: = .current,
             isDateDisabled: ((Date) -> Bool)? = nil)

ShadDatePicker(selection: Binding<Date?>, placeholder: String = "Select date",
               icon: ShadDatePickerIcon = .chevron, width: CGFloat? = 176,
               format: ShadDateFormat = .medium, …)
ShadDateRangePicker(range: Binding<ShadDateRange?>, placeholder: = "Pick a date range",
                    icon: = .calendar, width: CGFloat? = 240, format: = .medium, …)
ShadDateInput(selection: Binding<Date?>, placeholder: = "June 01, 2025",
              format: = .template("MMMM dd, yyyy"), …)        // typed, with a calendar popover
ShadDateTimePicker(selection: Binding<Date?>, clock: ShadClockStyle = .twelveHour,
                   format: = .medium, …)

ShadDateRange(from: Date, to: Date? = nil)      // .isComplete, .end, .contains(_:in:)
ShadDateFormat.medium · .template("…") · .style(…) · .init { date, locale, calendar, tz in … }
ShadCalendarCaptionLayout: .label, .dropdown, .dropdownMonths, .dropdownYears
```

## Conversation

```swift
enum ShadMessageAlignment { case start, end }
enum ShadBubbleVariant    { case sent, received, `default`, secondary, muted,
                            tinted, outline, ghost, destructive }

ShadMessageGroup(spacing: CGFloat = 3) {
    ShadMessage(align: .start, spacing: 8, hasFooter: Bool = false) {
        ShadMessageAvatar { ShadAvatar(fallback: "AB") }
        ShadMessageContent {
            ShadMessageHeader("Ada")
            ShadBubble(variant: .received) { ShadBubbleContent("Morning.") }
            ShadMessageFooter("09:41")
        }
    }
}

ShadBubble(variant: = .received, align: = .start, maxWidthFraction: CGFloat = 0.8, content:)
ShadBubbleContent(_ text: String) · ShadBubbleReactions(["👍"]) · ShadBubbleGroup(align:content:)
ShadTypingIndicator(_ label: String? = nil)

ShadMarker(variant: ShadMarkerVariant = .default, action: (() -> Void)? = nil, content:)
  ShadMarkerIcon(_ icon: ShadIcon, size: CGFloat = 14)
  ShadMarkerContent(_ text: String, shimmer: Bool = false)

// Auto-scrolling transcript:
@StateObject var scroller = ShadMessageScrollerModel(autoScroll: true, defaultScrollPosition: .end,
                                                     scrollPreviousItemPeek: 0,
                                                     preserveScrollOnPrepend: true)
ShadMessageScrollerProvider(scroller) {
    ShadMessageScroller(isBordered: false) {
        ShadMessageScrollerViewport {
            ForEach(messages) { m in ShadMessageScrollerItem(messageId: m.id) { … } }
        }
        ShadMessageScrollerButton(edge: .end, title: nil)
    }
}
```

`ShadBubble`'s sent/received colours come from the `bubbleSent` / `bubbleReceived`
tokens, which are independent of `primary` — a brand colour change does not
recolour the conversation.

## Icons

```swift
ShadIconView(_ icon: ShadIcon, size: CGFloat = 16,
             weight: Font.Weight = .regular, strokeWidth: CGFloat? = nil)
```

`ShadIcon` named cases:

```
check chevronDown chevronUp chevronRight chevronLeft chevronsUpDown x plus minus
search user users settings bell mail calendar home folder file trash copy pencil
share download upload star heart info circleAlert triangleAlert circleCheck circleX
circle creditCard logOut moreHorizontal moreVertical panelLeft panelRight arrowUp
arrowDown arrowRight arrowLeft arrowUpRight arrowUpDown sparkles bot send refresh
eye eyeOff lock globe terminal image play pause gitBranch gitPullRequest cloud
cloudUpload zap tag bookmark clock filter list grid clipboardList gripVertical
loaderCircle slash
```

Plus `.lucide("kebab-case-name")` for any of the 72 bundled Lucide glyphs, and
`.custom("sfsymbol.name")` for an SF Symbol. Glyphs are stroked natively at
Lucide's 2-in-24 weight.

## Utilities

```swift
.shadStaticRendering()        // makes a subtree safe for ImageRenderer snapshots
.shadShadow(ShadShadow)       // two-layer shadow cast by the background shape
.shadShimmer()                // skeleton shimmer
ShadWrapLayout(spacing:)      // flow layout that wraps
ShadRoundedRectangle          // continuous-corner rect used by every component
ShadSurface                   // themed background + border
ShadFocusRing                 // :focus-visible ring, sits outside the border
```
