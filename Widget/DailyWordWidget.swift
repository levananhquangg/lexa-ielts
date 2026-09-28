import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline

struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word?
    let saved: Bool
    let lang: String
    let meaningLang: String
}

struct WordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        makeEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    /// One entry per day for the coming week. Word selection is a pure
    /// function of the date, so future entries stay correct without reloads.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var entries = [makeEntry(for: Date())]
        for offset in 1...7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: today) {
                entries.append(makeEntry(for: day))
            }
        }
        let nextReload = calendar.date(byAdding: .day, value: 8, to: today) ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: entries, policy: .after(nextReload)))
    }

    private func makeEntry(for date: Date) -> WordEntry {
        let settings = StudySettings.load()
        let repo = VocabRepository()
        let pool = repo.pool(bands: settings.effectiveBands, topics: settings.topics)
        let word = DailyWord.word(for: date, pool: pool)
        let store = ProgressStore()
        return WordEntry(
            date: date,
            word: word,
            saved: word.map { store.isSaved($0.id) } ?? false,
            lang: settings.interfaceLanguage,
            meaningLang: settings.meaningLanguage
        )
    }
}

// MARK: - Views

struct DailyWordWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WordEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            inlineView
                .containerBackground(for: .widget) { Color.clear }
        case .accessoryCircular:
            circularView
                .containerBackground(for: .widget) { Color.clear }
        case .accessoryRectangular:
            rectangularView
                .containerBackground(for: .widget) { Color.clear }
        default:
            homeView
                .containerBackground(for: .widget) { Palette.paper }
                .widgetURL(URL(string: "lexa://today"))
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let word = entry.word {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(word.w)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 2)
                    SaveButton(entry: entry)
                }
                Text(word.gloss(in: entry.meaningLang))
                    .font(.system(size: 11.5, weight: .medium))
                    .opacity(0.92)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(secondaryText(for: word))
                    .font(.system(size: 9.5))
                    .opacity(0.6)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
                Text(meta(for: word))
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.55)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text(L10n.tr("widget.noWord", entry.lang))
                    .font(.system(size: 12))
                    .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "lexa://today"))
    }

    /// Primary meaning line is the gloss; the secondary line is the other
    /// language so the widget always explains the word twice over.
    private func secondaryText(for word: Word) -> String {
        entry.meaningLang == "en" ? word.vi : word.def
    }

    private func meta(for word: Word) -> String {
        let band = "BAND \(Band(rawValue: word.band)?.label ?? "")"
        if word.ipa.isEmpty { return band }
        return band + "  ·  " + word.ipa
    }

    private var inlineView: some View {
        Group {
            if let word = entry.word {
                Text("\(word.w) · \(word.gloss(in: entry.meaningLang))")
            } else {
                Text("Lexa")
            }
        }
        .font(.system(size: 14, weight: .medium, design: .serif))
        .lineLimit(1)
        .widgetURL(URL(string: "lexa://today"))
    }

    private var circularView: some View {
        VStack(spacing: 0) {
            if let word = entry.word {
                Text(String(word.w.prefix(1)).uppercased())
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                Text(Band(rawValue: word.band)?.shortLabel ?? "")
                    .font(.system(size: 10, weight: .semibold))
                    .monospacedDigit()
                    .opacity(0.7)
            } else {
                Text("L")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .opacity(0.5)
            }
        }
        .widgetURL(URL(string: "lexa://today"))
    }

    private var homeView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Palette.muted)
                    .textCase(.uppercase)
                Spacer()
                if entry.word != nil {
                    SaveButton(entry: entry)
                        .tint(Palette.accent)
                }
            }
            Spacer(minLength: 0)
            if let word = entry.word {
                Text(word.w)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(word.gloss(in: entry.meaningLang))
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                BandChip(band: word.band)
            } else {
                Text(L10n.tr("widget.noWord", entry.lang))
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(4)
    }
}

/// Interactive bookmark button (iOS 17 widgets).
private struct SaveButton: View {
    let entry: WordEntry

    var body: some View {
        Button(intent: SaveTodayIntent()) {
            Image(systemName: entry.saved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Intent

struct SaveTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Save today's word"
    static var description = IntentDescription("Bookmark today's word in your Lexa library.")

    func perform() async throws -> some IntentResult {
        let settings = StudySettings.load()
        let repo = VocabRepository()
        let pool = repo.pool(bands: settings.effectiveBands, topics: settings.topics)
        if let word = DailyWord.word(for: .now, pool: pool) {
            ProgressStore.toggleSavedOnDisk(word)
        }
        return .result()
    }
}

// MARK: - Configuration

struct DailyWordWidget: Widget {
    private static var lang: String { StudySettings.load().interfaceLanguage }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DailyWordWidget", provider: WordProvider()) { entry in
            DailyWordWidgetView(entry: entry)
        }
        .configurationDisplayName(Text(L10n.tr("widget.displayName", Self.lang)))
        .description(Text(L10n.tr("widget.description", Self.lang)))
        .supportedFamilies([
            .systemSmall,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

@main
struct LexaWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyWordWidget()
    }
}
