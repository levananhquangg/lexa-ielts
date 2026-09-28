import SwiftUI
import UIKit

// MARK: - Palette

enum Palette {
    static let paper = Color(light: "F7F4ED", dark: "14120D")
    static let card = Color(light: "FFFFFF", dark: "1F1C15")
    static let ink = Color(light: "221D13", dark: "F1ECE1")
    static let muted = Color(light: "6F6757", dark: "9C937F")
    static let hairline = Color(light: "E7E1D2", dark: "322D22")
    static let accent = Color(light: "B4542E", dark: "DE7A4C")

    static func band(_ band: Int) -> Color {
        switch band {
        case 5: return Color(light: "4C7FB0", dark: "7FA9D4")
        case 6: return Color(light: "3D8A67", dark: "76B794")
        case 7: return Color(light: "C98A2D", dark: "E0AC64")
        default: return Color(light: "B4542E", dark: "DE7A4C")
        }
    }
}

extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
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

// MARK: - Cards

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.card)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Palette.hairline, lineWidth: 1)
            )
    }
}

extension View {
    func card() -> some View {
        modifier(CardStyle())
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
            .background(Capsule().fill(Palette.band(band).opacity(0.14)))
            .foregroundStyle(Palette.band(band))
    }
}

struct SelectableChip: View {
    let title: String
    let selected: Bool
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 5) {
                if let systemImage {
                    Image(systemName: systemImage).font(.caption2.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(selected ? Palette.accent : Palette.hairline.opacity(0.35))
            )
            .foregroundStyle(selected ? Color.white : Palette.ink)
        }
        .buttonStyle(.plain)
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
