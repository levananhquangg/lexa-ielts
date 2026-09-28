import Foundation
import Observation
import SwiftUI
import WidgetKit

@Observable
final class AppState {
    let repository: VocabRepository
    let progress: ProgressStore
    private(set) var settings: StudySettings
    var selectedTab: AppTab = .today

    init() {
        self.repository = VocabRepository()
        self.settings = StudySettings.load()
        self.progress = ProgressStore()
    }

    /// Words that match the current band/topic selection.
    var pool: [Word] {
        repository.pool(bands: settings.effectiveBands, topics: settings.topics)
    }

    var todayWord: Word? {
        DailyWord.word(for: .now, pool: pool)
    }

    /// One headline word plus four extra suggestions for today (deduped —
    /// small pools would otherwise repeat words across slots).
    var daySet: [Word] {
        let day = DailyWord.dayIndex(for: .now)
        var seen = Set<String>()
        var result: [Word] = []
        for slot in 0..<5 {
            if let word = DailyWord.word(dayIndex: day, slot: slot, pool: pool),
               seen.insert(word.id).inserted {
                result.append(word)
            }
        }
        return result
    }

    func update(_ mutate: (inout StudySettings) -> Void) {
        var next = settings
        mutate(&next)
        settings = next
        next.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
