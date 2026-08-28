import SwiftUI

// MARK: - Radius

/// The radius scale. Every value is derived from a single `base`, exactly like
/// shadcn's `--radius` variable and its `calc()`-derived companions.
public struct ShadRadius: Sendable, Hashable {
    /// The `--radius` value. Defaults to `10` (shadcn's `0.625rem`).
    public var base: CGFloat

    public init(base: CGFloat = 10) { self.base = base }

    /// `calc(var(--radius) - 4px)`
    public var sm: CGFloat { max(0, base - 4) }
    /// `calc(var(--radius) - 2px)`
    public var md: CGFloat { max(0, base - 2) }
    /// `var(--radius)`
    public var lg: CGFloat { base }
    /// `calc(var(--radius) + 4px)`
    public var xl: CGFloat { base + 4 }
    /// `calc(var(--radius) + 8px)`
    public var xxl: CGFloat { base + 8 }
    /// A pill / circle.
    public var full: CGFloat { 9999 }
    /// The small inner radius used by menu rows and tab triggers.
    public var xs: CGFloat { max(0, base - 6) }
    /// The generous radius chat bubbles use — shadcn's `rounded-3xl`, which
    /// lands at 22pt against the default 10pt base.
    public var bubble: CGFloat { base * 2.2 }

    /// Perfectly square corners.
    public static let none = ShadRadius(base: 0)
    /// The shadcn default.
    public static let `default` = ShadRadius(base: 10)
    /// A tighter, more "system" feel.
    public static let small = ShadRadius(base: 6)
    /// Softer, rounder corners.
    public static let large = ShadRadius(base: 16)
}

// MARK: - Spacing

/// The 4pt spacing scale shared by all components.
public struct ShadSpacing: Sendable, Hashable {
    /// One spacing unit. Tailwind's `1` = 4px.
    public var unit: CGFloat

    public init(unit: CGFloat = 4) { self.unit = unit }

    /// `n` spacing units, e.g. `spacing(1.5)` is Tailwind's `gap-1.5`.
    public func callAsFunction(_ n: CGFloat) -> CGFloat { unit * n }

    public var xs: CGFloat { unit * 1 }      // 4
    public var sm: CGFloat { unit * 1.5 }    // 6
    public var md: CGFloat { unit * 2 }      // 8
    public var lg: CGFloat { unit * 3 }      // 12
    public var xl: CGFloat { unit * 4 }      // 16
    public var xxl: CGFloat { unit * 6 }     // 24
}

// MARK: - Typography

/// Font sizes, weights and family used across the library.
///
/// The defaults are the shadcn/ui documentation's own: Geist at 12 / 14 / 16 /
/// 18 / 20 / 24pt. Geist ships with the package, so nothing has to be installed.
public struct ShadTypography: Sendable {
    /// The sans family. `nil` uses the system font.
    public var fontName: String?
    /// The monospaced family, used by code and shortcut hints.
    public var monoFontName: String?
    /// The design applied to the system font when `fontName` is `nil`.
    public var design: Font.Design

    /// `text-xs`
    public var xs: CGFloat
    /// `text-sm` — the size almost every control uses.
    public var sm: CGFloat
    /// `text-base`
    public var base: CGFloat
    /// `text-lg`
    public var lg: CGFloat
    /// `text-xl`
    public var xl: CGFloat
    /// `text-2xl`
    public var xxl: CGFloat

    /// Weight used for labels, buttons and titles.
    public var medium: Font.Weight
    /// Weight used for headings.
    public var semibold: Font.Weight
    /// Weight used for body copy.
    public var regular: Font.Weight

    /// Extra tracking applied to small uppercase labels.
    public var labelTracking: CGFloat

    public init(
        fontName: String? = ShadFonts.sans,
        monoFontName: String? = ShadFonts.mono,
        design: Font.Design = .default,
        xs: CGFloat = 12,
        sm: CGFloat = 14,
        base: CGFloat = 16,
        lg: CGFloat = 18,
        xl: CGFloat = 20,
        xxl: CGFloat = 24,
        medium: Font.Weight = .medium,
        semibold: Font.Weight = .semibold,
        regular: Font.Weight = .regular,
        labelTracking: CGFloat = 0
    ) {
        self.fontName = fontName
        self.monoFontName = monoFontName
        self.design = design
        self.xs = xs
        self.sm = sm
        self.base = base
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.medium = medium
        self.semibold = semibold
        self.regular = regular
        self.labelTracking = labelTracking
    }

