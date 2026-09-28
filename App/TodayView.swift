import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var state
    @State private var revealed = false
    @State private var appeared = false

    private var lang: String { state.settings.interfaceLanguage }
    private var meaningLang: String { state.settings.meaningLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if let word = state.todayWord {
                        WordCard(word: word, revealed: $revealed, lang: lang, meaningLang: meaningLang)
                            .offset(y: appeared ? 0 : 30)
                            .opacity(appeared ? 1 : 0)
                        if state.daySet.count > 1 {
                            moreSection
                                .offset(y: appeared ? 0 : 34)
                                .opacity(appeared ? 1 : 0)
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Lexa")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Palette.ink)
                }
            }
        }
        .onChange(of: state.splashDone) { _, done in
            if done { animateIn() }
        }
        .task {
            if state.splashDone { animateIn() }
        }
    }

    private func animateIn() {
        guard !appeared else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.05)) {
            appeared = true
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
                .animation(nil, value: appeared)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(state.daySet.dropFirst().enumerated()), id: \.element.id) { index, word in
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
                            .glassSurface(cornerRadius: 18)
                        }
                        .buttonStyle(PressableStyle())
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.12 + Double(index) * 0.06), value: appeared)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            AppIconView(.compass, size: 34, color: Palette.muted, lineWidth: 1.5)
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
                    .background(Capsule().fill(Palette.accentGradient))
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(PressableStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassCard()
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        AppIconView(.xmark, size: 14, color: Palette.muted, lineWidth: 2.2)
                    }
                }
            }
        }
        .task { state.progress.recordSeen(word) }
    }
}
