import SwiftUI
import WidgetKit

@main
struct LexaApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(state)
                .tint(Palette.accent)
                .task { recordTodaysWordIfNeeded() }
                .onOpenURL { url in
                    guard url.scheme == "lexa" else { return }
                    state.selectedTab = .today
                }
        }
    }

    /// The daily word counts as "appeared" the first time the app runs that day.
    private func recordTodaysWordIfNeeded() {
        guard let word = state.todayWord else { return }
        let today = DailyWord.dayIndex(for: .now)
        let key = "last.recorded.day.v1"
        if AppGroup.defaults.integer(forKey: key) != today {
            state.progress.recordSeen(word)
            AppGroup.defaults.set(today, forKey: key)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
