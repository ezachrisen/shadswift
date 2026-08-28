import SwiftUI

/// The full set of semantic color tokens used by every ShadSwift component.
///
/// The names map one-to-one onto the shadcn/ui CSS variables, so a palette
/// copied from a `globals.css` file translates directly:
///
/// ```swift
/// var colors = ShadColors.light
/// colors.primary = Color(oklch: 0.55, 0.2, 264)
/// colors.primaryForeground = Color(oklch: 0.985, 0, 0)
/// ```
public struct ShadColors: Sendable {
    // MARK: Surfaces
    public var background: Color
    public var foreground: Color
    public var card: Color
    public var cardForeground: Color
    public var popover: Color
    public var popoverForeground: Color

    // MARK: Intents
    public var primary: Color
    public var primaryForeground: Color
    public var secondary: Color
    public var secondaryForeground: Color
    public var muted: Color
    public var mutedForeground: Color
    public var accent: Color
    public var accentForeground: Color
    public var destructive: Color
    public var destructiveForeground: Color

    // MARK: Status (used by Toast and Marker)
    public var success: Color
    public var successForeground: Color
    public var warning: Color
    public var warningForeground: Color
    public var info: Color
    public var infoForeground: Color

    // MARK: Lines
    public var border: Color
    public var input: Color
    public var ring: Color

    // MARK: Charts
    public var chart1: Color
    public var chart2: Color
    public var chart3: Color
    public var chart4: Color
    public var chart5: Color

    // MARK: Conversation
    /// The bubble for messages the current user sent — the right-hand side.
    public var bubbleSent: Color
    public var bubbleSentForeground: Color
    /// The bubble for messages received — the left-hand side.
    public var bubbleReceived: Color
    public var bubbleReceivedForeground: Color

    // MARK: Sidebar
    public var sidebar: Color
    public var sidebarForeground: Color
    public var sidebarPrimary: Color
    public var sidebarPrimaryForeground: Color
    public var sidebarAccent: Color
    public var sidebarAccentForeground: Color
    public var sidebarBorder: Color
    public var sidebarRing: Color

    /// The scrim painted behind modal dialogs.
    public var overlay: Color

    public init(
        background: Color,
        foreground: Color,
        card: Color,
        cardForeground: Color,
        popover: Color,
        popoverForeground: Color,
        primary: Color,
        primaryForeground: Color,
        secondary: Color,
        secondaryForeground: Color,
        muted: Color,
        mutedForeground: Color,
        accent: Color,
        accentForeground: Color,
        destructive: Color,
        destructiveForeground: Color,
        success: Color,
        successForeground: Color,
        warning: Color,
        warningForeground: Color,
        info: Color,
        infoForeground: Color,
        border: Color,
        input: Color,
        ring: Color,
        chart1: Color,
        chart2: Color,
        chart3: Color,
        chart4: Color,
        chart5: Color,
        bubbleSent: Color,
        bubbleSentForeground: Color,
        bubbleReceived: Color,
        bubbleReceivedForeground: Color,
        sidebar: Color,
        sidebarForeground: Color,
        sidebarPrimary: Color,
        sidebarPrimaryForeground: Color,
        sidebarAccent: Color,
        sidebarAccentForeground: Color,
        sidebarBorder: Color,
        sidebarRing: Color,
        overlay: Color
    ) {
        self.background = background
        self.foreground = foreground
        self.card = card
        self.cardForeground = cardForeground
        self.popover = popover
        self.popoverForeground = popoverForeground
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.secondary = secondary
        self.secondaryForeground = secondaryForeground
        self.muted = muted
        self.mutedForeground = mutedForeground
        self.accent = accent
        self.accentForeground = accentForeground
        self.destructive = destructive
        self.destructiveForeground = destructiveForeground
        self.success = success
        self.successForeground = successForeground
        self.warning = warning
        self.warningForeground = warningForeground
        self.info = info
        self.infoForeground = infoForeground
        self.border = border
        self.input = input
        self.ring = ring
        self.chart1 = chart1
        self.chart2 = chart2
        self.chart3 = chart3
        self.chart4 = chart4
        self.chart5 = chart5
        self.bubbleSent = bubbleSent
        self.bubbleSentForeground = bubbleSentForeground
        self.bubbleReceived = bubbleReceived
        self.bubbleReceivedForeground = bubbleReceivedForeground
        self.sidebar = sidebar
        self.sidebarForeground = sidebarForeground
        self.sidebarPrimary = sidebarPrimary
        self.sidebarPrimaryForeground = sidebarPrimaryForeground
        self.sidebarAccent = sidebarAccent
        self.sidebarAccentForeground = sidebarAccentForeground
        self.sidebarBorder = sidebarBorder
        self.sidebarRing = sidebarRing
        self.overlay = overlay
    }
}

