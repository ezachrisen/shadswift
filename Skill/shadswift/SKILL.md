---
name: shadswift
description: Build macOS SwiftUI interfaces with the ShadSwift component library — ShadButton, ShadInput, ShadSelect, ShadDialog, ShadTable, ShadSidebar, ShadToast, ShadForm and OKLCH theming via ShadThemeSet. Use whenever writing or editing SwiftUI views in a project that depends on ShadSwift, when adding ShadSwift to a project, or when a macOS app should follow shadcn/ui styling.
---

# ShadSwift

A SwiftUI port of [shadcn/ui](https://ui.shadcn.com/docs/components) for macOS 14+.
Thirty-nine components, real Lucide icons, Geist bundled, and one theme value that
drives every colour, radius, type size, shadow and animation.

Everything is prefixed `Shad`. If you are reaching for a plain SwiftUI control in a
project that depends on ShadSwift, you are almost certainly reaching for the wrong
thing — check the catalogue below first.

## Adding it to a project

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/ezachrisen/shadswift.git", from: "0.1.0")
],
targets: [
    .target(name: "MyApp", dependencies: [.product(name: "ShadSwift", package: "shadswift")])
]
```

In Xcode: File → Add Package Dependencies → paste the URL. Requires macOS 14+ and a
full Xcode install (the SwiftUI macros need more than Command Line Tools).

## The three setup rules

**1. Apply the theme at the root, or dark mode will not work.**

```swift
WindowGroup {
    ContentView()
        .shadTheme(.default)        // resolves light/dark from the environment
}
```

Components read an already-resolved `ShadTheme` from the environment. Its default
value is hard-coded to the *light* palette, so a view hierarchy with no
`.shadTheme(_:)` above it renders light even in dark mode. This is the single most
common mistake — apply it once, as high as you can.

**2. Dialogs and toasts attach to the window root**, not to the button that opens
them. The scrim and the toast stack need to cover everything below.

```swift
ContentView()
    .shadTheme(.default)
    .shadToaster(toasts)                        // ShadToastCenter
    .shadDialog(isPresented: $showingEdit) { … }
```

**3. Never set colours, fonts or radii literally.** Read them from the theme, so a
palette change moves the whole app at once:

```swift
@Environment(\.shadTheme) private var theme
…
Text("Total")
    .font(theme.font(theme.typography.sm, theme.typography.medium))
    .foregroundStyle(theme.colors.mutedForeground)
    .padding(theme.spacing.lg)
