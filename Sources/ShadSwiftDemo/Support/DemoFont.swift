import SwiftUI
import ShadSwift

/// Bundled and system faces that are available on both demo platforms.
enum DemoFont: String, CaseIterable {
    case geist = "Geist"
    case system = "System"
    case rounded = "Rounded"
    case serif = "Serif"
    case monospaced = "Monospaced"

    var typography: ShadTypography {
        switch self {
        case .geist: return ShadTypography()
        case .system: return ShadTypography(fontName: nil)
        case .rounded: return ShadTypography(fontName: nil, design: .rounded)
        case .serif: return ShadTypography(fontName: nil, design: .serif)
        case .monospaced: return ShadTypography(fontName: nil, design: .monospaced)
        }
    }
}

struct DemoFontPicker: View {
    @Binding var selection: DemoFont

    var body: some View {
        ShadSelect(
            selection: Binding(
                get: { Optional(selection) },
                set: { selection = $0 ?? .geist }
            ),
            options: DemoFont.allCases.map { ShadSelectOption($0.rawValue, value: $0) }
        )
    }
}

/// Keeps explicitly sized demo copy in the selected theme's font family.
private struct DemoFontModifier: ViewModifier {
    @Environment(\.shadTheme) private var theme
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(theme.font(size, weight))
    }
}

extension View {
    func demoFont(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(DemoFontModifier(size: size, weight: weight))
    }
}
