import Foundation
import Observation

struct WordProgress: Codable, Identifiable, Equatable {
    let id: String
    var band: Int
    var topics: [String]
    var firstSeen: Date
    var lastSeen: Date
    var times: Int
    var saved: Bool
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week, month, quarter, year

    var id: String { rawValue }
}

struct StatsBucket: Identifiable, Equatable {
    let date: Date
    let count: Int
    var id: Date { date }
}

/// Archive of every word that has appeared for the user, persisted as JSON
/// inside the App Group container. Both the app and the widget read it.
@Observable
final class ProgressStore {
    private(set) var records: [WordProgress] = []

    private var fileURL: URL {
        AppGroup.containerURL.appendingPathComponent("progress.json")
    }

    init() {
        load()
    }

    // MARK: - Persistence

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([WordProgress].self, from: data) else { return }
        records = decoded
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Recording

    /// Marks a word as appeared. Repeats on the same day do not bump the count.
    func recordSeen(_ word: Word, on date: Date = Date()) {
        if let index = records.firstIndex(where: { $0.id == word.id }) {
            if !Calendar.current.isDate(records[index].lastSeen, inSameDayAs: date) {
                records[index].times += 1
                records[index].lastSeen = date
            }
        } else {
            records.append(WordProgress(
                id: word.id,
                band: word.band,
                topics: word.topics,
                firstSeen: date,
                lastSeen: date,
                times: 1,
                saved: false
            ))
        }
        persist()
    }

    func toggleSaved(_ word: Word, on date: Date = Date()) {
        if let index = records.firstIndex(where: { $0.id == word.id }) {
            records[index].saved.toggle()
        } else {
            records.append(WordProgress(
                id: word.id,
                band: word.band,
                topics: word.topics,
                firstSeen: date,
                lastSeen: date,
                times: 1,
                saved: true
            ))
        }
        persist()
    }

    func setAllSaved(_ words: [Word], saved: Bool) {
        for word in words {
            if let index = records.firstIndex(where: { $0.id == word.id }) {
                records[index].saved = saved
            } else if saved {
                records.append(WordProgress(
                    id: word.id,
                    band: word.band,
                    topics: word.topics,
                    firstSeen: Date(),
                    lastSeen: Date(),
                    times: 1,
                    saved: true
                ))
            }
        }
        persist()
    }

    func reset() {
        records = []
        persist()
    }

    // MARK: - Lookup

    func record(for id: String) -> WordProgress? {
        records.first { $0.id == id }
    }

    func isSaved(_ id: String) -> Bool {
        record(for: id)?.saved ?? false
    }

    var savedCount: Int {
        records.filter(\.saved).count
    }

    /// Convenience for callers outside the UI (the widget's save button).
    static func toggleSavedOnDisk(_ word: Word) {
        let store = ProgressStore()
        store.toggleSaved(word)
    }

    // MARK: - Stats

    func count(firstSeenIn interval: Range<Date>) -> Int {
        records.filter { interval.contains($0.firstSeen) }.count
    }

    func count(from start: Date, to end: Date) -> Int {
        records.filter { $0.firstSeen >= start && $0.firstSeen < end }.count
    }

    func buckets(for period: StatsPeriod, now: Date = Date(), calendar: Calendar = .current) -> [StatsBucket] {
        let today = calendar.startOfDay(for: now)
        switch period {
        case .week:
            return dailyBuckets(days: 7, anchor: today, calendar: calendar)
        case .month:
            return dailyBuckets(days: 30, anchor: today, calendar: calendar)
        case .quarter:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            return (0..<13).reversed().compactMap { offset in
                guard let start = calendar.date(byAdding: .weekOfYear, value: -offset, to: weekStart),
                      let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) else { return nil }
                return StatsBucket(date: start, count: count(firstSeenIn: start..<end))
            }
        case .year:
            let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
            return (0..<12).reversed().compactMap { offset in
                guard let start = calendar.date(byAdding: .month, value: -offset, to: monthStart),
                      let end = calendar.date(byAdding: .month, value: 1, to: start) else { return nil }
                return StatsBucket(date: start, count: count(firstSeenIn: start..<end))
            }
        }
    }

    func totalInPeriod(_ period: StatsPeriod, now: Date = Date(), calendar: Calendar = .current) -> Int {
        let today = calendar.startOfDay(for: now)
        switch period {
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -6, to: today) else { return 0 }
            return count(from: start, to: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
        case .month:
            guard let start = calendar.date(byAdding: .day, value: -29, to: today) else { return 0 }
            return count(from: start, to: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
        case .quarter:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            guard let start = calendar.date(byAdding: .weekOfYear, value: -12, to: weekStart) else { return 0 }
            return count(from: start, to: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
        case .year:
            let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
            guard let start = calendar.date(byAdding: .month, value: -11, to: monthStart) else { return 0 }
            return count(from: start, to: calendar.date(byAdding: .day, value: 1, to: today) ?? today)
        }
    }

    private func dailyBuckets(days: Int, anchor: Date, calendar: Calendar) -> [StatsBucket] {
        (0..<days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: anchor),
                  let end = calendar.date(byAdding: .day, value: 1, to: day) else { return nil }
            return StatsBucket(date: day, count: count(firstSeenIn: day..<end))
        }
    }
}
