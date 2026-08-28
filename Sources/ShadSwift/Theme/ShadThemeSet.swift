import SwiftUI

/// A light/dark pair of palettes plus the shape, type and motion decisions that
/// are shared between them.
///
/// This is what you normally hand to ``SwiftUI/View/shadTheme(_:)``: the
/// modifier reads the ambient `colorScheme` and resolves it down to a concrete
/// ``ShadTheme`` for the views below.
public struct ShadThemeSet: Sendable {
    public var light: ShadColors
    public var dark: ShadColors
    public var lightShadows: ShadShadows
    public var darkShadows: ShadShadows

    public var radius: ShadRadius
    public var spacing: ShadSpacing
    public var typography: ShadTypography
    public var motion: ShadMotion
    public var focusRing: ShadFocusRing
    public var borderWidth: CGFloat

    public init(
        light: ShadColors = .light,
        dark: ShadColors = .dark,
        lightShadows: ShadShadows = .light,
        darkShadows: ShadShadows = .dark,
        radius: ShadRadius = .default,
        spacing: ShadSpacing = ShadSpacing(),
        typography: ShadTypography = ShadTypography(),
        motion: ShadMotion = .default,
        focusRing: ShadFocusRing = .default,
        borderWidth: CGFloat = 1
    ) {
        self.light = light
        self.dark = dark
        self.lightShadows = lightShadows
        self.darkShadows = darkShadows
        self.radius = radius
        self.spacing = spacing
        self.typography = typography
        self.motion = motion
        self.focusRing = focusRing
        self.borderWidth = borderWidth
    }

    /// Flattens the set for one color scheme.
    public func resolved(for scheme: ColorScheme) -> ShadTheme {
        ShadTheme(
            colors: scheme == .dark ? dark : light,
            radius: radius,
            spacing: spacing,
            typography: typography,
            shadows: scheme == .dark ? darkShadows : lightShadows,
            motion: motion,
            focusRing: focusRing,
            borderWidth: borderWidth,
            colorScheme: scheme
        )
    }

    // MARK: Builder-style customisation

    /// Returns a copy with a different corner radius scale.
    public func radius(_ radius: ShadRadius) -> ShadThemeSet {
        var copy = self; copy.radius = radius; return copy
    }

    /// Returns a copy with a different corner radius base, in points.
    public func radius(_ base: CGFloat) -> ShadThemeSet {
        var copy = self; copy.radius = ShadRadius(base: base); return copy
    }

    /// Returns a copy with different typography.
    public func typography(_ typography: ShadTypography) -> ShadThemeSet {
        var copy = self; copy.typography = typography; return copy
    }

    /// Returns a copy using a named font family.
    public func fontName(_ name: String?) -> ShadThemeSet {
        var copy = self; copy.typography.fontName = name; return copy
    }

    /// Returns a copy with different motion settings.
    public func motion(_ motion: ShadMotion) -> ShadThemeSet {
        var copy = self; copy.motion = motion; return copy
    }

    /// Returns a copy with a different hairline width.
    public func borderWidth(_ width: CGFloat) -> ShadThemeSet {
        var copy = self; copy.borderWidth = width; return copy
    }

    /// Returns a copy with the shadow scale replaced in both schemes.
    public func shadows(_ shadows: ShadShadows) -> ShadThemeSet {
        var copy = self; copy.lightShadows = shadows; copy.darkShadows = shadows; return copy
    }

    /// Returns a copy after mutating both palettes.
    public func colors(_ transform: (inout ShadColors, ColorScheme) -> Void) -> ShadThemeSet {
        var copy = self
        transform(&copy.light, .light)
        transform(&copy.dark, .dark)
        return copy
    }

    /// Returns a copy with different chat bubble colours.
    ///
    /// Bubbles are deliberately independent of `primary`: a conversation reads
    /// better when the sent side keeps its own hue whatever the brand colour is.
    public func bubbles(
        sent: Color, sentForeground: Color,
        received: Color, receivedForeground: Color,
        darkSent: Color? = nil, darkSentForeground: Color? = nil,
        darkReceived: Color? = nil, darkReceivedForeground: Color? = nil
    ) -> ShadThemeSet {
        var copy = self
        copy.light.bubbleSent = sent
        copy.light.bubbleSentForeground = sentForeground
        copy.light.bubbleReceived = received
        copy.light.bubbleReceivedForeground = receivedForeground
        copy.dark.bubbleSent = darkSent ?? sent
        copy.dark.bubbleSentForeground = darkSentForeground ?? sentForeground
        copy.dark.bubbleReceived = darkReceived ?? received
        copy.dark.bubbleReceivedForeground = darkReceivedForeground ?? receivedForeground
        return copy
    }

    /// Returns a copy with a new brand color used for `primary`, `ring` and
    /// `sidebarPrimary`, keeping the neutral surfaces intact.
    public func tinted(light lightPrimary: OKLCH, dark darkPrimary: OKLCH) -> ShadThemeSet {
        var copy = self
        copy.light.primary = lightPrimary.color
        copy.light.primaryForeground = (lightPrimary.l > 0.62 ? OKLCH(0.205, 0, 0) : OKLCH(0.985, 0, 0)).color
        copy.light.ring = lightPrimary.opacity(0.6).color
        copy.light.sidebarPrimary = lightPrimary.color
        copy.light.sidebarRing = lightPrimary.opacity(0.6).color

        copy.dark.primary = darkPrimary.color
        copy.dark.primaryForeground = (darkPrimary.l > 0.62 ? OKLCH(0.205, 0, 0) : OKLCH(0.985, 0, 0)).color
        copy.dark.ring = darkPrimary.opacity(0.6).color
        copy.dark.sidebarPrimary = darkPrimary.color
        copy.dark.sidebarRing = darkPrimary.opacity(0.6).color
        return copy
    }
}

