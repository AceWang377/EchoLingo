import Foundation

protocol TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String, provider: TranslationProvider) async throws -> String
}

enum TranslationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case missingAPIKey
    case providerNotReady
    case networkUnavailable
    case requestTimedOut
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Translation URL is invalid."
        case .invalidResponse:
            return "Translation service returned an invalid response."
        case .missingAPIKey:
            return "Translation API key is missing."
        case .providerNotReady:
            return "This translation provider is not connected yet. Use Mock or LibreTranslate for now."
        case .networkUnavailable:
            return "Network connection appears unavailable. Please check your connection and try again."
        case .requestTimedOut:
            return "Translation request timed out. Try again or switch back to Mock mode."
        case .serviceUnavailable:
            return "The translation service is temporarily unavailable. Try again later or use Mock mode."
        }
    }
}

struct TranslationService: TranslationProviding {
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String, provider: TranslationProvider) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        switch provider {
        case .mock:
            return mockTranslate(trimmed, to: targetLanguage)
        case .libreTranslate:
            return try await translateWithLibreTranslate(trimmed, from: sourceLanguage, to: targetLanguage)
        case .googleCloudPlaceholder:
            throw TranslationError.providerNotReady
        }
    }

    private func mockTranslate(_ text: String, to targetLanguage: String) -> String {
        switch targetLanguage {
        case "zh-CN":
            return "[中文示例] \(text)"
        case "en-US":
            return "[English mock] \(text)"
        case "es-ES":
            return "[Español simulado] \(text)"
        default:
            return "[\(targetLanguage.uppercased())] \(text)"
        }
    }

    private func translateWithLibreTranslate(_ text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        guard let url = URL(string: "https://libretranslate.com/translate") else {
            throw TranslationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 8

        let payload = LibreTranslateRequest(
            q: text,
            source: languageCode(from: sourceLanguage),
            target: languageCode(from: targetLanguage),
            format: "text",
            api_key: AppSecrets.translationAPIKey.isEmpty ? nil : AppSecrets.translationAPIKey
        )
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TranslationError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200..<300:
                let decoded = try JSONDecoder().decode(LibreTranslateResponse.self, from: data)
                return decoded.translatedText
            case 408:
                throw TranslationError.requestTimedOut
            case 429, 500...599:
                throw TranslationError.serviceUnavailable
            default:
                throw TranslationError.invalidResponse
            }
        } catch let error as TranslationError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw TranslationError.requestTimedOut
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                throw TranslationError.networkUnavailable
            default:
                throw TranslationError.serviceUnavailable
            }
        } catch {
            throw TranslationError.serviceUnavailable
        }
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
