# ShadSwift

A SwiftUI component library for macOS, modelled on [shadcn/ui](https://ui.shadcn.com/docs/components).

Twenty-six components, every documented variant, and one theme value that drives
every colour, corner radius, type size, shadow and animation in the library.
Geist ships with the package, and the metrics are measured from the live shadcn
site rather than eyeballed.

```swift
import SwiftUI
import ShadSwift

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .shadTheme(.default)
        }
    }
}
```

## What's in the box

| Group | Components |
| --- | --- |
| Display | Button · Badge · Card · Avatar · Item · Spinner |
| Controls | Switch · Checkbox · Radio Group · Slider · Tabs |
| Forms | Input · Textarea · Field · Form · Label |
| Overlays | Select · Combobox · Dropdown Menu · Dialog · Alert Dialog · Toast |
| Layout | Sidebar · Separator |
| Conversation | Message · Bubble · Marker · Message Scroller |

## Installing it

ShadSwift is distributed as a private SwiftPM package. Add it to a project:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/ezachrisen/shadswift.git", from: "0.1.0")
],
targets: [
    .target(name: "MyApp", dependencies: [.product(name: "ShadSwift", package: "shadswift")])
]
```

In Xcode: File ▸ Add Package Dependencies, paste the URL. The repository is
private, so Xcode needs your GitHub account under Settings ▸ Accounts, and the
command line needs git credentials for github.com:

```bash
gh auth setup-git
```

### Shipping an update

`from:` tracks every minor and patch release, so a consumer only has to resolve
again to pick one up.

```bash
./Scripts/release.sh 0.2.0        # builds, checks icons, tags, pushes
./Scripts/update-consumers.sh     # pulls it into every project that uses it
```

`update-consumers.sh` searches `~/code` by default — pass a different root as its
first argument, or set `DRY_RUN=1` to see what it would touch. Xcode projects are
listed rather than updated; they resolve through File ▸ Packages ▸ Update to
Latest Package Versions.

Bump the major version for a breaking change, and pin the projects that are not
ready for it.

### The agent skill

`Skill/shadswift/` is a Claude Code skill that teaches an agent the library — the
component catalogue, the theming model, and the mistakes that are easy to make.
Install it once for your user and every project gets it:

```bash
./Scripts/install-skill.sh
```

It symlinks into `~/.claude/skills/`, so pulling this repo updates the skill too.
Pass `--copy` on a machine where a symlink is not wanted.

## Documentation

`Docs/index.html` is a complete static site: one page per component, every
example rendered from the real SwiftUI views, in both light and dark, with the
Swift you would write beside it.

```bash
./Scripts/generate-docs.sh
open Docs/index.html
```

`./Scripts/check-icons.sh` verifies that every bundled Lucide glyph still
parses into real geometry — a silent path-parser failure renders as nothing,
which is very easy to miss by eye.

## Demo app

A macOS gallery app exercises every component and every theme knob — base
colour, radius, dark mode and typeface, all live.

```bash
./Scripts/build-app.sh
open build/ShadSwiftDemo.app
```

It also takes launch arguments, which is handy for screenshots:

```bash
open -n build/ShadSwiftDemo.app --args --page combobox --dark --preset blue --radius 4
```

## Fidelity

The numbers came from the live shadcn/ui site — computed styles read out of the
rendered DOM — not from a screenshot:

- **Type.** Geist and Geist Mono ship with the package under the SIL Open Font
  License and register themselves with Core Text on first use. Nothing has to
  be installed. Weights address the face by name (`Geist-Medium`) rather than
  asking SwiftUI to apply a weight to a family, which is how you end up a step
  bolder than the web. `ShadTypography.system` opts out.
- **Icons.** The real [Lucide](https://lucide.dev) glyphs — the pack shadcn
  draws from — vectorised from the upstream SVGs and stroked natively at
  Lucide's own 2-in-24 weight. SF Symbols are a fallback, not the default:
  their optical sizing is heavier than the text beside them.
- **Focus rings** sit entirely outside the border, and follow `:focus-visible`
  — a ring appears when you tab to a control, not when you click it.
- **A modal blurs the app** rather than covering it with a grey sheet. SwiftUI's
  `Material` cannot do this in an in-window overlay — it tints against the
  window, not the content — so the content itself is blurred beneath a light
  scrim. `ShadMotion.dialogBackdropBlur` tunes it.
- **Chat bubbles have their own tokens.** `bubbleSent` and `bubbleReceived` are
  independent of `primary`, so a conversation keeps its palette whatever the
  brand colour is: blue on the right, grey on the left, by default.
- **No shadows on controls.** Buttons, inputs, checkboxes, switches, sliders,
  select triggers and menus are all flat; shadcn's `shadow-xs` resolves to
  nothing. Only cards, dialogs and toasts are elevated, and those shadows are
  two-layer, cast by the background shape so text never picks up a halo.
- **Sizes.** Buttons are 24 / 28 / 32 / 36pt. Inputs and select triggers are
  32pt. Slider tracks are 4pt with a 12pt thumb. Badges are 20pt pills.
- **Destructive is a wash.** A 10% destructive background with destructive
  text, not a solid red fill — for buttons, badges and bubbles alike.
- **Press.** Buttons sink one point, matching `active:translate-y-px`.
- **Invalid.** A 3pt destructive halo stays around an invalid control whether
  or not it has focus.
- **Select opens over its trigger** with the selected row on top of it, the way
  a shadcn Select and a macOS pop-up button both behave.

## Theming

Colours are authored in OKLCH — the same notation shadcn uses in `globals.css` —
and converted to sRGB at build time, so a palette copied from the web
translates almost verbatim.

```swift
let brand = ShadThemeSet.slate
    .radius(4)                                   // --radius
    .fontName("Geist")                           // type family
    .tinted(light: OKLCH(0.55, 0.20, 264),       // --primary
            dark:  OKLCH(0.65, 0.20, 264))

