import Foundation

enum TranslationProvider: String, CaseIterable, Identifiable {
    case mock
    case libreTranslate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mock: return "Mock"
        case .libreTranslate: return "LibreTranslate"
        }
    }
}
