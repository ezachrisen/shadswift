import SwiftUI

/// An input where the user selects a value from within a given range.
///
/// One thumb per element of `values`, so a two-element binding produces
/// shadcn's range slider.
///
/// ```swift
/// ShadSlider(value: $volume, in: 0...100, step: 1)
/// ShadSlider(values: $range, in: 0...100)          // two thumbs
/// ShadSlider(value: $level, orientation: .vertical)
/// ```
public struct ShadSlider: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var values: [Double]
    private let bounds: ClosedRange<Double>
    private let step: Double?
    private let orientation: Axis
    private let trackThickness: CGFloat
    private let thumbSize: CGFloat
    private let onEditingChanged: ((Bool) -> Void)?

    @State private var activeThumb: Int?
    @State private var hoveringThumb: Int?

    public init(
        values: Binding<[Double]>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        orientation: Axis = .horizontal,
        trackThickness: CGFloat = 4,
        thumbSize: CGFloat = 12,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._values = values
        self.bounds = bounds
        self.step = step
        self.orientation = orientation
        self.trackThickness = trackThickness
        self.thumbSize = thumbSize
        self.onEditingChanged = onEditingChanged
    }

    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        orientation: Axis = .horizontal,
        trackThickness: CGFloat = 4,
        thumbSize: CGFloat = 12,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.init(
            values: Binding(
                get: { [value.wrappedValue] },
                set: { value.wrappedValue = $0.first ?? value.wrappedValue }
            ),
            in: bounds,
            step: step,
            orientation: orientation,
            trackThickness: trackThickness,
            thumbSize: thumbSize,
            onEditingChanged: onEditingChanged
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            let length = orientation == .horizontal ? proxy.size.width : proxy.size.height
            let usable = max(1, length - thumbSize)

            ZStack(alignment: orientation == .horizontal ? .leading : .bottom) {
                track
                filled(usable: usable)
                ForEach(values.indices, id: \.self) { index in
                    thumb(index: index, usable: usable)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(dragGesture(usable: usable))
        }
        .frame(
            width: orientation == .vertical ? thumbSize : nil,
            height: orientation == .horizontal ? thumbSize : nil
        )
        .frame(minHeight: orientation == .vertical ? 120 : nil)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(values.map { String(format: "%.0f", $0) }.joined(separator: " to "))
    }

    // MARK: Pieces

    private var track: some View {
        Capsule()
            .fill(theme.colors.muted)
            .frame(
                width: orientation == .vertical ? trackThickness : nil,
                height: orientation == .horizontal ? trackThickness : nil
            )
            .frame(maxWidth: orientation == .horizontal ? .infinity : nil,
                   maxHeight: orientation == .vertical ? .infinity : nil)
    }

    private func filled(usable: CGFloat) -> some View {
        let sorted = values.sorted()
        let start = sorted.count > 1 ? position(for: sorted.first ?? bounds.lowerBound, usable: usable) : 0
        let end = position(for: sorted.last ?? bounds.lowerBound, usable: usable)
        let extent = max(0, end - start) + (sorted.count > 1 ? 0 : thumbSize / 2)

        return Capsule()
            .fill(theme.colors.primary)
            .frame(
                width: orientation == .horizontal ? extent + (sorted.count > 1 ? thumbSize / 2 : thumbSize / 2) : trackThickness,
                height: orientation == .vertical ? extent + thumbSize / 2 : trackThickness
            )
            .offset(
                x: orientation == .horizontal ? start : 0,
                y: orientation == .vertical ? -start : 0
            )
            .frame(
                maxWidth: orientation == .horizontal ? .infinity : nil,
                maxHeight: orientation == .vertical ? .infinity : nil,
                alignment: orientation == .horizontal ? .leading : .bottom
            )
    }

    private func thumb(index: Int, usable: CGFloat) -> some View {
        let offset = position(for: values[index], usable: usable)
        let isActive = activeThumb == index || hoveringThumb == index

        return Circle()
            .fill(theme.colors.background)
            .overlay(
                Circle().strokeBorder(theme.colors.ring, lineWidth: theme.borderWidth)
            )
            .frame(width: thumbSize, height: thumbSize)
            // shadcn grows a 3pt halo on hover and while dragging. It sits
            // outside the thumb, and the thumb itself never changes size.
            .overlay(
                Circle()
                    .inset(by: -theme.focusRing.width)
                    .strokeBorder(theme.colors.ring.opacity(isActive ? theme.focusRing.opacity : 0),
                                  lineWidth: theme.focusRing.width)
            )
            .animation(theme.interactionAnimation, value: isActive)
            .offset(
                x: orientation == .horizontal ? offset : 0,
                y: orientation == .vertical ? -offset : 0
            )
            .frame(
                maxWidth: orientation == .horizontal ? .infinity : nil,
                maxHeight: orientation == .vertical ? .infinity : nil,
                alignment: orientation == .horizontal ? .leading : .bottom
            )
            .onHover { hovering in
                guard isEnabled else { return }
                hoveringThumb = hovering ? index : (hoveringThumb == index ? nil : hoveringThumb)
            }
    }

    // MARK: Maths

    private func fraction(of value: Double) -> Double {
        let span = bounds.upperBound - bounds.lowerBound
        guard span > 0 else { return 0 }
        return min(max((value - bounds.lowerBound) / span, 0), 1)
    }

    private func position(for value: Double, usable: CGFloat) -> CGFloat {
        CGFloat(fraction(of: value)) * usable
    }

    private func value(at point: CGFloat, usable: CGFloat) -> Double {
        let clamped = min(max(point - thumbSize / 2, 0), usable)
        var raw = bounds.lowerBound + Double(clamped / usable) * (bounds.upperBound - bounds.lowerBound)
        if let step, step > 0 {
            raw = (raw / step).rounded() * step
        }
        return min(max(raw, bounds.lowerBound), bounds.upperBound)
    }

    private func dragGesture(usable: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                guard isEnabled else { return }
                let point = orientation == .horizontal
                    ? drag.location.x
                    : (usable + thumbSize) - drag.location.y
                let newValue = value(at: point, usable: usable)

                let index = activeThumb ?? nearestThumb(to: newValue)
                if activeThumb == nil {
                    activeThumb = index
                    onEditingChanged?(true)
                }
                var updated = values
                updated[index] = newValue
                values = updated
            }
            .onEnded { _ in
                activeThumb = nil
                onEditingChanged?(false)
            }
    }

    private func nearestThumb(to value: Double) -> Int {
        var best = 0
        var bestDistance = Double.greatestFiniteMagnitude
        for (index, current) in values.enumerated() {
            let distance = abs(current - value)
            if distance < bestDistance {
                bestDistance = distance
                best = index
            }
        }
        return best
    }
}
