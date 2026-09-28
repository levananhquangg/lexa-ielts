import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id: String
    let w: String
    let ipa: String
    let pos: String
    let band: Int
    let topics: [String]
    let def: String
    let ex: String
    let vi: String
}

struct WordBank: Codable {
    let version: Int
    let words: [Word]
}

enum Band: Int, CaseIterable, Identifiable {
    case b55 = 5
    case b65 = 6
    case b75 = 7
    case b85 = 8

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .b55: return "5.0–5.5"
        case .b65: return "6.0–6.5"
        case .b75: return "7.0–7.5"
        case .b85: return "8.0–9.0"
        }
    }

    var shortLabel: String {
        switch self {
        case .b55: return "5+"
        case .b65: return "6+"
        case .b75: return "7+"
        case .b85: return "8+"
        }
    }
}

struct Topic: Identifiable, Hashable {
    let code: String
    let symbol: String

    var id: String { code }

    static let all: [Topic] = [
        Topic(code: "education", symbol: "graduationcap"),
        Topic(code: "work", symbol: "briefcase"),
        Topic(code: "technology", symbol: "cpu"),
        Topic(code: "environment", symbol: "leaf"),
        Topic(code: "health", symbol: "heart"),
        Topic(code: "society", symbol: "person.3"),
        Topic(code: "money", symbol: "banknote"),
        Topic(code: "media", symbol: "megaphone"),
        Topic(code: "travel", symbol: "airplane"),
        Topic(code: "culture", symbol: "paintpalette"),
        Topic(code: "science", symbol: "atom"),
        Topic(code: "law", symbol: "scalemass"),
        Topic(code: "government", symbol: "building.columns"),
        Topic(code: "urban", symbol: "building.2"),
        Topic(code: "food", symbol: "fork.knife"),
        Topic(code: "global", symbol: "globe"),
    ]

    static func byCode(_ code: String) -> Topic? {
        all.first { $0.code == code }
    }

    static func icon(for code: String) -> AppIcon? {
        switch code {
        case "education": return .graduation
        case "work": return .briefcase
        case "technology": return .cpu
        case "environment": return .leaf
        case "health": return .heart
        case "society": return .users
        case "money": return .banknote
        case "media": return .megaphone
        case "travel": return .plane
        case "culture": return .palette
        case "science": return .atom
        case "law": return .scales
        case "government": return .columns
        case "urban": return .skyline
        case "food": return .food
        case "global": return .globe
        default: return nil
        }
    }
}

extension Word {
    /// Primary meaning in the requested language ("vi" or "en").
    func gloss(in language: String) -> String {
        language == "en" ? def : vi
    }

    /// Secondary meaning shown under the primary one (English definition
    /// when Vietnamese is selected).
    func secondaryGloss(in language: String) -> String? {
        language == "en" ? nil : def
    }
}

enum PartOfSpeech {
    /// Compact display form for the POS tag stored in the dataset.
    static func label(for raw: String) -> String {
        switch raw {
        case "n": return "noun"
        case "v": return "verb"
        case "adj": return "adj"
        case "adv": return "adv"
        case "prep": return "prep"
        default: return raw
        }
    }
}
