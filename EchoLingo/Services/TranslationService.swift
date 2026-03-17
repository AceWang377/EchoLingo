import Foundation

protocol TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String
}

struct TranslationService: TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        // V1 placeholder. Replace with a real translation API or on-device translation engine next.
        return "[\(targetLanguage.uppercased())] \(trimmed)"
    }
}
