import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var state
    @State private var mode: Mode = .topics

    enum Mode: Hashable { case topics, bands }

    private var lang: String { state.settings.interfaceLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Picker("", selection: $mode) {
                        Text(L10n.tr("explore.topics", lang)).tag(Mode.topics)
                        Text(L10n.tr("explore.bands", lang)).tag(Mode.bands)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    switch mode {
                    case .topics:
                        topicGrid
                    case .bands:
                        bandList
                    }
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle(L10n.tr("tab.explore", lang))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func topicCount(_ code: String) -> Int {
        state.repository.words.filter { $0.topics.contains(code) }.count
    }

    private var topicGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(Topic.all) { topic in
                NavigationLink {
                    WordListScreen(
                        title: L10n.tr("topic.\(topic.code)", lang),
                        topicCode: topic.code
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        AppIconView(Topic.icon(for: topic.code) ?? .grid, size: 21, color: Palette.accent, lineWidth: 1.8)
                            .frame(width: 42, height: 42)
                            .background(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(Palette.accent.opacity(0.13))
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(L10n.tr("topic.\(topic.code)", lang))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Palette.ink)
                            Text(String(format: L10n.tr("explore.count", lang), topicCount(topic.code)))
                                .font(.caption)
                                .foregroundStyle(Palette.muted)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassSurface(cornerRadius: 18)
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    private func bandCount(_ raw: Int) -> Int {
        state.repository.words.filter { $0.band == raw }.count
    }

    private var bandList: some View {
        VStack(spacing: 12) {
            ForEach(Band.allCases) { band in
                NavigationLink {
                    WordListScreen(
                        title: band.label,
                        topicCode: nil,
                        fixedBand: band.rawValue
                    )
                } label: {
                    HStack(spacing: 12) {
                        BandChip(band: band.rawValue)
                        Spacer()
                        Text(String(format: L10n.tr("explore.count", lang), bandCount(band.rawValue)))
                            .font(.subheadline)
                            .foregroundStyle(Palette.muted)
                        AppIconView(.chevronRight, size: 11, color: Palette.muted.opacity(0.7), lineWidth: 2.2)
                    }
                    .padding(16)
                    .glassSurface(cornerRadius: 18)
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

/// Alphabetical word list for one topic or one band.
struct WordListScreen: View {
    @Environment(AppState.self) private var state
    let title: String
    var topicCode: String?
    var fixedBand: Int?

    @State private var selected: Word?

    private var lang: String { state.settings.interfaceLanguage }
    private var meaningLang: String { state.settings.meaningLanguage }

    private var words: [Word] {
        state.repository.words
            .filter { word in
                if let topicCode, !word.topics.contains(topicCode) { return false }
                if let fixedBand, word.band != fixedBand { return false }
                return true
            }
            .sorted { $0.w < $1.w }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(words) { word in
                    Button {
                        Haptics.tap()
                        selected = word
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(word.w)
                                    .font(.system(size: 17, weight: .semibold, design: .serif))
                                    .foregroundStyle(Palette.ink)
                                Text(word.gloss(in: meaningLang))
                                    .font(.caption)
                                    .foregroundStyle(Palette.muted)
                                    .lineLimit(1)
                            }
                            Spacer()
                            BandChip(band: word.band)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { word in
            WordDetailSheet(word: word)
                .presentationDetents([.medium, .large])
        }
    }
}
