import SwiftUI

// MARK: - Custom hand-drawn icon set
//
// Every icon is a path string on a 24×24 grid, stroke-based with round caps.
// The same strings drive the app (parsed below) and the HTML design preview
// (tools/gen_preview_icons.py extracts them), so the two always match.
// Commands (absolute): M x y · L x y · C x1 y1 x2 y2 x y · Q x1 y1 x y ·
// A rx ry rot laf sf x y · O cx cy rx ry rot (full ellipse) · Z

enum AppIcon: String {
    // Tab bar
    case sun = "O 12 12 4 4 0 M19 12 L21.8 12 M5 12 L2.2 12 M12 5 L12 2.2 M12 19 L12 21.8 M16.9 7.1 L19.8 4.2 M16.9 16.9 L19.8 19.8 M7.1 16.9 L4.2 19.8 M7.1 7.1 L4.2 4.2"
    case compass = "O 12 12 9 9 0 M16.2 7.8 L14.1 14.1 L7.8 16.2 L9.9 9.9 Z"
    case book = "M2.5 3.5 L8.5 3.5 C10.71 3.5 12 5.29 12 7.5 L12 21 C11 19.7 9.7 19 8 19 L2.5 19 Z M21.5 3.5 L15.5 3.5 C13.29 3.5 12 5.29 12 7.5 L12 21 C13 19.7 14.3 19 16 19 L21.5 19 Z"
    case chart = "M3.5 20.5 L20.5 20.5 M6.5 16.5 L6.5 9.5 M12 16.5 L12 4.5 M17.5 16.5 L17.5 11.5"
    case sliders = "M4 7 L20 7 M4 12 L20 12 M4 17 L20 17 O 9.5 7 2 2 0 O 14.5 12 2 2 0 O 8.5 17 2 2 0"

    // UI
    case bookmark = "M6.8 3.5 L17.2 3.5 C17.75 3.5 18.2 3.95 18.2 4.5 L18.2 20.8 L12 16.2 L5.8 20.8 L5.8 4.5 C5.8 3.95 6.25 3.5 6.8 3.5 Z"
    case eye = "M2.8 12 C5.4 7.4 8.5 5.2 12 5.2 C15.5 5.2 18.6 7.4 21.2 12 C18.6 16.6 15.5 18.8 12 18.8 C8.5 18.8 5.4 16.6 2.8 12 Z O 12 12 2.9 2.9 0"
    case xmark = "M6.5 6.5 L17.5 17.5 M17.5 6.5 L6.5 17.5"
    case search = "O 10.8 10.8 6.3 6.3 0 M15.4 15.4 L20.5 20.5"
    case calendar = "M4.8 5.5 L19.2 5.5 C19.75 5.5 20.2 5.95 20.2 6.5 L20.2 19.2 C20.2 19.75 19.75 20.2 19.2 20.2 L4.8 20.2 C4.25 20.2 3.8 19.75 3.8 19.2 L3.8 6.5 C3.8 5.95 4.25 5.5 4.8 5.5 Z M3.8 9.7 L20.2 9.7 M8.2 3.2 L8.2 6.8 M15.8 3.2 L15.8 6.8"
    case trash = "M4 6.8 L20 6.8 M9.2 6.8 L9.2 4.3 C9.2 3.75 9.65 3.3 10.2 3.3 L13.8 3.3 C14.35 3.3 14.8 3.75 14.8 4.3 L14.8 6.8 M6 6.8 L6.8 18.9 C6.85 19.7 7.5 20.3 8.3 20.3 L15.7 20.3 C16.5 20.3 17.15 19.7 17.2 18.9 L18 6.8 M10 10.4 L10 16.6 M14 10.4 L14 16.6"
    case chevronRight = "M9.2 5 L16.2 12 L9.2 19"
    case chevronDown = "M5 9.2 L12 16.2 L19 9.2"
    case grid = "O 7.5 7.5 2.3 2.3 0 O 16.5 7.5 2.3 2.3 0 O 7.5 16.5 2.3 2.3 0 O 16.5 16.5 2.3 2.3 0"
    case refresh = "M3.6 12 A8.4 8.4 0 0 1 18.2 6.9 M18.2 6.9 L18.7 3.3 M18.2 6.9 L14.7 6.6 M20.4 12 A8.4 8.4 0 0 1 5.8 17.1 M5.8 17.1 L5.3 20.7 M5.8 17.1 L9.3 17.4"
    case moon = "M20.6 13.3 A8.6 8.6 0 1 1 10.7 3.4 A7 7 0 0 0 20.6 13.3 Z"
    case contrast = "O 12 12 8.4 8.4 0 M12 3.6 A8.4 8.4 0 0 0 12 20.4 Z"