```

`theme.typography` holds sizes and weights separately; `theme.font(_:_:)` turns a
pair into a `Font`.

## Component catalogue

Use these instead of hand-rolling or falling back to AppKit/SwiftUI defaults.

| Need | Use |
| --- | --- |
| Button | `ShadButton` — or `.buttonStyle(.shad(...))` on a plain `Button` |
| Text field, password, search | `ShadInput` |
| Multi-line text | `ShadTextarea` |
| Standalone form label | `ShadLabel` |
| File picker | `ShadFileInput` |
| Checkbox / toggle / radio | `ShadCheckbox`, `ShadSwitch`, `ShadRadioGroup` |
| Slider | `ShadSlider` (single value or multiple thumbs) |
| Pop-up / dropdown selection | `ShadSelect` |
| Searchable selection | `ShadCombobox`, `ShadComboboxMultiple` |
| Context / action menu | `ShadDropdownMenu` |
| Labelled field with help + error | `ShadField` + `ShadFieldLabel` / `ShadFieldDescription` / `ShadFieldError` |
| Whole validated form | `ShadForm` + `ShadFormModel` |
| Modal | `.shadDialog(isPresented:)` + `ShadDialogContent` |
| Destructive confirm | `.shadAlertDialog(isPresented:)` + `ShadAlertDialogContent` |
| Transient notification | `ShadToastCenter` + `.shadToaster(_:)` |
| Panel anchored to a control | `.shadPopover(...)` |
| Card / surface | `ShadCard` + `ShadCardHeader` / `ShadCardContent` / `ShadCardFooter` |
| List row with media, title, actions | `ShadItem`, `ShadItemGroup` |
| Status pill | `ShadBadge` |
| Avatar, avatar stack | `ShadAvatar`, `ShadAvatarGroup` |
| Editable profile picture | `ShadEditableAvatar` + `.shadAvatarEditor(_:)` |
| Loading | `ShadSpinner`, or `isLoading:` on `ShadButton` |
| Static table | `ShadTable` |
| Sortable, filterable, paginated table | `ShadDataTable` |
| Page numbers | `ShadPagination` |
| Tabs | `ShadTabs` + `ShadTabsList` / `ShadTabsTrigger` / `ShadTabsContent` |
| App sidebar | `ShadSidebarProvider` + `ShadSidebar` + `ShadSidebarInset` |
| Breadcrumbs | `ShadBreadcrumb`, or `ShadBreadcrumbPath` for a data-driven trail |
| Divider | `ShadSeparator` |
| Date / time entry | `ShadDatePicker`, `ShadDateRangePicker`, `ShadDateInput`, `ShadDateTimePicker` |
| Inline month grid | `ShadCalendar` |
| Chat transcript | `ShadMessage`, `ShadBubble`, `ShadMarker`, `ShadMessageScroller` |
| Icon | `ShadIconView(.check, size: 16)` |

Full initialiser signatures for every one of these: [reference/components.md](reference/components.md).
Theme tokens, presets and overrides: [reference/theming.md](reference/theming.md).

## House style

```swift
ShadButton("Save", icon: .check) { save() }
ShadButton("Delete", variant: .destructive, icon: .trash) { delete() }
ShadButton("Cancel", variant: .outline) { dismiss() }
ShadButton(icon: .plus, variant: .ghost, size: .icon, accessibilityLabel: "Add") { add() }
```

- **Variants** are `.default` (solid primary), `.secondary`, `.destructive`,
  `.outline`, `.ghost`, `.link`. Sizes are `.xs .sm .default .lg` and the
  icon-only `.iconXS .iconSM .icon .iconLG`.
- **Icon-only buttons always take `accessibilityLabel:`.**
- **Destructive is a wash, not a fill** — a 10% background with destructive text.
  Do not "fix" this to a solid red.
- **Controls are flat.** Buttons, inputs, checkboxes, switches, sliders and menus
  carry no shadow. Only cards, dialogs and toasts are elevated. Do not add
  `.shadow(...)`.
- **Icons come from `ShadIcon`** — 72 named cases (`.check`, `.chevronDown`,
  `.trash`, `.search`, `.settings`, …), one per bundled glyph, plus two escape
  hatches: `.lucide("circle-plus")` reaches a glyph by its Lucide name and
  `.custom("sfsymbol.name")` falls back to an SF Symbol. Prefer the named cases; prefer Lucide over SF Symbols, whose
  optical weight is heavier than the text beside it.

A form, end to end:

```swift
ShadFieldGroup {
    ShadField {
        ShadFieldLabel("Email", isRequired: true)
        ShadInput("you@example.com", text: $email, icon: .mail)
        ShadFieldDescription("We'll never share it.")
    }
    ShadField(isInvalid: !password.isValid) {
        ShadFieldLabel("Password")
        ShadInput("", text: $password, isSecure: true, isInvalid: !password.isValid)
        ShadFieldError(password.error)
    }
}
```

Selection, which is generic over any `Hashable` value:

```swift
@State private var role: Role?

ShadSelect(selection: $role, options: [
    ShadSelectOption("Owner", value: .owner, description: "Full access"),
    ShadSelectOption("Member", value: .member),
])
```

## Traps

- **`ShadCheckbox` has two initialisers.** `isOn:` takes a `Binding<Bool>`;
  `state:` takes a `Binding<ShadCheckboxState>` and is the one that supports
  `.indeterminate`.
- **`ShadRadioGroup` and `ShadSelect` bind to `Value?`** (optional) by default.
  `ShadRadioGroup` also has a non-optional overload; `ShadSelect` does not.
- **`ShadTable` vs `ShadDataTable`.** `ShadTable` is the presentational one.
  `ShadDataTable` wraps it with a filter field, a column picker and pagination —
  reach for it whenever the data is user-searchable.
- **Popovers are real `NSPanel`s.** `ShadSelect`, `ShadCombobox` and
  `ShadDropdownMenu` present in a child window so they can escape a `ScrollView`
  and the window edge. They need a real window — they will not appear in an Xcode
  preview that has none.
- **Snapshotting with `ImageRenderer` needs `.shadStaticRendering()`**, which
  swaps `ScrollView`/`LazyVStack`/`TextField` for renderable stand-ins.
- **Sidebar needs the provider.** `ShadSidebar` and `ShadSidebarInset` must both
  live inside a `ShadSidebarProvider(state:)` holding a `ShadSidebarState`.
- **Fonts in a hand-assembled `.app`.** SwiftPM's resource bundle must be copied
  into the bundle or Geist silently falls back to the system font. See
  `Scripts/build-app.sh` in the library repo.

## Checking your work

The library repo ships a generated reference — every component, every variant,
rendered light and dark from the real views, with the Swift beside it:

```bash
./Scripts/generate-docs.sh && open Docs/index.html
```

and a gallery app that exercises every component and theme knob live:

```bash
./Scripts/build-app.sh && open build/ShadSwiftDemo.app
```

If a symbol you want does not appear in [reference/components.md](reference/components.md),
it does not exist — check the real source rather than inventing an initialiser.
