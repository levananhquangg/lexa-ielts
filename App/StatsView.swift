import SwiftUI
import Charts

struct StatsView: View {
    @Environment(AppState.self) private var state
    @State private var period: StatsPeriod = .week

    private var lang: String { state.settings.interfaceLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if state.progress.records.isEmpty {
                        emptyState
                    } else {
                        mainCard
                        tiles
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle(L10n.tr("tab.stats", lang))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Chart card

    private var mainCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("", selection: $period) {
                ForEach(StatsPeriod.allCases) { value in
                    Text(L10n.tr("stats.\(value.rawValue)", lang)).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(state.progress.totalInPeriod(period))")
                    .font(.system(size: 46, weight: .semibold, design: .serif))
                    .foregroundStyle(Palette.ink)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(L10n.tr("stats.newWords", lang))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: period)

            chart
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: period)
    }

    private var buckets: [StatsBucket] {
        state.progress.buckets(for: period)
    }

    private var chartUnit: Calendar.Component {
        switch period {
        case .quarter: return .weekOfYear
        case .year: return .month
        default: return .day
        }
    }

    private var strideValues: AxisMarkValues {
        switch period {
        case .week: return .stride(by: .day)
        case .month: return .stride(by: .weekOfYear)
        case .quarter, .year: return .stride(by: .month)
        }
    }

    private var axisFormat: Date.FormatStyle {
        switch period {
        case .quarter, .year: return .dateTime.month(.abbreviated)
        default: return .dateTime.day().month(.abbreviated)
        }
    }

    private var chart: some View {
        Chart(buckets) { bucket in
            BarMark(
                x: .value("date", bucket.date, unit: chartUnit),
                y: .value("count", bucket.count)
            )
            .foregroundStyle(Palette.accentGradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks(values: strideValues) { _ in
                AxisValueLabel(format: axisFormat)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
    }

    // MARK: - Tiles

    private var tiles: some View {
        HStack(spacing: 12) {
            StatTile(
                value: state.progress.records.count,
                label: L10n.tr("stats.allTime", lang),
                icon: .book
            )
            StatTile(
                value: state.progress.savedCount,
                label: L10n.tr("stats.savedWords", lang),
                icon: .bookmark
            )
            StatTile(
                value: state.progress.totalInPeriod(.week),
                label: L10n.tr("stats.week", lang),
                icon: .sun
            )
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: state.progress.records.count)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            AppIconView(.chart, size: 34, color: Palette.muted, lineWidth: 1.5)
            Text(L10n.tr("stats.empty", lang))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

private struct StatTile: View {
    let value: Int
    let label: String
    let icon: AppIcon

    var body: some View {
        VStack(spacing: 6) {
            AppIconView(icon, size: 15, color: Palette.accent, lineWidth: 1.9)
            Text("\(value)")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(Palette.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassSurface(cornerRadius: 18)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: value)
    }
}
