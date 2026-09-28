import SwiftUI

enum AppTab: Hashable {
    case today, explore, library, stats, settings
}

struct RootView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        let lang = state.settings.interfaceLanguage
        TabView(selection: $state.selectedTab) {
            TodayView()
                .tabItem { Label(L10n.tr("tab.today", lang), systemImage: "sun.max") }
                .tag(AppTab.today)

            ExploreView()
                .tabItem { Label(L10n.tr("tab.explore", lang), systemImage: "square.grid.2x2") }
                .tag(AppTab.explore)

            LibraryView()
                .tabItem { Label(L10n.tr("tab.library", lang), systemImage: "books.vertical") }
                .tag(AppTab.library)

            StatsView()
                .tabItem { Label(L10n.tr("tab.stats", lang), systemImage: "chart.bar") }
                .tag(AppTab.stats)

            SettingsView()
                .tabItem { Label(L10n.tr("tab.settings", lang), systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
    }
}
