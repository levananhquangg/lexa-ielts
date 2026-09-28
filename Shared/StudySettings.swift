import Foundation

/// Study preferences. Stored in the App Group so the widget follows the
/// exact same band/topic/language selection as the app.
struct StudySettings: Codable, Equatable {
    var bands: Set<Int> = []
    var topics: Set<String> = []
    var meaningLanguage: String = StudySettings.defaultLanguage()
    var interfaceLanguage: String = StudySettings.defaultLanguage()

    static let storageKey = "study.settings.v1"

    /// Empty sets mean "everything". These helpers normalise access.
    var effectiveBands: Set<Int> {
        bands.isEmpty ? Set(Band.allCases.map(\.rawValue)) : bands
    }

    var isAllTopics: Bool { topics.isEmpty }

    static func defaultLanguage() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.lowercased().hasPrefix("vi") ? "vi" : "en"
    }
}

extension StudySettings {
    static func load() -> StudySettings {
        guard let data = AppGroup.defaults.data(forKey: storageKey),
              let settings = try? JSONDecoder().decode(StudySettings.self, from: data) else {
            return StudySettings()
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            AppGroup.defaults.set(data, forKey: Self.storageKey)
        }
    }
}
