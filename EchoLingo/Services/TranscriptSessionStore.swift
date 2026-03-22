import Combine
import Foundation

@MainActor
final class TranscriptSessionStore: ObservableObject {
    static let shared = TranscriptSessionStore()

    @Published private(set) var sessions: [SavedTranscriptSession] = []
    @Published var selectedSession: SavedTranscriptSession?

    private let storageKeyPrefix = "echolingo.saved.sessions"
    private var currentOwnerKey = "guest"

    init() {
        switchUser(to: AuthViewModel.shared.storageUserKey)
    }

    func switchUser(to ownerKey: String) {
        currentOwnerKey = ownerKey
        load()
    }

    func saveCurrentSession(title: String?, sourceLanguage: String, targetLanguage: String, transcriptHistory: [TranscriptSegment]) {
        guard !transcriptHistory.isEmpty else { return }

        let normalizedTitle = (title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? title! : transcriptHistory.last?.sourceText ?? "Session")
        let clippedTitle = String(normalizedTitle.prefix(40))
        let record = SavedTranscriptSession(
            title: clippedTitle,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            items: transcriptHistory.reversed().map(TranscriptSegmentRecord.init)
        )

        sessions.insert(record, at: 0)
        persist()
    }

    func selectSession(_ session: SavedTranscriptSession) {
        selectedSession = session
    }

    func consumeSelectedSession() -> SavedTranscriptSession? {
        let session = selectedSession
        selectedSession = nil
        return session
    }

    func deleteSession(_ session: SavedTranscriptSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: fullStorageKey) else {
            sessions = []
            return
        }
        if let decoded = try? JSONDecoder().decode([SavedTranscriptSession].self, from: data) {
            sessions = decoded.sorted { $0.updatedAt > $1.updatedAt }
        } else {
            sessions = []
        }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: fullStorageKey)
        }
    }

    private var fullStorageKey: String {
        "\(storageKeyPrefix).\(currentOwnerKey)"
    }
}
