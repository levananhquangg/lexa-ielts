import Foundation

enum AppGroup {
    static let identifier = "group.com.lexa.vocab"

    /// Falls back to the app's own documents directory when the group is not
    /// yet configured (e.g. running without signing), so the app still works.
    static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}