    // Topics
    case graduation = "M2.8 9.4 L12 4.8 L21.2 9.4 L12 14 Z M6.6 11.4 L6.6 16 C6.6 17.75 9 19.1 12 19.1 C15 19.1 17.4 17.75 17.4 16 L17.4 11.4 M21.2 9.4 L21.2 14.6"
    case briefcase = "M4.2 7.6 L19.8 7.6 C20.35 7.6 20.8 8.05 20.8 8.6 L20.8 17.9 C20.8 18.45 20.35 18.9 19.8 18.9 L4.2 18.9 C3.65 18.9 3.2 18.45 3.2 17.9 L3.2 8.6 C3.2 8.05 3.65 7.6 4.2 7.6 Z M8.8 7.6 L8.8 5.6 C8.8 5.05 9.25 4.6 9.8 4.6 L14.2 4.6 C14.75 4.6 15.2 5.05 15.2 5.6 L15.2 7.6 M3.2 12.4 L20.8 12.4 M10.6 12.4 L10.6 14.6 L13.4 14.6 L13.4 12.4"
    case cpu = "M6.6 5 L17.4 5 C17.95 5 18.4 5.45 18.4 6 L18.4 18 C18.4 18.55 17.95 19 17.4 19 L6.6 19 C6.05 19 5.6 18.55 5.6 18 L5.6 6 C5.6 5.45 6.05 5 6.6 5 Z O 12 12 2.7 2.7 0 M9.2 5 L9.2 2.4 M14.8 5 L14.8 2.4 M9.2 19 L9.2 21.6 M14.8 19 L14.8 21.6 M5 9.2 L2.4 9.2 M5 14.8 L2.4 14.8 M19 9.2 L21.6 9.2 M19 14.8 L21.6 14.8"
    case leaf = "M19.6 4.4 C10.6 4.9 5.6 9.3 5.6 14.4 C5.6 17.7 8.1 20.2 11.3 20.3 C11.2 15.2 14.2 8.6 19.6 4.4 Z M4.2 20.6 C6.2 17.2 9.6 13.8 13.4 11.9"
    case heart = "M12 20.1 C7.1 16.5 3.4 13.4 3.4 9.5 C3.4 6.8 5.5 4.7 8 4.7 C9.7 4.7 11.2 5.6 12 7 C12.8 5.6 14.3 4.7 16 4.7 C18.5 4.7 20.6 6.8 20.6 9.5 C20.6 13.4 16.9 16.5 12 20.1 Z"
    case users = "O 9.4 8 3.2 3.2 0 M3.6 19.4 C3.6 15.9 6.2 13.6 9.4 13.6 C12.6 13.6 15.2 15.9 15.2 19.4 M15.9 5 C17.4 5.6 18.4 7 18.4 8.6 C18.4 10.1 17.6 11.4 16.3 12 M17.3 14.1 C19.3 14.9 20.6 16.7 20.6 19.1"
    case banknote = "M3.6 6.6 L20.4 6.6 C20.95 6.6 21.4 7.05 21.4 7.6 L21.4 16.4 C21.4 16.95 20.95 17.4 20.4 17.4 L3.6 17.4 C3.05 17.4 2.6 16.95 2.6 16.4 L2.6 7.6 C2.6 7.05 3.05 6.6 3.6 6.6 Z O 12 12 2.5 2.5 0 M6.2 10.1 L6.21 10.1 M17.8 13.9 L17.81 13.9"
    case megaphone = "M3.6 10.4 L3.6 13.6 C3.6 14.15 4.05 14.6 4.6 14.6 L7.1 14.6 L15.4 18.95 C16.1 19.3 17 18.8 17 18 L17 6 C17 5.2 16.1 4.7 15.4 5.05 L7.1 9.4 L4.6 9.4 C4.05 9.4 3.6 9.85 3.6 10.4 Z M20.2 9.7 C21 10.7 21 13.3 20.2 14.3 M7.4 14.6 L8.3 19.7"
    case plane = "M17.6 19.1 L16 11.2 L19.4 7.8 C20.8 6.4 21.3 4.5 20.8 3.6 C19.9 3.1 18 3.6 16.6 5 L13.2 8.4 L5.1 6.6 C4.6 6.5 4.2 6.7 4 7.1 L3.8 7.5 C3.6 7.9 3.7 8.4 4.1 8.7 L9.2 12.1 L7.3 15 L4.4 15 L3.4 16 L6.4 18 L8.4 21 L9.4 20 L9.4 17.1 L12.3 15.2 L15.7 20.3 C15.9 20.7 16.4 20.8 16.8 20.6 L17.2 20.4 C17.6 20.2 17.8 19.6 17.6 19.1 Z"
    case palette = "M12 3.6 C7.1 3.6 3.2 7.2 3.2 11.9 C3.2 16.6 7.1 20.4 12 20.4 C13.4 20.4 14.3 19.5 14.3 18.4 C14.3 17.8 14 17.4 13.7 17 C13.4 16.7 13.2 16.3 13.2 15.9 C13.2 14.9 14 14.1 15 14.1 L17.3 14.1 C19.6 14.1 21.4 12.4 21.4 10.2 C21.4 6.5 17.2 3.6 12 3.6 Z M7.3 10.2 L7.31 10.2 M11.6 7.3 L11.61 7.3 M15.9 9.3 L15.91 9.3 M8.6 14.1 L8.61 14.1"
    case atom = "O 12 12 2 2 0 O 12 12 9.2 3.8 62 O 12 12 9.2 3.8 118"
    case scales = "M12 4.4 L12 20.6 M8.6 20.6 L15.4 20.6 M4.6 7.4 L19.4 7.4 O 12 4 1.3 1.3 0 M4.6 7.4 L2.4 12.9 M4.6 7.4 L6.8 12.9 M2.3 12.9 C3.3 15 6.9 15 7.9 12.9 M19.4 7.4 L17.2 12.9 M19.4 7.4 L21.6 12.9 M16.1 12.9 C17.1 15 20.7 15 21.7 12.9"
    case columns = "M3.4 9.6 L12 4.6 L20.6 9.6 Z M5.6 9.6 L5.6 16.8 M9.9 9.6 L9.9 16.8 M14.1 9.6 L14.1 16.8 M18.4 9.6 L18.4 16.8 M4.2 19.9 L19.8 19.9"
    case skyline = "M3.2 20.4 L3.2 10.4 L8 10.4 L8 20.4 M8 20.4 L8 4.9 L14 4.9 L14 20.4 M14 20.4 L14 12.4 L19 12.4 L19 20.4 M2.2 20.4 L21.8 20.4 M10.3 7.6 L11.7 7.6 M10.3 10.8 L11.7 10.8 M5 13.2 L6.2 13.2 M16 15.2 L17 15.2"
    case food = "M5.6 3.2 L5.6 7.6 C5.6 9 6.7 10.1 8.1 10.1 C9.5 10.1 10.6 9 10.6 7.6 L10.6 3.2 M8.1 10.1 L8.1 20.8 M18.4 3.3 C15.8 6.2 15.3 9.8 16.7 12.6 M18.4 3.3 C19.6 6.3 19.5 10 18.4 12.6 L18.4 20.8"
    case globe = "O 12 12 8.8 8.8 0 M3.2 12 L20.8 12 M12 3.2 C14.7 5.9 16.1 8.8 16.1 12 C16.1 15.2 14.7 18.1 12 20.8 C9.3 18.1 7.9 15.2 7.9 12 C7.9 8.8 9.3 5.9 12 3.2 Z"
}

