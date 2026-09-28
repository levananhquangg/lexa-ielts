import SwiftUI

/// The dictionary-style card used on the Today screen and in word details.
struct WordCard: View {
    let word: Word
    @Binding var revealed: Bool
    let lang: String
    let meaningLang: String
    var showProgressRow: Bool = false

    @Environment(AppState.self) private var state

    private var gloss: String { word.gloss(in: meaningLang) }
    private var secondary: String? { word.secondaryGloss(in: meaningLang) }
    private var saved: Bool { state.progress.isSaved(word.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topRow
            Text(word.w)
                .font(.system(size: 42, weight: .semibold, design: .serif))
                .foregroundStyle(Palette.ink)
                .padding(.top, 14)
            if !word.ipa.isEmpty {
                Text(word.ipa)
                    .font(.callout)
                    .foregroundStyle(Palette.muted)
                    .padding(.top, 2)
            }

            if revealed {
                meaningSection
            } else {
                revealButton
            }

            if showProgressRow {
                progressRow
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    // MARK: - Pieces

    private var topRow: some View {
        HStack(spacing: 8) {
            BandChip(band: word.band)
            if !word.pos.isEmpty {
                Text(PartOfSpeech.label(for: word.pos))
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Palette.hairline.opacity(0.4)))
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            saveButton
        }
    }

    private var saveButton: some View {
        Button {
            Haptics.success()
            state.progress.toggleSaved(word)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: saved ? "bookmark.fill" : "bookmark")
                    .font(.caption)
                Text(L10n.tr(saved ? "action.saved" : "action.save", lang))
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(saved ? Palette.accent.opacity(0.16) : Palette.hairline.opacity(0.4))
            )
            .foregroundStyle(saved ? Palette.accent : Palette.muted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.tr(saved ? "action.saved" : "action.save", lang))
    }

    private var revealButton: some View {
        Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                revealed = true
            }
        } label: {
            Label(L10n.tr("today.reveal", lang), systemImage: "eye")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(Capsule().fill(Palette.accent))
                .foregroundStyle(Color.white)
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
    }

    private var meaningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(Palette.hairline)
                .frame(height: 1)
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr("section.meaning", lang))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Palette.muted)
                Text(gloss)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Palette.ink)
                if let secondary {
                    Text(secondary)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
            }

            if !word.ex.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Palette.accent.opacity(0.55))
                        .frame(width: 3)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.tr("section.example", lang))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Palette.muted)
                        Text(word.ex)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(Palette.ink.opacity(0.85))
                    }
                }
            }

            if !word.topics.isEmpty {
                HStack(spacing: 6) {
                    ForEach(word.topics, id: \.self) { code in
                        if let topic = Topic.byCode(code) {
                            Label(L10n.tr("topic.\(topic.code)", lang), systemImage: topic.symbol)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Palette.hairline.opacity(0.35)))
                                .foregroundStyle(Palette.muted)
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var progressRow: some View {
        if let record = state.progress.record(for: word.id) {
            VStack(alignment: .leading, spacing: 10) {
                Rectangle()
                    .fill(Palette.hairline)
                    .frame(height: 1)
                HStack {
                    Label(
                        L10n.tr("library.seenOn", lang)
                            + " "
                            + record.firstSeen.formatted(date: .numeric, time: .omitted),
                        systemImage: "calendar"
                    )
                    Spacer()
                    Text(L10n.tr("library.times", lang, record.times))
                }
                .font(.caption)
                .foregroundStyle(Palette.muted)
            }
            .padding(.top, 18)
        }
    }
}
