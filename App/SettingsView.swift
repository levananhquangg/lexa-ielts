import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @State private var confirmReset = false

    private var lang: String { state.settings.interfaceLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    languageCard
                    bandCard
                    topicCard
                    widgetCard
                    dataCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Palette.paper.ignoresSafeArea())
            .navigationTitle(L10n.tr("tab.settings", lang))
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                L10n.tr("settings.reset.confirm", lang),
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("settings.reset.button", lang), role: .destructive) {
                    state.progress.reset()
                    Haptics.success()
                }
                Button(L10n.tr("common.cancel", lang), role: .cancel) {}
            }
        }
    }

    // MARK: - Cards

    private var languageCard: some View {
        settingsCard(L10n.tr("settings.meaning", lang)) {
            languagePicker(
                value: state.settings.meaningLanguage,
                onChange: { value in state.update { $0.meaningLanguage = value } }
            )
            sectionCaption(L10n.tr("settings.interface", lang))
            languagePicker(
                value: state.settings.interfaceLanguage,
                onChange: { value in state.update { $0.interfaceLanguage = value } }
            )
        }
    }

    private func languagePicker(value: String, onChange: @escaping (String) -> Void) -> some View {
        Picker("", selection: Binding(get: { value }, set: { onChange($0) })) {
            Text(L10n.tr("common.language.vi", "vi")).tag("vi")
            Text(L10n.tr("common.language.en", "en")).tag("en")
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    private var bandCard: some View {
        settingsCard(L10n.tr("settings.band", lang)) {
            FlowLayout(spacing: 8) {
                ForEach(Band.allCases) { band in
                    SelectableChip(
                        title: band.label,
                        selected: state.settings.effectiveBands.contains(band.rawValue)
                    ) {
                        toggleBand(band.rawValue)
                    }
                }
            }
            sectionCaption(
                String(format: L10n.tr("explore.count", lang), state.pool.count)
            )
        }
    }

    private var topicCard: some View {
        settingsCard(L10n.tr("settings.topics", lang)) {
            FlowLayout(spacing: 8) {
                SelectableChip(
                    title: L10n.tr("settings.allTopics", lang),
                    selected: state.settings.isAllTopics,
                    systemImage: "circle.grid.2x2"
                ) {
                    state.update { $0.topics = [] }
                }
                ForEach(Topic.all) { topic in
                    SelectableChip(
                        title: L10n.tr("topic.\(topic.code)", lang),
                        selected: state.settings.topics.contains(topic.code)
                    ) {
                        toggleTopic(topic.code)
                    }
                }
            }
        }
    }

    private var widgetCard: some View {
        settingsCard(L10n.tr("settings.widget", lang)) {
            Text(L10n.tr("settings.widget.hint", lang))
                .font(.footnote)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Haptics.tap()
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Label(L10n.tr("settings.widget.refresh", lang), systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Palette.hairline.opacity(0.4)))
                    .foregroundStyle(Palette.ink)
            }
            .buttonStyle(.plain)
        }
    }

    private var dataCard: some View {
        settingsCard(L10n.tr("settings.data", lang)) {
            Text(String(format: L10n.tr("settings.data.credit", lang), state.repository.words.count))
                .font(.footnote)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button(role: .destructive) {
                confirmReset = true
            } label: {
                Label(L10n.tr("settings.reset", lang), systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
    }

    // MARK: - Helpers

    private func settingsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Palette.muted)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func sectionCaption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Palette.muted)
    }

    private func toggleBand(_ raw: Int) {
        state.update { settings in
            if settings.effectiveBands.contains(raw) {
                if settings.bands.isEmpty {
                    // Everything was selected; keep only the other bands.
                    let others = Set(Band.allCases.map(\.rawValue)).subtracting([raw])
                    settings.bands = others
                } else if settings.bands.count > 1 {
                    settings.bands.remove(raw)
                }
            } else {
                settings.bands.insert(raw)
            }
        }
    }

    private func toggleTopic(_ code: String) {
        state.update { settings in
            if settings.topics.contains(code) {
                settings.topics.remove(code)
            } else if settings.topics.isEmpty {
                settings.topics = [code]
            } else {
                settings.topics.insert(code)
            }
        }
    }
}