/// Icon view rendered from the path string — no system symbol anywhere.
struct AppIconView: View {
    let icon: AppIcon
    var size: CGFloat = 22
    var color: Color = Palette.ink
    var lineWidth: CGFloat = 1.7
    var filled: Bool = false

    init(_ icon: AppIcon, size: CGFloat = 22, color: Color = Palette.ink,
         lineWidth: CGFloat = 1.7, filled: Bool = false) {
        self.icon = icon
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
        self.filled = filled
    }

    var body: some View {
        let path = IconPainter.path(icon.rawValue)
            .applying(CGAffineTransform(scaleX: size / 24, y: size / 24))
        Group {
            if filled {
                path.fill(color)
            } else {
                path.stroke(color, style: StrokeStyle(lineWidth: lineWidth * size / 24, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Path mini-language parser

enum IconPainter {
    static func path(_ d: String) -> Path {
        var path = Path()
        var chars = Array(d)
        var i = 0
        var current = CGPoint.zero

        func skipSeparators() {
            while i < chars.count, chars[i] == " " || chars[i] == "," { i += 1 }
        }

        func number() -> CGFloat {
            skipSeparators()
            var str = ""
            while i < chars.count, "0123456789.-".contains(chars[i]) {
                str.append(chars[i])
                i += 1
            }
            return CGFloat(Double(str) ?? 0)
        }

        func point() -> CGPoint {
            let x = number()
            let y = number()
            return CGPoint(x: x, y: y)
        }

        while i < chars.count {
            let ch = chars[i]
            i += 1
            switch ch {
            case " ":
                continue
            case "M":
                let p = point()
                path.move(to: p)
                current = p
            case "L":
                let p = point()
                path.addLine(to: p)
                current = p
            case "C":
                let c1 = point(), c2 = point(), p = point()
                path.addCurve(to: p, control1: c1, control2: c2)
                current = p
            case "Q":
                let c = point(), p = point()
                path.addQuadCurve(to: p, control: c)
                current = p
            case "A":
                let rx = number(), ry = number(), rot = number()
                let laf = number(), sf = number(), p = point()
                appendArc(&path, from: current, rx: rx, ry: ry, rotation: rot,
                          largeArc: laf == 1, sweep: sf == 1, to: p)
                current = p
            case "O":
                let cx = number(), cy = number(), rx = number(), ry = number(), rot = number()
                appendEllipse(&path, cx: cx, cy: cy, rx: rx, ry: ry, rotation: rot)
                current = CGPoint(x: cx, y: cy)
            case "Z":
                path.closeSubpath()
            default:
                continue
            }
        }
        return path
    }

    private static func appendEllipse(_ path: inout Path, cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, rotation: CGFloat) {
        var p = Path()
        let k: CGFloat = 0.5522847498
        p.move(to: CGPoint(x: cx + rx, y: cy))
        p.addCurve(to: CGPoint(x: cx, y: cy + ry), control1: CGPoint(x: cx + rx, y: cy + ry * k), control2: CGPoint(x: cx + rx * k, y: cy + ry))
        p.addCurve(to: CGPoint(x: cx - rx, y: cy), control1: CGPoint(x: cx - rx * k, y: cy + ry), control2: CGPoint(x: cx - rx, y: cy + ry * k))
        p.addCurve(to: CGPoint(x: cx, y: cy - ry), control1: CGPoint(x: cx - rx, y: cy - ry * k), control2: CGPoint(x: cx - rx * k, y: cy - ry))
        p.addCurve(to: CGPoint(x: cx + rx, y: cy), control1: CGPoint(x: cx + rx * k, y: cy - ry), control2: CGPoint(x: cx + rx, y: cy - ry * k))
        p.closeSubpath()
        if rotation != 0 {
            let t = CGAffineTransform(translationX: cx, y: cy)
                .rotated(by: rotation * .pi / 180)
                .translatedBy(x: -cx, y: -cy)
            p = p.applying(t)
        }
        path.addPath(p)
    }

    /// SVG elliptical-arc (endpoint parameterisation) → cubic segments.
    private static func appendArc(_ path: inout Path, from p0: CGPoint, rx rxIn: CGFloat, ry ryIn: CGFloat,
                                  rotation: CGFloat, largeArc: Bool, sweep: Bool, to p1: CGPoint) {
        if rxIn == 0 || ryIn == 0 {
            path.addLine(to: p1)
            return
        }
        let phi = rotation * .pi / 180
        let dx2 = (p0.x - p1.x) / 2
        let dy2 = (p0.y - p1.y) / 2
        let x1p = cos(phi) * dx2 + sin(phi) * dy2
        let y1p = -sin(phi) * dx2 + cos(phi) * dy2

        var rx = abs(rxIn)
        var ry = abs(ryIn)
        let lambda = x1p * x1p / (rx * rx) + y1p * y1p / (ry * ry)
        if lambda > 1 {
            let s = sqrt(lambda)
            rx *= s
            ry *= s
        }

        let sign: CGFloat = (largeArc != sweep) ? 1 : -1
        let numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
        let denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        let coefficient = sign * sqrt(max(0, numerator / denominator))
        let cxp = coefficient * rx * y1p / ry
        let cyp = -coefficient * ry * x1p / rx
        let cx = cos(phi) * cxp - sin(phi) * cyp + (p0.x + p1.x) / 2
        let cy = sin(phi) * cxp + cos(phi) * cyp + (p0.y + p1.y) / 2

        func angle(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
            let dot = ux * vx + uy * vy
            let length = sqrt(ux * ux + uy * uy) * sqrt(vx * vx + vy * vy)
            var a = acos(min(1, max(-1, length == 0 ? 1 : dot / length)))
            if ux * vy - uy * vx < 0 { a = -a }
            return a
        }

        let theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
        var delta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let segmentCount = Int(ceil(abs(delta) / (Double.pi / 2)))
        let step = delta / CGFloat(max(1, segmentCount))
        let tangentFactor = 4 / 3 * tan(step / 4)
        let transform = CGAffineTransform(translationX: cx, y: cy).rotated(by: phi)

        var theta = theta1
        for _ in 0..<max(1, segmentCount) {
            let nextTheta = theta + step
            let startX = cx + rx * cos(theta), startY = cy + ry * sin(theta)
            let endX = cx + rx * cos(nextTheta), endY = cy + ry * sin(nextTheta)
            let c1 = CGPoint(x: startX - tangentFactor * rx * sin(theta), y: startY + tangentFactor * ry * cos(theta))
            let c2 = CGPoint(x: endX + tangentFactor * rx * sin(nextTheta), y: endY - tangentFactor * ry * cos(nextTheta))
            path.addCurve(
                to: CGPoint(x: endX, y: endY).applying(transform),
                control1: c1.applying(transform),
                control2: c2.applying(transform)
            )
            theta = nextTheta
        }
    }
}
