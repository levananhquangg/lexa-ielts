import Foundation

/// Read-only access to the bundled vocabulary dataset.
final class VocabRepository {
    static let shared = VocabRepository()

    private(set) var words: [Word] = []
    private var byID: [String: Word] = [:]

    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "vocab", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bank = try? JSONDecoder().decode(WordBank.self, from: data) else { return }
        words = bank.words
        byID = Dictionary(uniqueKeysWithValues: words.map { ($0.id, $0) })
    }

    func word(withID id: String) -> Word? {
        byID[id]
    }

    /// Words matching the study filters. Empty sets mean "no restriction".
    func pool(bands: Set<Int>, topics: Set<String>) -> [Word] {
        words.filter { word in
            let bandOK = bands.isEmpty || bands.contains(word.band)
            let topicOK = topics.isEmpty || !Set(word.topics).isDisjoint(with: topics)
            return bandOK && topicOK
        }
    }

    /// A stable, dependency-free order so the app and the widget pick the
    /// same word for the same day without exchanging state.
    static func stableHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }

    static func ordered(_ pool: [Word]) -> [Word] {
        pool.sorted { stableHash($0.id) < stableHash($1.id) }
    }
}
