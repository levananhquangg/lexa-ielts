import Foundation

/// Deterministic daily word rotation shared by the app and the widget.
enum DailyWord {
    /// Whole days since 2024-01-01 in the local calendar.
    static func dayIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let epoch = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? start
        return calendar.dateComponents([.day], from: epoch, to: start).day ?? 0
    }

    /// The `slot`-th suggested word for a given day. Slot 0 is the headline
    /// word shown on the lock screen widget; slots 1...4 are extra picks.
    static func word(dayIndex: Int, slot: Int, pool: [Word]) -> Word? {
        guard !pool.isEmpty else { return nil }
        let ordered = VocabRepository.ordered(pool)
        let base = dayIndex * 5
        return ordered[(base + slot) % ordered.count]
    }

    static func word(for date: Date, slot: Int = 0, pool: [Word]) -> Word? {
        word(dayIndex: dayIndex(for: date), slot: slot, pool: pool)
    }
}
