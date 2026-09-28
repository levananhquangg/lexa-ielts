import SwiftUI
import UIKit

// MARK: - Palette

enum Palette {
    static let paper = Color(light: "F8F5EE", dark: "100F0B")
    static let card = Color(light: "FFFFFF", dark: "1F1C15")
    static let ink = Color(light: "221D13", dark: "F1ECE1")
    static let muted = Color(light: "6F6757", dark: "9C937F")
    static let hairline = Color(light: "E7E1D2", dark: "322D22")
    static let accent = Color(light: "B4542E", dark: "DE7A4C")
    static let accentSoft = Color(light: "D08A2E", dark: "E8B05C")

    static let accentGradient = LinearGradient(
        colors: [Color(light: "B4542E", dark: "DE7A4C"), Color(light: "D08A2E", dark: "E8B05C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func band(_ band: Int) -> Color {
        switch band {
        case 5: return Color(light: "4C7FB0", dark: "7FA9D4")
        case 6: return Color(light: "3D8A67", dark: "76B794")
        case 7: return Color(light: "C98A2D", dark: "E0AC64")
        default: return Color(light: "B4542E", dark: "DE7A4C")
        }
    }

    /// Matches the LaunchBackground asset so the static launch screen and the
    /// animated splash blend into each other seamlessly.
    static let splashBack = Color(light: "F7F4ED", dark: "14120D")
}

extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

extension UIColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex.replacingOccurrences(of: "#", with: "")).scanHexInt64(&value)
        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

// MARK: - Haptics

@MainActor
enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Glass surfaces

extension View {
    /// Signature surface: real Liquid Glass on iOS 26+, layered material with
    /// a hairline stroke on older systems.
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 24, padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .modifier(GlassSurface(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func glassSurface(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassSurface(cornerRadius: cornerRadius))
    }
}

private struct GlassSurface: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(Palette.hairline, lineWidth: 1))
        }
    }
}

// MARK: - Press feedback

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Signature flourish

/// The hand-drawn swash that sits under a word — Lexa's small trademark.
struct Swash: View {
    var width: CGFloat = 46

    var body: some View {
        IconPainter.path("M2 7 C12 1.6 30 1.6 42 6")
            .stroke(Palette.accentGradient, style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            .frame(width: width, height: 9)
    }
}

// MARK: - Chips

struct BandChip: View {
    let band: Int

    var body: some View {
        Text(Band(rawValue: band)?.label ?? "")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Palette.band(band).opacity(0.16)))
            .overlay(Capsule().strokeBorder(Palette.band(band).opacity(0.4), lineWidth: 1))
            .foregroundStyle(Palette.band(band))
    }
}

struct SelectableChip: View {
    let title: String
    let selected: Bool
    var systemIcon: AppIcon? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let systemIcon {
                    AppIconView(systemIcon, size: 14, color: selected ? .white : Palette.muted, lineWidth: 2)
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(selected ? AnyShapeStyle(Palette.accentGradient) : AnyShapeStyle(Palette.hairline.opacity(0.35)))
            )
            .foregroundStyle(selected ? Color.white : Palette.ink)
        }
        .buttonStyle(PressableStyle())
    }
}

// MARK: - Flow layout for chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    private struct Row {
        var items: [(index: Int, size: CGSize)] = []
        var height: CGFloat = 0
        var width: CGFloat = 0
    }

    private func rows(proposalWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for (index, view) in subviews.enumerated() {
            let size = view.sizeThatFits(.unspecified)
            let nextWidth = (current.items.isEmpty ? 0 : current.width + spacing) + size.width
            if nextWidth > proposalWidth, !current.items.isEmpty {
                rows.append(current)
                current = Row()
            }
            let width = (current.items.isEmpty ? 0 : current.width + spacing) + size.width
            current.items.append((index, size))
            current.width = width
            current.height = max(current.height, size.height)
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let laid = rows(proposalWidth: width, subviews: subviews)
        let height = laid.reduce(0) { $0 + $1.height } + CGFloat(max(0, laid.count - 1)) * spacing
        let widest = laid.map(\.width).max() ?? 0
        return CGSize(width: min(width, widest), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let laid = rows(proposalWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in laid {
            var x = bounds.minX
            for (index, size) in row.items {
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }
}
