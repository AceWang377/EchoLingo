import Foundation

protocol TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String, provider: TranslationProvider) async throws -> String
}

enum TranslationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Translation URL is invalid."
        case .invalidResponse:
            return "Translation service returned an invalid response."
        case .missingAPIKey:
            return "Translation API key is missing."
        }
    }
}

struct TranslationService: TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String, provider: TranslationProvider) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        switch provider {
        case .mock:
            return "[\(targetLanguage.uppercased())] \(trimmed)"
        case .libreTranslate:
            return try await translateWithLibreTranslate(trimmed, from: sourceLanguage, to: targetLanguage)
        }
    }

    private func translateWithLibreTranslate(_ text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        guard let url = URL(string: "https://libretranslate.com/translate") else {
            throw TranslationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = LibreTranslateRequest(
            q: text,
            source: languageCode(from: sourceLanguage),
            target: languageCode(from: targetLanguage),
            format: "text",
            api_key: AppSecrets.translationAPIKey.isEmpty ? nil : AppSecrets.translationAPIKey
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw TranslationError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(LibreTranslateResponse.self, from: data)
        return decoded.translatedText
    }

    private func languageCode(from localeIdentifier: String) -> String {
        if let code = localeIdentifier.split(separator: "-").first {
            return code.lowercased()
        }
        return localeIdentifier.lowercased()
    }
}

private struct LibreTranslateRequest: Codable {
    let q: String
    let source: String
    let target: String
    let format: String
    let api_key: String?
}

private struct LibreTranslateResponse: Codable {
    let translatedText: String
}
