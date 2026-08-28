import SwiftUI

/// A small SVG path-data parser, enough for the Lucide icon set.
///
/// Supports `M m L l H h V v C c A a Z z` — the commands Lucide actually uses.
/// Elliptical arcs are converted to cubic Béziers.
enum ShadSVGPath {
    static func append(_ data: String, to path: inout Path) {
        var scanner = Tokenizer(data)
        var current = CGPoint.zero
        var start = CGPoint.zero
        var command: Character = "M"
        var lastControl: CGPoint?

        while true {
            scanner.skipSeparators()
            if let letter = scanner.peekCommand() {
                command = letter
                scanner.advance()
            } else if scanner.isAtEnd {
                break
            }

            let isRelative = command.isLowercase
            func point(_ x: Double, _ y: Double) -> CGPoint {
                isRelative
                    ? CGPoint(x: current.x + x, y: current.y + y)
                    : CGPoint(x: x, y: y)
            }

            switch Character(command.lowercased()) {
            case "m":
                guard let x = scanner.number(), let y = scanner.number() else { return }
                current = point(x, y)
                start = current
                path.move(to: current)
                // Subsequent pairs after a moveto are implicit linetos.
                command = isRelative ? "l" : "L"
                lastControl = nil

            case "l":
                guard let x = scanner.number(), let y = scanner.number() else { return }
                current = point(x, y)
                path.addLine(to: current)
                lastControl = nil

            case "h":
                guard let x = scanner.number() else { return }
                current = CGPoint(x: isRelative ? current.x + x : x, y: current.y)
                path.addLine(to: current)
                lastControl = nil

            case "v":
                guard let y = scanner.number() else { return }
                current = CGPoint(x: current.x, y: isRelative ? current.y + y : y)
                path.addLine(to: current)
                lastControl = nil

            case "c":
                guard let x1 = scanner.number(), let y1 = scanner.number(),
                      let x2 = scanner.number(), let y2 = scanner.number(),
                      let x = scanner.number(), let y = scanner.number() else { return }
                let control1 = point(x1, y1)
                let control2 = point(x2, y2)
                current = point(x, y)
                path.addCurve(to: current, control1: control1, control2: control2)
                lastControl = control2

            case "a":
                // The two arc flags are single digits and the grammar lets them
                // run together — `0 00-2.474-1.561` is rotation 0, flags 0 and
                // 0, then the endpoint. Reading them as ordinary numbers would
                // swallow both at once.
                guard let rx = scanner.number(), let ry = scanner.number(),
                      let rotation = scanner.number(), let largeArc = scanner.flag(),
                      let sweep = scanner.flag(), let x = scanner.number(),
                      let y = scanner.number() else { return }
                let end = point(x, y)
                addArc(
                    to: end, from: current, rx: rx, ry: ry,
                    rotation: rotation, largeArc: largeArc != 0, sweep: sweep != 0,
                    path: &path
                )
                current = end
                lastControl = nil

            case "z":
                path.closeSubpath()
                current = start
                lastControl = nil

            default:
                return
            }

            _ = lastControl
            if scanner.isAtEnd { break }
        }
    }

