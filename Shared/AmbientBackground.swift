import SwiftUI

/// Living backdrop: animated mesh gradient on iOS 18+, drifting blurred blobs
/// on older systems, plus film grain so nothing ever looks flat.
struct AmbientBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            base
            core
            grain
            vignette
        }
        .ignoresSafeArea()
    }

    private var base: Color {
        scheme == .dark ? Color(hex: "100F0B") : Color(hex: "F8F5EE")
    }

    @ViewBuilder
    private var core: some View {
        if #available(iOS 18.0, *) {
            AnimatedMesh(scheme: scheme)
        } else {
            AnimatedBlobs(scheme: scheme)
        }
    }

    private var grain: some View {
        Image("Grain")
            .resizable(resizingMode: .tile)
            .blendMode(scheme == .dark ? .softLight : .overlay)
            .opacity(scheme == .dark ? 0.5 : 0.4)
            .allowsHitTesting(false)
    }

    private var vignette: some View {
        LinearGradient(
            colors: [.black.opacity(scheme == .dark ? 0.28 : 0.05), .clear, .black.opacity(scheme == .dark ? 0.3 : 0.06)],
            startPoint: .top, endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}

@available(iOS 18.0, *)
private struct AnimatedMesh: View {
    let scheme: ColorScheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            MeshGradient(
                width: 3,
                height: 3,
                points: Self.basePoints.map { base in
                    Self.offset(base, t: t)
                },
                colors: scheme == .dark ? Self.darkColors : Self.lightColors,
                smoothsColors: true
            )
        }
        .allowsHitTesting(false)
    }

    private static let basePoints: [SIMD2<Float>] = [
        [0, 0], [0.5, 0], [1, 0],
        [0, 0.5], [0.5, 0.5], [1, 0.5],
        [0, 1], [0.5, 1], [1, 1],
    ]

    private static func offset(_ p: SIMD2<Float>, t: Double) -> SIMD2<Float> {
        let phase = Float(p.x * 3.1 + p.y * 5.7)
        let dx = Float(sin(t * 0.21 + phase)) * 0.07
        let dy = Float(cos(t * 0.17 + phase * 1.3)) * 0.06
        return SIMD2<Float>(min(1, max(0, p.x + dx)), min(1, max(0, p.y + dy)))
    }

    private static let lightColors: [Color] = [
        Color(hex: "F8F5EE"), Color(hex: "F6F1E6"), Color(hex: "F1EBDD"),
        Color(hex: "F3E4D7"), Color(hex: "E7EDE3"), Color(hex: "F5EFE2"),
        Color(hex: "EEEAE0"), Color(hex: "F4ECDA"), Color(hex: "ECE8DF"),
    ]

    private static let darkColors: [Color] = [
        Color(hex: "141109"), Color(hex: "171310"), Color(hex: "100F0C"),
        Color(hex: "1D1410"), Color(hex: "101612"), Color(hex: "14120D"),
        Color(hex: "0F0E0B"), Color(hex: "171310"), Color(hex: "0D0D0A"),
    ]
}

private struct AnimatedBlobs: View {
    let scheme: ColorScheme

    private struct Blob {
        let color: Color
        let base: CGPoint
        let radius: CGFloat
        let speed: Double
        let phase: Double
        let travel: CGFloat
    }

    private var blobs: [Blob] {
        let alpha: CGFloat = scheme == .dark ? 0.5 : 0.4
        return [
            Blob(color: Color(hex: "C96A3F").opacity(alpha), base: CGPoint(x: 0.15, y: 0.2), radius: 260, speed: 0.23, phase: 0.0, travel: 60),
            Blob(color: Color(hex: "4E8F70").opacity(alpha * 0.8), base: CGPoint(x: 0.85, y: 0.3), radius: 300, speed: 0.17, phase: 1.8, travel: 74),
            Blob(color: Color(hex: "D9A441").opacity(alpha * 0.65), base: CGPoint(x: 0.7, y: 0.85), radius: 280, speed: 0.2, phase: 3.4, travel: 66),
            Blob(color: Color(hex: "5B7FB4").opacity(alpha * 0.6), base: CGPoint(x: 0.25, y: 0.85), radius: 250, speed: 0.15, phase: 4.9, travel: 58),
        ]
    }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(Array(blobs.enumerated()), id: \.offset) { _, blob in
                        let dx = cos(t * blob.speed + blob.phase) * blob.travel
                        let dy = sin(t * blob.speed * 0.8 + blob.phase * 1.7) * blob.travel * 0.8
                        Circle()
                            .fill(blob.color)
                            .frame(width: blob.radius * 2, height: blob.radius * 2)
                            .blur(radius: 70)
                            .position(
                                x: blob.base.x * geo.size.width + dx,
                                y: blob.base.y * geo.size.height + dy
                            )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .allowsHitTesting(false)
    }
}
