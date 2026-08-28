# ShadSwift theming

One value drives every colour, corner radius, type size, shadow and animation in
the library. No component names a colour; they all read
`@Environment(\.shadTheme)`.

## The two types

**`ShadThemeSet`** — a light palette, a dark palette, and the shape/type/motion
decisions shared between them. This is what you author.

**`ShadTheme`** — one `ShadThemeSet` already resolved for a single colour scheme.
This is what components read.

`.shadTheme(_ set: ShadThemeSet)` does the resolving. **Apply it at the root or
dark mode will not work** — the environment's default value is a `ShadTheme()`
hard-coded to the light palette, so an unmodified hierarchy renders light forever.

```swift
WindowGroup {
    ContentView().shadTheme(.default)
}
```

## The three modifiers

```swift
.shadTheme(_ set: ShadThemeSet, colorScheme: ColorScheme? = nil)  // resolve + inject
.shadTheme(_ theme: ShadTheme)                                    // inject an already-resolved theme
.shadTheme { (theme: inout ShadTheme) in … }                      // mutate the inherited theme
```

The closure form is for local overrides — a squarer card, a flatter section:

```swift
VStack { … }
    .shadTheme { theme in
        theme.radius = ShadRadius(base: 0)
        theme.colors.primary = .accentColor
        theme.shadows = .none
        theme.motion = .none
    }
```

Pass `colorScheme:` to pin a subtree — that is how the docs generator renders the
same view light and dark side by side.

## Presets

Nine, all `ShadThemeSet` statics:

```
.default (neutral) · .zinc · .slate · .stone · .blue · .green · .rose · .violet · .orange
```

`ShadThemeSet.presets` is the `[(name: String, theme: ShadThemeSet)]` list, useful
for a theme picker. `ShadThemeSet.neutralRamp(chroma:hue:)` builds a new
shadcn-shaped neutral ramp.

## Building on a preset

Every builder returns a new `ShadThemeSet`, so they chain:

```swift
let brand = ShadThemeSet.slate
    .radius(4)                                   // --radius, in points
    .fontName("Geist")                           // nil for the system face
    .borderWidth(1)
    .tinted(light: OKLCH(0.55, 0.20, 264),       // --primary, both schemes
            dark:  OKLCH(0.65, 0.20, 264))
    .typography(.system)                         // opt out of Geist entirely
    .shadows(.none)
    .motion(.none)
    .bubbles(sent: .blue, sentForeground: .white,
             received: Color(nsColor: .controlColor), receivedForeground: .primary)
    .colors { colors, scheme in                  // per-scheme escape hatch
        colors.ring = scheme == .dark ? .white : .black
    }
```

`.tinted(light:dark:)` moves `primary`, `ring`, `sidebarPrimary` and the related
tokens together, leaving the neutral surfaces alone — it is the one-line way to
brand an app.

## OKLCH

Colours are authored in the same notation shadcn uses in `globals.css` and
converted to sRGB at build time, so a palette copied off the web translates
almost verbatim.

```swift
OKLCH(_ l: Double, _ c: Double, _ h: Double, alpha: Double = 1)   // 0.55, 0.20, 264
OKLCH(hex: "#3b82f6")
```

Helpers on `Color`:

```swift
color.shadMix(with: .black, amount: 0.2)
color.shadLightness { $0 * 0.8 }        // transform OKLCH lightness in place
```

## Colour tokens

`theme.colors` is a `ShadColors`. Same names as shadcn's CSS variables:

| Group | Tokens |
| --- | --- |
| Surfaces | `background` `foreground` `card` `cardForeground` `popover` `popoverForeground` |
| Brand | `primary` `primaryForeground` `secondary` `secondaryForeground` |
| Neutrals | `muted` `mutedForeground` `accent` `accentForeground` |
| Status | `destructive` `success` `warning` `info` + a `…Foreground` for each |
| Chrome | `border` `input` `ring` `overlay` |
| Conversation | `bubbleSent` `bubbleSentForeground` `bubbleReceived` `bubbleReceivedForeground` |
| Sidebar | `sidebar` `sidebarForeground` `sidebarPrimary` `sidebarPrimaryForeground` `sidebarAccent` `sidebarAccentForeground` `sidebarBorder` `sidebarRing` |

`ShadColors.light` and `.dark` are the shadcn neutral defaults.

**Bubble tokens are deliberately independent of `primary`** so a brand colour
change does not recolour a conversation. Set them with `.bubbles(…)`.

## The rest of the theme

```swift
theme.radius        // ShadRadius(base: 10) → .sm .md .lg .xl .xxl .full
                    //   sm = base-4, md = base-2, lg = base, xl = base+4, xxl = base+8
theme.spacing       // ShadSpacing(unit: 4) → .xs 4 .sm 6 .md 8 .lg 12 .xl 16 .xxl 24
                    //   callable: theme.spacing(1.5) == Tailwind gap-1.5
theme.typography    // fontName, monoFontName, design, labelTracking
                    //   sizes  (CGFloat): .xs 12 .sm 14 .base 16 .lg 18 .xl 20 .xxl 24
                    //   weights (Font.Weight): .regular .medium .semibold
                    //   ShadTypography.system opts out of Geist
theme.shadows       // ShadShadows → .xs .sm .md .lg   (statics: .light .dark .none)
                    //   each a ShadShadow(layers:) — two-layer, cast by the background shape
theme.motion        // interaction, presentation, loop, isEnabled, dialogBackdropBlur
theme.focusRing     // width (3), opacity (0.5), offset — drawn in colors.ring
theme.borderWidth   // 1
theme.colorScheme   // which scheme this was resolved for
```

**Building a font.** `theme.typography` holds *sizes* (`CGFloat`) and *weights*
(`Font.Weight`) separately — neither is a `Font`. Combine them with
`theme.font(_:_:)`:

```swift
.font(theme.font(theme.typography.sm, theme.typography.medium))
```

It names the exact face (`Geist-Medium`) rather than asking SwiftUI to apply a
weight to a family, which is what made Geist render a step bolder than the web.
`ShadTypography.system` is the only preset — it drops Geist for the system face.

Convenience: `theme.interactionAnimation` and `theme.presentationAnimation`
return `nil` when motion is disabled, so they are safe to pass straight to
`withAnimation`.

## Reading the theme

```swift
struct Total: View {
    @Environment(\.shadTheme) private var theme

    var body: some View {
        Text("Total")
            .font(theme.font(theme.typography.sm, theme.typography.medium))
            .foregroundStyle(theme.colors.mutedForeground)
            .padding(theme.spacing.lg)
            .background(theme.colors.card, in: ShadRoundedRectangle(cornerRadius: theme.radius.lg))
    }
}
```

Never hard-code a hex, a point size or a corner radius in app code. If a value
you need is missing from the theme, add a token to the library rather than
inlining it — that is the whole point of the single theme value.
