import Foundation
import SwiftUI

/// A color expressed in the OKLCH color space, the same notation used by the
/// shadcn/ui CSS theme variables (`oklch(0.646 0.222 41.116)`).
///
/// Authoring colors in OKLCH means a theme copied from a shadcn `globals.css`
/// can be pasted into Swift essentially verbatim.
public struct OKLCH: Hashable, Sendable {
    /// Perceptual lightness, `0...1`.
    public var l: Double
    /// Chroma, typically `0...0.4`.
    public var c: Double
    /// Hue angle in degrees, `0...360`.
    public var h: Double
    /// Alpha, `0...1`.
    public var alpha: Double

    public init(_ l: Double, _ c: Double, _ h: Double, alpha: Double = 1) {
        self.l = l
        self.c = c
        self.h = h
        self.alpha = alpha
    }

    /// Returns a copy with a different alpha, mirroring CSS' `oklch(... / 10%)`.
    public func opacity(_ alpha: Double) -> OKLCH {
        OKLCH(l, c, h, alpha: self.alpha * alpha)
    }

    /// Returns a copy with the lightness replaced.
    public func lightness(_ l: Double) -> OKLCH { OKLCH(l, c, h, alpha: alpha) }

    /// Returns a copy with the chroma replaced.
    public func chroma(_ c: Double) -> OKLCH { OKLCH(l, c, h, alpha: alpha) }

    /// Gamma-encoded sRGB components in `0...1`.
    public var sRGB: (red: Double, green: Double, blue: Double) {
        let hueRadians = h * .pi / 180
        let a = c * cos(hueRadians)
        let b = c * sin(hueRadians)

        // OkLab -> LMS (cube roots)
        let lRoot = l + 0.3963377774 * a + 0.2158037573 * b
        let mRoot = l - 0.1055613458 * a - 0.0638541728 * b
        let sRoot = l - 0.0894841775 * a - 1.2914855480 * b

        let lms0 = lRoot * lRoot * lRoot
        let lms1 = mRoot * mRoot * mRoot
        let lms2 = sRoot * sRoot * sRoot

        // LMS -> linear sRGB
        let linearR = 4.0767416621 * lms0 - 3.3077115913 * lms1 + 0.2309699292 * lms2
        let linearG = -1.2684380046 * lms0 + 2.6097574011 * lms1 - 0.3413193965 * lms2
        let linearB = -0.0041960863 * lms0 - 0.7034186147 * lms1 + 1.7076147010 * lms2

        return (Self.encodeGamma(linearR), Self.encodeGamma(linearG), Self.encodeGamma(linearB))
    }

    private static func encodeGamma(_ value: Double) -> Double {
        let clamped = min(max(value, 0), 1)
        let encoded = clamped <= 0.0031308
            ? clamped * 12.92
            : 1.055 * pow(clamped, 1 / 2.4) - 0.055
        return min(max(encoded, 0), 1)
    }

    /// The equivalent SwiftUI color.
    public var color: Color {
        let rgb = sRGB
        return Color(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: alpha)
    }

    /// A `#rrggbb` string, useful for exporting a theme to CSS or documentation.
    public var hexString: String {
        let rgb = sRGB
        let r = Int((rgb.red * 255).rounded())
        let g = Int((rgb.green * 255).rounded())
        let b = Int((rgb.blue * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// Parses `#rgb`, `#rrggbb` or `#rrggbbaa` into OKLCH.
    public init(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        if text.count == 3 { text = text.map { "\($0)\($0)" }.joined() }
        var value: UInt64 = 0
        Scanner(string: text).scanHexInt64(&value)
        let hasAlpha = text.count == 8
        let r = Double((value >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let g = Double((value >> (hasAlpha ? 16 : 8)) & 0xFF) / 255
        let b = Double((value >> (hasAlpha ? 8 : 0)) & 0xFF) / 255
        let a = hasAlpha ? Double(value & 0xFF) / 255 : 1
        self = OKLCH(sRGBRed: r, green: g, blue: b, alpha: a)
    }

    /// Converts gamma-encoded sRGB components into OKLCH.
    public init(sRGBRed r: Double, green g: Double, blue b: Double, alpha: Double = 1) {
        func linearize(_ value: Double) -> Double {
            value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        let lr = linearize(r), lg = linearize(g), lb = linearize(b)

        let l = cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb)
        let m = cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb)
        let s = cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb)

        let okL = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
        let okA = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
        let okB = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s

        let chroma = sqrt(okA * okA + okB * okB)
        var hue = atan2(okB, okA) * 180 / .pi
        if hue < 0 { hue += 360 }
        self.init(okL, chroma, hue, alpha: alpha)
    }
}

extension Color {
    /// Builds a SwiftUI color from OKLCH components.
    public init(oklch l: Double, _ c: Double, _ h: Double, alpha: Double = 1) {
        self = OKLCH(l, c, h, alpha: alpha).color
    }
}

// MARK: - Mixing

import AppKit

extension Color {
    /// The colour's gamma-encoded sRGB components, or `nil` when it cannot be
    /// resolved (a dynamic system colour outside a drawing context, say).
    public var shadRGBA: (red: Double, green: Double, blue: Double, alpha: Double)? {
        guard let converted = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        return (Double(converted.redComponent),
                Double(converted.greenComponent),
                Double(converted.blueComponent),
                Double(converted.alphaComponent))
    }

    /// Mixes this colour with another in the OkLab space — the Swift equivalent
    /// of CSS `color-mix(in oklch, self, other amount%)`.
    ///
    /// shadcn uses this for hover states that need to stay perceptually even
    /// across light and dark palettes.
    public func shadMix(with other: Color, amount: Double) -> Color {
        guard let a = shadRGBA, let b = other.shadRGBA else { return self }
        let first = OKLCH(sRGBRed: a.red, green: a.green, blue: a.blue, alpha: a.alpha)
        let second = OKLCH(sRGBRed: b.red, green: b.green, blue: b.blue, alpha: b.alpha)

        // Interpolate in OkLab so hue wrap-around cannot produce a detour
        // through an unrelated hue.
        func lab(_ value: OKLCH) -> (Double, Double, Double) {
            let radians = value.h * .pi / 180
            return (value.l, value.c * cos(radians), value.c * sin(radians))
        }
        let (l1, a1, b1) = lab(first)
        let (l2, a2, b2) = lab(second)
        let t = min(max(amount, 0), 1)

        let l = l1 + (l2 - l1) * t
        let aa = a1 + (a2 - a1) * t
        let bb = b1 + (b2 - b1) * t
        var hue = atan2(bb, aa) * 180 / .pi
        if hue < 0 { hue += 360 }
        let alpha = first.alpha + (second.alpha - first.alpha) * t

        return OKLCH(l, sqrt(aa * aa + bb * bb), hue, alpha: alpha).color
    }

    /// Returns the colour with its lightness nudged, staying in OkLab.
    public func shadLightness(_ transform: (Double) -> Double) -> Color {
        guard let rgba = shadRGBA else { return self }
        var value = OKLCH(sRGBRed: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        value.l = min(max(transform(value.l), 0), 1)
        return value.color
    }
}
