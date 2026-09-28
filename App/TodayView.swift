import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var state
    @State private var revealed = false

    private var lang: String { state.settings.interfaceLanguage }
    private var meaningLang: String { state.settings.meaningLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if let word = state.todayWord {
                        WordCard(word: word, revealed: $revealed, lang: lang, meaningLang: meaningLang)
                        if state.daySet.count > 1 {
                            moreSection
                        }
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Palette.paper.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Lexa")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Palette.ink)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month().year()))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
            Text(L10n.tr("today.header", lang))
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var moreSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.tr("today.more", lang))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Palette.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(state.daySet.dropFirst().enumerated()), id: \.element.id) { _, word in
                        NavigationLink {
                            WordDetailScreen(word: word)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(word.w)
                                    .font(.system(size: 17, weight: .semibold, design: .serif))
                                    .foregroundStyle(Palette.ink)
                                Text(word.gloss(in: meaningLang))
                                    .font(.caption)
                                    .foregroundStyle(Palette.muted)
                                    .lineLimit(1)
                                BandChip(band: word.band)
                            }
                            .padding(14)
                            .frame(width: 152, alignment: .leading)
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
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Palette.muted)
            Text(L10n.tr("today.empty.title", lang))
                .font(.headline)
                .foregroundStyle(Palette.ink)
            Text(L10n.tr("today.empty.hint", lang))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
            Button {
                state.selectedTab = .settings
            } label: {
                Text(L10n.tr("tab.settings", lang))
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Palette.accent))
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .card()
    }
}

/// Detail screen pushed from the horizontal suggestions on Today.
struct WordDetailScreen: View {
    @Environment(AppState.self) private var state
    let word: Word
    @State private var revealed = true

    var body: some View {
        ScrollView {
            WordCard(
                word: word,
                revealed: $revealed,
                lang: state.settings.interfaceLanguage,
                meaningLang: state.settings.meaningLanguage,
                showProgressRow: true
            )
            .padding(20)
        }
        .background(Palette.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { state.progress.recordSeen(word) }
    }
}

/// Sheet shown from the Library and Explore lists.
struct WordDetailSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    let word: Word
    @State private var revealed = true

    var body: some View {
        NavigationStack {
            ScrollView {
                WordCard(
                    word: word,
                    revealed: $revealed,
                    lang: state.settings.interfaceLanguage,
                    meaningLang: state.settings.meaningLanguage,
                    showProgressRow: true
                )
                .padding(20)
            }
            .background(Palette.paper.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Palette.muted)
                    }
                }
            }
        }
        .task { state.progress.recordSeen(word) }
    }
}
