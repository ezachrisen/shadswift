import SwiftUI

/// A rounded rectangle whose corner radius is clamped to half the shortest
/// side, so a "full" radius reliably produces a pill or a circle.
public struct ShadRoundedRectangle: Shape, InsettableShape {
    public var cornerRadius: CGFloat
    private var inset: CGFloat = 0

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: inset, dy: inset)
        guard insetRect.width > 0, insetRect.height > 0 else { return Path() }
        let radius = min(cornerRadius, min(insetRect.width, insetRect.height) / 2)
        return Path(roundedRect: insetRect, cornerRadius: max(0, radius), style: .continuous)
    }

    public func inset(by amount: CGFloat) -> ShadRoundedRectangle {
        var copy = self
        copy.inset += amount
        return copy
    }
}

extension View {
    /// Casts `shadow` from an unclipped shape behind this view.
    ///
    /// Use this rather than `.shadow` directly on a surface: a shadow applied
    /// to the view itself is drawn from the alpha of everything in it, which
    /// haloes text, and a shadow applied inside a `clipShape` is cut away.
    @ViewBuilder
    func shadElevation(_ shadow: ShadShadow, cornerRadius: CGFloat, fill: Color) -> some View {
        if shadow.isEmpty {
            self
        } else {
            background(
                ShadRoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fill)
                    .shadShadow(shadow)
            )
        }
    }

    /// Applies one of the theme's shadow levels, stacking each layer the way a
    /// CSS `box-shadow` list does.
    @ViewBuilder
    public func shadShadow(_ shadow: ShadShadow) -> some View {
        switch shadow.layers.count {
        case 0:
            self
        case 1:
            self.shadow(color: shadow.layers[0].color, radius: shadow.layers[0].radius,
                        x: shadow.layers[0].x, y: shadow.layers[0].y)
        default:
            self
                .shadow(color: shadow.layers[0].color, radius: shadow.layers[0].radius,
                        x: shadow.layers[0].x, y: shadow.layers[0].y)
                .shadow(color: shadow.layers[1].color, radius: shadow.layers[1].radius,
                        x: shadow.layers[1].x, y: shadow.layers[1].y)
        }
    }

    /// Fills, borders and clips a view in one step — the shape every surface in
    /// the library is built from.
    ///
    /// The shadow is cast by a second copy of the shape sitting *behind* the
    /// clip. Two mistakes are easy here and both have been made: shadowing the
    /// view itself haloes the text inside it, and shadowing a background that
    /// is then clipped removes the shadow entirely, since the clip applies to
    /// the composited result.
    func shadSurfaceStyle(
        fill: Color,
        border: Color? = nil,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat,
        shadow: ShadShadow = .none
    ) -> some View {
        let shape = ShadRoundedRectangle(cornerRadius: cornerRadius)
        return self
            .background(shape.fill(fill))
            .overlay {
                if let border, borderWidth > 0 {
                    shape.strokeBorder(border, lineWidth: borderWidth)
                }
            }
            .clipShape(shape)
            .shadElevation(shadow, cornerRadius: cornerRadius, fill: fill)
    }

    /// Applies `transform` only when `condition` holds.
    @ViewBuilder
    func shadIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

/// A 1pt hairline in the theme's border color.
public struct ShadSeparator: View {
    @Environment(\.shadTheme) private var theme
    private let axis: Axis
    private let color: Color?

    public init(_ axis: Axis = .horizontal, color: Color? = nil) {
        self.axis = axis
        self.color = color
    }

    public var body: some View {
        Rectangle()
            .fill(color ?? theme.colors.border)
            .frame(
                width: axis == .vertical ? theme.borderWidth : nil,
                height: axis == .horizontal ? theme.borderWidth : nil
            )
    }
}