// MARK: - Presets

extension ShadThemeSet {
    /// shadcn/ui's default "neutral" base color.
    public static let `default` = ShadThemeSet()

    /// A cooler grey ramp with a hint of blue.
    public static let zinc = ShadThemeSet.neutralRamp(chroma: 0.006, hue: 286)

    /// A blue-leaning grey ramp.
    public static let slate = ShadThemeSet.neutralRamp(chroma: 0.013, hue: 258)

    /// A warm grey ramp.
    public static let stone = ShadThemeSet.neutralRamp(chroma: 0.005, hue: 60)

    /// Neutral surfaces with a blue brand color.
    public static let blue = ShadThemeSet.slate
        .tinted(light: OKLCH(0.546, 0.215, 262.881), dark: OKLCH(0.623, 0.214, 259.815))

    /// Neutral surfaces with a green brand color.
    public static let green = ShadThemeSet.default
        .tinted(light: OKLCH(0.596, 0.145, 163.225), dark: OKLCH(0.696, 0.17, 162.48))

    /// Neutral surfaces with a rose brand color.
    public static let rose = ShadThemeSet.default
        .tinted(light: OKLCH(0.586, 0.253, 17.585), dark: OKLCH(0.645, 0.246, 16.439))

    /// Neutral surfaces with a violet brand color.
    public static let violet = ShadThemeSet.default
        .tinted(light: OKLCH(0.541, 0.281, 293.009), dark: OKLCH(0.627, 0.265, 303.9))

    /// Neutral surfaces with an orange brand color.
    public static let orange = ShadThemeSet.default
        .tinted(light: OKLCH(0.646, 0.222, 41.116), dark: OKLCH(0.705, 0.213, 47.604))

    /// Builds a shadcn-shaped palette where every neutral step carries the same
    /// hue and chroma. This is how the `zinc`, `slate` and `stone` base colors
    /// differ from `neutral`.
    public static func neutralRamp(chroma: Double, hue: Double) -> ShadThemeSet {
        func tint(_ l: Double, _ alpha: Double = 1) -> Color {
            OKLCH(l, chroma, hue, alpha: alpha).color
        }
        var light = ShadColors.light
        light.background = tint(1)
        light.foreground = tint(0.141)
        light.card = tint(1)
        light.cardForeground = tint(0.141)
        light.popover = tint(1)
        light.popoverForeground = tint(0.141)
        light.primary = tint(0.21)
        light.primaryForeground = tint(0.985)
        light.secondary = tint(0.967)
        light.secondaryForeground = tint(0.21)
        light.muted = tint(0.967)
        light.mutedForeground = tint(0.552)
        light.accent = tint(0.967)
        light.accentForeground = tint(0.21)
        light.border = tint(0.929)
        light.input = tint(0.929)
        light.ring = tint(0.704)
        light.sidebar = tint(0.985)
        light.sidebarForeground = tint(0.141)
        light.sidebarPrimary = tint(0.21)
        light.sidebarPrimaryForeground = tint(0.985)
        light.sidebarAccent = tint(0.967)
        light.sidebarAccentForeground = tint(0.21)
        light.sidebarBorder = tint(0.929)
        light.sidebarRing = tint(0.704)
        light.bubbleReceived = tint(0.955)
        light.bubbleReceivedForeground = tint(0.141)

        var dark = ShadColors.dark
        dark.background = tint(0.141)
        dark.foreground = tint(0.985)
        dark.card = tint(0.21)
        dark.cardForeground = tint(0.985)
        dark.popover = tint(0.21)
        dark.popoverForeground = tint(0.985)
        dark.primary = tint(0.92)
        dark.primaryForeground = tint(0.21)
        dark.secondary = tint(0.274)
        dark.secondaryForeground = tint(0.985)
        dark.muted = tint(0.274)
        dark.mutedForeground = tint(0.705)
        dark.accent = tint(0.274)
        dark.accentForeground = tint(0.985)
        dark.border = Color(oklch: 1, 0, 0, alpha: 0.10)
        dark.input = Color(oklch: 1, 0, 0, alpha: 0.15)
        dark.ring = tint(0.551)
        dark.sidebar = tint(0.21)
        dark.sidebarForeground = tint(0.985)
        dark.sidebarPrimary = tint(0.92)
        dark.sidebarPrimaryForeground = tint(0.21)
        dark.sidebarAccent = tint(0.274)
        dark.sidebarAccentForeground = tint(0.985)
        dark.sidebarBorder = Color(oklch: 1, 0, 0, alpha: 0.10)
        dark.sidebarRing = tint(0.551)
        dark.bubbleReceived = tint(0.290)
        dark.bubbleReceivedForeground = tint(0.985)

        return ShadThemeSet(light: light, dark: dark)
    }

    /// Every built-in preset, keyed by name. Handy for theme pickers.
    public static let presets: [(name: String, theme: ShadThemeSet)] = [
        ("neutral", .default),
        ("zinc", .zinc),
        ("slate", .slate),
        ("stone", .stone),
        ("blue", .blue),
        ("green", .green),
        ("rose", .rose),
        ("violet", .violet),
        ("orange", .orange),
    ]
}
