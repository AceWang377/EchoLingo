import Foundation

struct AppPreferences {
    var sourceLanguage: String = "en-US"
    var targetLanguage: String = "zh-CN"
    var translationProvider: TranslationProvider = .mock

    static let `default` = AppPreferences()
}
