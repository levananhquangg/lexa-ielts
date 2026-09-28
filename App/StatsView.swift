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
            .background(Palette.paper.ignoresSafeArea())
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
                Text(L10n.tr("stats.newWords", lang))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            chart
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
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
            .foregroundStyle(Palette.accent.gradient)
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
                value: "\(state.progress.records.count)",
                label: L10n.tr("stats.allTime", lang),
                icon: "square.stack.3d.up"
            )
            StatTile(
                value: "\(state.progress.savedCount)",
                label: L10n.tr("stats.savedWords", lang),
                icon: "bookmark"
            )
            StatTile(
                value: "\(state.progress.totalInPeriod(.week))",
                label: L10n.tr("stats.week", lang),
                icon: "calendar"
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Palette.muted)
            Text(L10n.tr("stats.empty", lang))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .card()
    }
}

private struct StatTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(Palette.accent)
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(Palette.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.card)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }
}