extension ShadColors {
    /// The default shadcn/ui light palette (the "neutral" base color).
    public static let light = ShadColors(
        background: Color(oklch: 1, 0, 0),
        foreground: Color(oklch: 0.145, 0, 0),
        card: Color(oklch: 1, 0, 0),
        cardForeground: Color(oklch: 0.145, 0, 0),
        popover: Color(oklch: 1, 0, 0),
        popoverForeground: Color(oklch: 0.145, 0, 0),
        primary: Color(oklch: 0.205, 0, 0),
        primaryForeground: Color(oklch: 0.985, 0, 0),
        secondary: Color(oklch: 0.97, 0, 0),
        secondaryForeground: Color(oklch: 0.205, 0, 0),
        muted: Color(oklch: 0.97, 0, 0),
        mutedForeground: Color(oklch: 0.556, 0, 0),
        accent: Color(oklch: 0.97, 0, 0),
        accentForeground: Color(oklch: 0.205, 0, 0),
        destructive: Color(oklch: 0.577, 0.245, 27.325),
        destructiveForeground: Color(oklch: 0.985, 0, 0),
        success: Color(oklch: 0.596, 0.145, 163.225),
        successForeground: Color(oklch: 0.985, 0, 0),
        warning: Color(oklch: 0.769, 0.188, 70.08),
        warningForeground: Color(oklch: 0.216, 0.04, 70.08),
        info: Color(oklch: 0.588, 0.158, 254.0),
        infoForeground: Color(oklch: 0.985, 0, 0),
        border: Color(oklch: 0.922, 0, 0),
        input: Color(oklch: 0.922, 0, 0),
        ring: Color(oklch: 0.708, 0, 0),
        chart1: Color(oklch: 0.646, 0.222, 41.116),
        chart2: Color(oklch: 0.6, 0.118, 184.704),
        chart3: Color(oklch: 0.398, 0.07, 227.392),
        chart4: Color(oklch: 0.828, 0.189, 84.429),
        chart5: Color(oklch: 0.769, 0.188, 70.08),
        bubbleSent: Color(oklch: 0.600, 0.196, 258.0),
        bubbleSentForeground: Color(oklch: 1, 0, 0),
        bubbleReceived: Color(oklch: 0.955, 0, 0),
        bubbleReceivedForeground: Color(oklch: 0.145, 0, 0),
        sidebar: Color(oklch: 0.985, 0, 0),
        sidebarForeground: Color(oklch: 0.145, 0, 0),
        sidebarPrimary: Color(oklch: 0.205, 0, 0),
        sidebarPrimaryForeground: Color(oklch: 0.985, 0, 0),
        sidebarAccent: Color(oklch: 0.97, 0, 0),
        sidebarAccentForeground: Color(oklch: 0.205, 0, 0),
        sidebarBorder: Color(oklch: 0.922, 0, 0),
        sidebarRing: Color(oklch: 0.708, 0, 0),
        overlay: Color.black.opacity(0.18)
    )

    /// The default shadcn/ui dark palette.
    public static let dark = ShadColors(
        background: Color(oklch: 0.145, 0, 0),
        foreground: Color(oklch: 0.985, 0, 0),
        card: Color(oklch: 0.205, 0, 0),
        cardForeground: Color(oklch: 0.985, 0, 0),
        popover: Color(oklch: 0.205, 0, 0),
        popoverForeground: Color(oklch: 0.985, 0, 0),
        primary: Color(oklch: 0.922, 0, 0),
        primaryForeground: Color(oklch: 0.205, 0, 0),
        secondary: Color(oklch: 0.269, 0, 0),
        secondaryForeground: Color(oklch: 0.985, 0, 0),
        muted: Color(oklch: 0.269, 0, 0),
        mutedForeground: Color(oklch: 0.708, 0, 0),
        accent: Color(oklch: 0.269, 0, 0),
        accentForeground: Color(oklch: 0.985, 0, 0),
        destructive: Color(oklch: 0.704, 0.191, 22.216),
        destructiveForeground: Color(oklch: 0.985, 0, 0),
        success: Color(oklch: 0.696, 0.17, 162.48),
        successForeground: Color(oklch: 0.205, 0, 0),
        warning: Color(oklch: 0.828, 0.189, 84.429),
        warningForeground: Color(oklch: 0.205, 0, 0),
        info: Color(oklch: 0.685, 0.169, 254.0),
        infoForeground: Color(oklch: 0.205, 0, 0),
        border: Color(oklch: 1, 0, 0, alpha: 0.10),
        input: Color(oklch: 1, 0, 0, alpha: 0.15),
        ring: Color(oklch: 0.556, 0, 0),
        chart1: Color(oklch: 0.488, 0.243, 264.376),
        chart2: Color(oklch: 0.696, 0.17, 162.48),
        chart3: Color(oklch: 0.769, 0.188, 70.08),
        chart4: Color(oklch: 0.627, 0.265, 303.9),
        chart5: Color(oklch: 0.645, 0.246, 16.439),
        bubbleSent: Color(oklch: 0.560, 0.200, 258.0),
        bubbleSentForeground: Color(oklch: 1, 0, 0),
        bubbleReceived: Color(oklch: 0.290, 0, 0),
        bubbleReceivedForeground: Color(oklch: 0.985, 0, 0),
        sidebar: Color(oklch: 0.205, 0, 0),
        sidebarForeground: Color(oklch: 0.985, 0, 0),
        sidebarPrimary: Color(oklch: 0.488, 0.243, 264.376),
        sidebarPrimaryForeground: Color(oklch: 0.985, 0, 0),
        sidebarAccent: Color(oklch: 0.269, 0, 0),
        sidebarAccentForeground: Color(oklch: 0.985, 0, 0),
        sidebarBorder: Color(oklch: 1, 0, 0, alpha: 0.10),
        sidebarRing: Color(oklch: 0.556, 0, 0),
        overlay: Color.black.opacity(0.35)
    )
}