    /// The system font, for apps that would rather not ship a typeface.
    public static let system = ShadTypography(fontName: nil, monoFontName: nil)

    /// Builds a font at an explicit point size and weight, honouring `fontName`.
    ///
    /// The exact face is named rather than asking SwiftUI to apply a weight to
    /// a family — given a family, SwiftUI will happily synthesise a heavier
    /// face, which is why Geist looked a step bolder than it does on the web.
    public func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if let fontName {
            ShadFonts.registerBundledFonts()
            if let face = ShadFonts.faceName(family: fontName, weight: weight) {
                return .custom(face, fixedSize: size)
            }
            return .custom(fontName, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: design)
    }

    /// Builds a monospaced font at an explicit point size and weight.
    public func monoFont(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if let monoFontName {
            ShadFonts.registerBundledFonts()
            if let face = ShadFonts.faceName(family: monoFontName, weight: weight) {
                return .custom(face, fixedSize: size)
            }
            return .custom(monoFontName, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Shadows

/// A drop shadow, which may stack several layers the way a CSS `box-shadow`
/// list does. Layering is what keeps shadcn's elevations soft rather than
/// muddy — a single SwiftUI shadow cannot reproduce them.
public struct ShadShadow: Sendable, Hashable {
    /// One `box-shadow` entry.
    public struct Layer: Sendable, Hashable {
        public var color: Color
        /// SwiftUI blur radius — roughly half the CSS blur.
        public var radius: CGFloat
        public var x: CGFloat
        public var y: CGFloat

        public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }

    public var layers: [Layer]

    public init(layers: [Layer]) { self.layers = layers }

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.layers = [Layer(color: color, radius: radius, x: x, y: y)]
    }

    /// No shadow at all.
    public static let none = ShadShadow(layers: [])

    public var isEmpty: Bool { layers.isEmpty }
}

/// The elevation scale.
///
/// Measured from shadcn/ui: controls carry no shadow at all, cards use
/// `shadow-sm`, and only dialogs and toasts are meaningfully elevated.
public struct ShadShadows: Sendable, Hashable {
    /// Reserved for the rare control that needs a hairline lift (a switch thumb).
    public var xs: ShadShadow
    /// Cards.
    public var sm: ShadShadow
    /// Popovers and menus.
    public var md: ShadShadow
    /// Dialogs and toasts.
    public var lg: ShadShadow

    public init(xs: ShadShadow, sm: ShadShadow, md: ShadShadow, lg: ShadShadow) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
    }

    public static let light = ShadShadows(
        xs: ShadShadow(color: .black.opacity(0.10), radius: 1, y: 0.5),
        sm: ShadShadow(layers: [
            .init(color: .black.opacity(0.08), radius: 1.5, y: 1),
            .init(color: .black.opacity(0.06), radius: 1, y: 1),
        ]),
        // Tailwind's shadow-md: 0 4px 6px -1px rgb(0 0 0/.1),
        //                       0 2px 4px -2px rgb(0 0 0/.1).
        // Both layers carry a negative spread, which pulls the shadow in
        // tighter than a plain blur; SwiftUI has no spread, so the opacity is
        // dialled back instead of the radius.
        md: ShadShadow(layers: [
            .init(color: .black.opacity(0.07), radius: 3, y: 3),
            .init(color: .black.opacity(0.05), radius: 1.5, y: 1),
        ]),
        lg: ShadShadow(layers: [
            .init(color: .black.opacity(0.10), radius: 12, y: 8),
            .init(color: .black.opacity(0.06), radius: 3, y: 2),
        ])
    )

    public static let dark = ShadShadows(
        xs: ShadShadow(color: .black.opacity(0.35), radius: 1, y: 0.5),
        sm: ShadShadow(layers: [
            .init(color: .black.opacity(0.35), radius: 2, y: 1),
        ]),
        md: ShadShadow(layers: [
            .init(color: .black.opacity(0.35), radius: 5, y: 3),
            .init(color: .black.opacity(0.22), radius: 2, y: 1),
        ]),
        lg: ShadShadow(layers: [
            .init(color: .black.opacity(0.55), radius: 14, y: 8),
            .init(color: .black.opacity(0.35), radius: 4, y: 2),
        ])
    )

    /// Disables every shadow in the library.
    public static let none = ShadShadows(xs: .none, sm: .none, md: .none, lg: .none)
}

// MARK: - Motion

/// Animation timings used for hover, press and presentation transitions.
public struct ShadMotion: Sendable {
    /// Hover / press colour changes.
    public var interaction: Animation?
    /// Popovers, dialogs, toasts.
    public var presentation: Animation?
    /// Indeterminate spinners and shimmer effects.
    public var loop: Animation?
    /// Set to `false` to remove all ShadSwift animation.
    public var isEnabled: Bool
    /// How far the app behind a modal dialog is blurred. Zero disables it.
    public var dialogBackdropBlur: CGFloat

    public init(
        interaction: Animation? = .easeOut(duration: 0.12),
        presentation: Animation? = .spring(response: 0.28, dampingFraction: 0.86),
        loop: Animation? = .linear(duration: 0.9).repeatForever(autoreverses: false),
        isEnabled: Bool = true,
        dialogBackdropBlur: CGFloat = 7
    ) {
        self.interaction = interaction
        self.presentation = presentation
        self.loop = loop
        self.isEnabled = isEnabled
        self.dialogBackdropBlur = dialogBackdropBlur
    }

    public static let `default` = ShadMotion()
    public static let none = ShadMotion(interaction: nil, presentation: nil, loop: nil, isEnabled: false)
}

// MARK: - Focus ring

/// How the keyboard focus ring is drawn.
public struct ShadFocusRing: Sendable, Hashable {
    public var width: CGFloat
    public var opacity: Double
    /// Extra inset/outset applied to the ring relative to the control's edge.
    public var offset: CGFloat

    public init(width: CGFloat = 3, opacity: Double = 0.5, offset: CGFloat = 0) {
        self.width = width
        self.opacity = opacity
        self.offset = offset
    }

    public static let `default` = ShadFocusRing()
}

// MARK: - Theme

/// Every design decision the library makes, in one value.
///
/// Inject it once at the root of your app and every ShadSwift component below
/// picks it up:
///
/// ```swift
/// WindowGroup {
///     ContentView()
///         .shadTheme(.default)
/// }
/// ```
public struct ShadTheme: Sendable {
    public var colors: ShadColors
    public var radius: ShadRadius
    public var spacing: ShadSpacing
    public var typography: ShadTypography
    public var shadows: ShadShadows
    public var motion: ShadMotion
    public var focusRing: ShadFocusRing
    /// The hairline width used for every border in the library.
    public var borderWidth: CGFloat
    /// The color scheme this theme was resolved for.
    public var colorScheme: ColorScheme

    public init(
        colors: ShadColors = .light,
        radius: ShadRadius = .default,
        spacing: ShadSpacing = ShadSpacing(),
        typography: ShadTypography = ShadTypography(),
        shadows: ShadShadows = .light,
        motion: ShadMotion = .default,
        focusRing: ShadFocusRing = .default,
        borderWidth: CGFloat = 1,
        colorScheme: ColorScheme = .light
    ) {
        self.colors = colors
        self.radius = radius
        self.spacing = spacing
        self.typography = typography
        self.shadows = shadows
        self.motion = motion
        self.focusRing = focusRing
        self.borderWidth = borderWidth
        self.colorScheme = colorScheme
    }

    // MARK: Convenience

    /// `interaction` animation, or `nil` when motion is disabled.
    public var interactionAnimation: Animation? { motion.isEnabled ? motion.interaction : nil }
    /// `presentation` animation, or `nil` when motion is disabled.
    public var presentationAnimation: Animation? { motion.isEnabled ? motion.presentation : nil }

    public func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        typography.font(size, weight)
    }

    public func monoFont(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        typography.monoFont(size, weight)
    }
}
