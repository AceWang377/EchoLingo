import Foundation

enum AppSecrets {
    static var translationAPIKey: String {
        ProcessInfo.processInfo.environment["ECHOLINGO_TRANSLATION_API_KEY"] ?? ""
    }
}
