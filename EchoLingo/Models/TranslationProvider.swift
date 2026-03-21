import Foundation

enum TranslationProvider: String, CaseIterable, Identifiable {
    case mock
    case libreTranslate
    case googleCloudPlaceholder

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mock:
            return "Mock"
        case .libreTranslate:
            return "LibreTranslate"
        case .googleCloudPlaceholder:
            return "Google Cloud (Soon)"
        }
    }

    var statusDescription: String {
        switch self {
        case .mock:
            return "Best for development, demos, and UI testing. No network cost."
        case .libreTranslate:
            return "Useful for early real-network experiments, but public endpoints may be unstable."
        case .googleCloudPlaceholder:
            return "Planned production-grade provider for a later step once cost controls are ready."
        }
    }

    var isProductionReady: Bool {
        switch self {
        case .mock:
            return false
        case .libreTranslate:
            return false
        case .googleCloudPlaceholder:
            return false
        }
    }
}
