import SwiftUI

enum AppTab: Hashable {
    case today, explore, library, stats, settings
}

struct RootView: View {
    @Environment(AppState.self) private var state

    private var tabs: [(tab: AppTab, icon: AppIcon, label: String)] {
        let lang = state.settings.interfaceLanguage
        return [
            (.today, .sun, L10n.tr("tab.today", lang)),
            (.explore, .compass, L10n.tr("tab.explore", lang)),
            (.library, .book, L10n.tr("tab.library", lang)),
            (.stats, .chart, L10n.tr("tab.stats", lang)),
            (.settings, .sliders, L10n.tr("tab.settings", lang)),
        ]
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            // Pages stay alive so scroll positions survive tab switches.
            ZStack {
                TodayView().opacity(state.selectedTab == .today ? 1 : 0).allowsHitTesting(state.selectedTab == .today)
                ExploreView().opacity(state.selectedTab == .explore ? 1 : 0).allowsHitTesting(state.selectedTab == .explore)
                LibraryView().opacity(state.selectedTab == .library ? 1 : 0).allowsHitTesting(state.selectedTab == .library)
                StatsView().opacity(state.selectedTab == .stats ? 1 : 0).allowsHitTesting(state.selectedTab == .stats)
                SettingsView().opacity(state.selectedTab == .settings ? 1 : 0).allowsHitTesting(state.selectedTab == .settings)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                GlassTabBar(selection: bindSelection, tabs: tabs)
            }
        }
        .preferredColorScheme(state.appearanceScheme)
        .overlay {
            if !state.splashDone {
                SplashView()
                    .transition(.opacity.combined(with: .scale(1.04)))
                    .zIndex(10)
            }
        }
    }

    private var bindSelection: Binding<AppTab> {
        Binding(
            get: { state.selectedTab },
            set: { newValue in
                guard newValue != state.selectedTab else { return }
                Haptics.tap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    state.selectedTab = newValue
                }
            }
        )
    }
}

/// Floating glass tab bar with Lexa's own icon set.
struct GlassTabBar: View {
    @Binding var selection: AppTab
    let tabs: [(tab: AppTab, icon: AppIcon, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tab) { item in
                let selected = selection == item.tab
                Button {
                    selection = item.tab
                } label: {
                    VStack(spacing: 3) {
                        AppIconView(item.icon, size: 21, color: selected ? Palette.accent : Palette.muted, lineWidth: selected ? 2 : 1.6)
                            .scaleEffect(selected ? 1.08 : 1)
                            .shadow(color: selected ? Palette.accent.opacity(0.45) : .clear, radius: 6, y: 1)
                        Text(item.label)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(selected ? Palette.accent : Palette.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel(item.label)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 9)
        .glassSurface(cornerRadius: 26)
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
}