ContentView().shadTheme(brand)
```

A `ShadThemeSet` holds a light palette, a dark palette, and the shape, type and
motion decisions shared between them. The `.shadTheme(_:)` modifier resolves it
against the ambient colour scheme and hands the flattened `ShadTheme` down the
environment. Components read it from there; none of them names a colour.

Nine presets ship built in — `neutral` (the default), `zinc`, `slate`, `stone`,
`blue`, `green`, `rose`, `violet` and `orange` — and any of them can be
overridden token by token:

```swift
VStack { … }
    .shadTheme { theme in
        theme.radius = ShadRadius(base: 0)       // square corners here only
        theme.colors.primary = .accentColor
        theme.colors.bubbleSent = .accentColor   // conversation colours are separate
        theme.shadows = .none
        theme.motion = .none
    }
```

## Notes on the macOS implementation

A few places where a faithful port needed native machinery rather than a direct
translation of the web component:

- **Popovers are real windows.** `ShadSelect`, `ShadCombobox` and
  `ShadDropdownMenu` present their panels in a borderless, non-activating
  `NSPanel` added as a child of the app's window. That is what lets a menu
  escape a `ScrollView`'s bounds and extend past the edge of the window, without
  the arrow and chrome `NSPopover` would impose.
- **Dialogs and toasts are overlays.** Attach `.shadDialog(isPresented:)` and
  `.shadToaster(_:)` to the root of a window so the scrim and the toast stack
  cover everything below.
- **Static rendering.** `ImageRenderer` cannot lay out a `ScrollView`, cannot
  materialise a `LazyVStack`, and draws AppKit-backed views — `TextField`,
  `TextEditor`, `NSViewRepresentable` — as placeholder blocks. Setting
  `.shadStaticRendering()` makes the library substitute plain stacks and plain
  text so a component snapshots exactly as it looks on screen. The documentation
  images are produced this way.
- **Keyboard.** Select and Combobox panels handle ↑ ↓ Home End Return and Escape.
  Dropdown menus handle Escape and the pointer; their content is free-form, so
  there is no ordered list to walk.
- **Fonts in a hand-assembled app.** `Scripts/build-app.sh` copies SwiftPM's
  resource bundle into the `.app`. If a host forgets to, ShadSwift falls back to
  the system font instead of trapping.

## Requirements

- macOS 14 or later
- Swift 6 toolchain (a full Xcode install — the SwiftUI macros `@State` and
  friends expand to cannot be resolved by Command Line Tools alone)

## Licence notes

Geist and Geist Mono (`Sources/ShadSwift/Resources/Fonts`) are © Vercel, used
under the SIL Open Font License 1.1.

The icon geometry in `Sources/ShadSwift/Support/LucideIcons.swift` is generated
from [Lucide](https://lucide.dev), which is ISC licensed.

## Layout

```
Sources/
  ShadSwift/         the library
    Theme/           OKLCH, tokens, ShadThemeSet, environment, Geist
    Resources/Fonts/ Geist + Geist Mono
    Support/         shapes, icons, popover host, static rendering
    Components/      one file per component
  ShadSwiftDemo/     the macOS gallery app
  ShadSwiftDocs/     the documentation generator
Skill/shadswift/     the Claude Code skill: SKILL.md + reference/
Docs/                generated HTML + snapshots (git-ignored)
Scripts/             build-app.sh, generate-docs.sh, release.sh,
                     update-consumers.sh, install-skill.sh
```

## Skipped on purpose

The RTL variants documented on the shadcn site are not implemented; macOS
layout direction is handled by SwiftUI's own `layoutDirection` environment
value rather than per-component classes.
