import SwiftUI

struct LibraryView: View {
    @Environment(AppState.self) private var state
    @State private var query = ""
    @State private var savedOnly = false
    @State private var bandFilter: Int?
    @State private var topicFilter: String?
    @State private var selected: Word?

    private var lang: String { state.settings.interfaceLanguage }
    private var meaningLang: String { state.settings.meaningLanguage }

    private var filtered: [WordProgress] {
        state.progress.records
            .filter { record in
                if savedOnly && !record.saved { return false }
                if let bandFilter, record.band != bandFilter { return false }
                if let topicFilter, !record.topics.contains(topicFilter) { return false }
                if !query.isEmpty {
                    let q = query.lowercased()
                    let matchesWord = record.id.lowercased().contains(q)
                    let matchesGloss = state.repository.word(withID: record.id)?
                        .gloss(in: meaningLang)
                        .lowercased()
                        .contains(q) ?? false
                    if !matchesWord && !matchesGloss { return false }
                }
                return true
            }
            .sorted { $0.lastSeen > $1.lastSeen }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                summary
                filters
                if filtered.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Palette.paper.ignoresSafeArea())
            .navigationTitle(L10n.tr("library.title", lang))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, prompt: Text(L10n.tr("library.search", lang)))
            .sheet(item: $selected) { word in
                WordDetailSheet(word: word)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Sections

    private var summary: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(state.progress.records.count)")
                .font(.system(size: 44, weight: .semibold, design: .serif))
                .foregroundStyle(Palette.ink)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("library.total", lang))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                Label("\(state.progress.savedCount)", systemImage: "bookmark.fill")
                    .font(.caption)
                    .foregroundStyle(Palette.accent)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 14)
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SelectableChip(
                    title: L10n.tr("library.all", lang),
                    selected: !savedOnly
                ) { savedOnly = false }

                SelectableChip(
                    title: L10n.tr("library.saved", lang),
                    selected: savedOnly,
                    systemImage: "bookmark"
                ) { savedOnly = true }

                Menu {
                    Picker(L10n.tr("library.band", lang), selection: $bandFilter) {
                        Text(L10n.tr("library.all", lang)).tag(Int?.none)
                        ForEach(Band.allCases) { band in
                            Text(band.label).tag(Int?.some(band.rawValue))
                        }
                    }
                } label: {
                    FilterMenuLabel(
                        title: L10n.tr("library.band", lang),
                        value: bandFilter.flatMap { Band(rawValue: $0)?.shortLabel }
                    )
                }

                Menu {
                    Picker(L10n.tr("library.topic", lang), selection: $topicFilter) {
                        Text(L10n.tr("library.all", lang)).tag(String?.none)
                        ForEach(Topic.all) { topic in
                            Text(L10n.tr("topic.\(topic.code)", lang)).tag(String?.some(topic.code))
                        }
                    }
                } label: {
                    FilterMenuLabel(
                        title: L10n.tr("library.topic", lang),
                        value: topicFilter.map { L10n.tr("topic.\($0)", lang) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filtered) { record in
                    if let word = state.repository.word(withID: record.id) {
                        Button {
                            Haptics.tap()
                            selected = word
                        } label: {
                            row(record)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Palette.hairline.opacity(0.7))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }

    private func row(_ record: WordProgress) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(record.id)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(Palette.ink)
                Text(record.topics.map { L10n.tr("topic.\($0)", lang) }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(record.lastSeen.formatted(date: .numeric, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Palette.muted)
                HStack(spacing: 5) {
                    if record.saved {
                        Image(systemName: "bookmark.fill")
                            .font(.caption2)
                            .foregroundStyle(Palette.accent)
                    }
                    Text("×\(record.times)")
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Palette.muted)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "books.vertical")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Palette.muted)
            Text(L10n.tr("library.empty.title", lang))
                .font(.headline)
                .foregroundStyle(Palette.ink)
            Text(L10n.tr("library.empty.hint", lang))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .card()
        .padding(20)
    }
}

private struct FilterMenuLabel: View {
    let title: String
    let value: String?

    var body: some View {
        HStack(spacing: 5) {
            Text(value.map { "\(title): \($0)" } ?? title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(value == nil ? Palette.hairline.opacity(0.35) : Palette.accent.opacity(0.16))
        )
        .foregroundStyle(value == nil ? Palette.ink : Palette.accent)
    }
}