    /// Endpoint-parameterised arc → centre parameterisation → cubic segments.
    /// The maths is the implementation note from the SVG specification.
    private static func addArc(
        to end: CGPoint, from start: CGPoint,
        rx: Double, ry: Double, rotation: Double,
        largeArc: Bool, sweep: Bool,
        path: inout Path
    ) {
        var rx = abs(rx), ry = abs(ry)
        if rx == 0 || ry == 0 {
            path.addLine(to: end)
            return
        }

        let phi = rotation * .pi / 180
        let cosPhi = cos(phi), sinPhi = sin(phi)

        let dx2 = (start.x - end.x) / 2, dy2 = (start.y - end.y) / 2
        let x1 = cosPhi * dx2 + sinPhi * dy2
        let y1 = -sinPhi * dx2 + cosPhi * dy2

        // Scale the radii up if they are too small to span the chord.
        let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 {
            rx *= sqrt(lambda)
            ry *= sqrt(lambda)
        }

        let sign: Double = largeArc == sweep ? -1 : 1
        let numerator = max(0, rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1)
        let denominator = rx * rx * y1 * y1 + ry * ry * x1 * x1
        let coefficient = denominator == 0 ? 0 : sign * sqrt(numerator / denominator)

        let cx1 = coefficient * rx * y1 / ry
        let cy1 = -coefficient * ry * x1 / rx

        let cx = cosPhi * cx1 - sinPhi * cy1 + (start.x + end.x) / 2
        let cy = sinPhi * cx1 + cosPhi * cy1 + (start.y + end.y) / 2

        func angle(_ ux: Double, _ uy: Double, _ vx: Double, _ vy: Double) -> Double {
            let dot = ux * vx + uy * vy
            let len = sqrt(ux * ux + uy * uy) * sqrt(vx * vx + vy * vy)
            guard len != 0 else { return 0 }
            var value = acos(min(max(dot / len, -1), 1))
            if ux * vy - uy * vx < 0 { value = -value }
            return value
        }

        let theta1 = angle(1, 0, (x1 - cx1) / rx, (y1 - cy1) / ry)
        var delta = angle((x1 - cx1) / rx, (y1 - cy1) / ry, (-x1 - cx1) / rx, (-y1 - cy1) / ry)
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let segments = Int(ceil(abs(delta / (.pi / 2))))
        guard segments > 0 else { return }
        let step = delta / Double(segments)
        let alpha = 4.0 / 3.0 * tan(step / 4)

        var theta = theta1
        var point = start
        for _ in 0..<segments {
            let next = theta + step
            let cosT = cos(theta), sinT = sin(theta)
            let cosN = cos(next), sinN = sin(next)

            func map(_ ex: Double, _ ey: Double) -> CGPoint {
                CGPoint(
                    x: cosPhi * rx * ex - sinPhi * ry * ey + cx,
                    y: sinPhi * rx * ex + cosPhi * ry * ey + cy
                )
            }

            let endPoint = map(cosN, sinN)
            let control1 = CGPoint(
                x: point.x + alpha * (cosPhi * rx * -sinT - sinPhi * ry * cosT),
                y: point.y + alpha * (sinPhi * rx * -sinT + cosPhi * ry * cosT)
            )
            let control2 = CGPoint(
                x: endPoint.x - alpha * (cosPhi * rx * -sinN - sinPhi * ry * cosN),
                y: endPoint.y - alpha * (sinPhi * rx * -sinN + cosPhi * ry * cosN)
            )
            path.addCurve(to: endPoint, control1: control1, control2: control2)

            point = endPoint
            theta = next
        }
    }

    // MARK: - Tokenizer

    private struct Tokenizer {
        private let characters: [Character]
        private var index = 0

        init(_ text: String) { characters = Array(text) }

        var isAtEnd: Bool { index >= characters.count }

        mutating func skipSeparators() {
            while index < characters.count, characters[index] == " " || characters[index] == "," || characters[index] == "\n" {
                index += 1
            }
        }

        func peekCommand() -> Character? {
            guard index < characters.count else { return nil }
            let character = characters[index]
            return character.isLetter && character != "e" && character != "E" ? character : nil
        }

        mutating func advance() { index += 1 }

        /// Reads a single-character arc flag.
        mutating func flag() -> Double? {
            skipSeparators()
            guard index < characters.count else { return nil }
            let character = characters[index]
            guard character == "0" || character == "1" else { return nil }
            index += 1
            return character == "1" ? 1 : 0
        }

        mutating func number() -> Double? {
            skipSeparators()
            var text = ""
            var sawDot = false
            var sawExponent = false

            if index < characters.count, characters[index] == "-" || characters[index] == "+" {
                text.append(characters[index]); index += 1
            }
            while index < characters.count {
                let character = characters[index]
                if character.isNumber {
                    text.append(character); index += 1
                } else if character == "." {
                    // SVG packs numbers without separators — `.53.53` is two
                    // values, not one. A second point starts the next number.
                    if sawDot || sawExponent { break }
                    sawDot = true
                    text.append(character); index += 1
                } else if character == "e" || character == "E", !text.isEmpty, !sawExponent {
                    sawExponent = true
                    text.append(character); index += 1
                    if index < characters.count, characters[index] == "-" || characters[index] == "+" {
                        text.append(characters[index]); index += 1
                    }
                } else {
                    break
                }
            }
            return Double(text)
        }
    }
}

/// A Lucide glyph as a SwiftUI `Shape`, drawn in its native 24×24 grid and
/// scaled to whatever frame it is given.
struct ShadLucideShape: Shape, @unchecked Sendable {
    let commands: [ShadVectorCommand]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for command in commands {
            switch command {
            case .path(let data):
                ShadSVGPath.append(data, to: &path)
            case .circle(let x, let y, let r):
                path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
            case .rect(let x, let y, let width, let height, let rx, let ry):
                if rx > 0 || ry > 0 {
                    path.addRoundedRect(
                        in: CGRect(x: x, y: y, width: width, height: height),
                        cornerSize: CGSize(width: rx, height: ry == 0 ? rx : ry)
                    )
                } else {
                    path.addRect(CGRect(x: x, y: y, width: width, height: height))
                }
            case .line(let x1, let y1, let x2, let y2):
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))
            }
        }
        let scale = min(rect.width, rect.height) / 24
        return path.applying(
            CGAffineTransform(translationX: rect.minX, y: rect.minY)
                .scaledBy(x: scale, y: scale)
        )
    }
}
