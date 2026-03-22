import Combine
import Foundation
import UIKit

@MainActor
final class CaptionSessionViewModel: ObservableObject {
    @Published var isListening = false
    @Published var isTranslating = false
    @Published var captionText = "Waiting for speech..."
    @Published var translationText = "Translation will appear here"
    @Published var errorMessage: String?
    @Published var transcriptHistory: [TranscriptSegment] = []
    @Published var sourceLanguage = "en-US"
    @Published var targetLanguage = "zh-CN"
    @Published var translationProvider: TranslationProvider = .mock
    @Published var permissionGuidance: String?
    @Published var translationGuidance: String?
    @Published var focusModeEnabled = false

    let sessionStore: TranscriptSessionStore

    private let speechService: SpeechRecognitionService
    private let translationService: TranslationProviding
    private var latestStableCaption = ""
    private var currentPartialCaption = ""
    private var translationTask: Task<Void, Never>?

    init(
        speechService: SpeechRecognitionService,
        translationService: TranslationProviding,
        sessionStore: TranscriptSessionStore
    ) {
        self.speechService = speechService
        self.translationService = translationService
        self.sessionStore = sessionStore
    }

    convenience init() {
        self.init(
            speechService: SpeechRecognitionService(),
            translationService: TranslationService(),
            sessionStore: .shared
        )
    }

    var transcriptExportText: String {
        transcriptHistory
            .reversed()
            .map {
                "[\($0.timestamp.formatted(date: .omitted, time: .shortened))]\nOriginal: \($0.sourceText)\nTranslated: \($0.translatedText)"
            }
            .joined(separator: "\n\n")
    }

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            Task { await startListening() }
        }
    }

    func toggleFocusMode() {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
            focusModeEnabled.toggle()
        }
    }

    func saveCurrentSession() {
        sessionStore.saveCurrentSession(
            title: transcriptHistory.last?.sourceText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            transcriptHistory: transcriptHistory
        )
    }

    func loadSession(_ session: SavedTranscriptSession) {
        stopListening()
        sourceLanguage = session.sourceLanguage
        targetLanguage = session.targetLanguage
        transcriptHistory = session.items.map { $0.toSegment() }.reversed()
        captionText = transcriptHistory.last?.sourceText ?? "Waiting for speech..."
        translationText = transcriptHistory.last?.translatedText ?? "Translation will appear here"
        latestStableCaption = normalize(transcriptHistory.first?.sourceText ?? "")
        translationGuidance = nil
        permissionGuidance = nil
    }

    func handlePendingSessionSelection() {
        if let pending = sessionStore.consumeSelectedSession() {
            loadSession(pending)
        }
    }

    func deleteSavedSession(_ session: SavedTranscriptSession) {
        sessionStore.deleteSession(session)
    }

    func startListening() async {
        errorMessage = nil
        permissionGuidance = nil
        translationGuidance = nil

        do {
            try await speechService.requestPermissions()
            try speechService.startRecognition(locale: Locale(identifier: sourceLanguage)) { [weak self] text, isFinal in
                guard let self else { return }
                Task { await self.handleRecognition(text: text, isFinal: isFinal) }
            }
            isListening = true
            captionText = "Listening..."
            translationText = translationProvider == .mock ? "Mock translation ready" : "Waiting for translated text..."
            currentPartialCaption = ""
        } catch {
            isListening = false
            errorMessage = error.localizedDescription
            permissionGuidance = guidance(for: error)
        }
    }

    func stopListening() {
        speechService.stopRecognition()
        translationTask?.cancel()
        translationTask = nil
        isListening = false
        isTranslating = false
        currentPartialCaption = ""
    }

    func clearSession() {
        stopListening()
        captionText = "Waiting for speech..."
        translationText = "Translation will appear here"
        transcriptHistory.removeAll()
        latestStableCaption = ""
        currentPartialCaption = ""
        errorMessage = nil
        permissionGuidance = nil
        translationGuidance = nil
    }

    func copyTranscript() {
        UIPasteboard.general.string = transcriptExportText
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func handleRecognition(text: String, isFinal: Bool) async {
        let trimmed = normalize(text)
        guard !trimmed.isEmpty else { return }

        if !isFinal, trimmed == currentPartialCaption {
            return
        }

        currentPartialCaption = trimmed
        captionText = trimmed
        scheduleTranslation(for: trimmed, isFinal: isFinal)
    }

    private func scheduleTranslation(for text: String, isFinal: Bool) {
        translationTask?.cancel()
        translationTask = Task {
            if !isFinal {
                try? await Task.sleep(for: .milliseconds(450))
            }
            guard !Task.isCancelled else { return }
            await translateAndStore(text: text, isFinal: isFinal)
        }
    }

    private func translateAndStore(text: String, isFinal: Bool) async {
        isTranslating = true
        if translationProvider != .mock {
            translationText = "Translating..."
        }

        do {
            let translated = try await translationService.translate(text, from: sourceLanguage, to: targetLanguage, provider: translationProvider)
            guard !Task.isCancelled else { return }
            isTranslating = false
            translationGuidance = nil
            translationText = translated

            guard isFinal else { return }

            let normalizedText = normalize(text)
            guard normalizedText != latestStableCaption else { return }

            latestStableCaption = normalizedText
            currentPartialCaption = ""
            appendOrMergeSegment(sourceText: normalizedText, translatedText: translated)
        } catch {
            guard !Task.isCancelled else { return }
            isTranslating = false
            errorMessage = error.localizedDescription
            translationGuidance = translationFallbackGuidance(for: error)

            if translationProvider == .libreTranslate {
                translationText = "Translation unavailable right now. Switch to Mock or try again later."
            }
        }
    }

    private func appendOrMergeSegment(sourceText: String, translatedText: String) {
        if let first = transcriptHistory.first,
           shouldMerge(sourceText: sourceText, with: first.sourceText) {
            transcriptHistory[0] = TranscriptSegment(
                id: first.id,
                sourceText: sourceText,
                translatedText: translatedText,
                timestamp: Date(),
                isFinal: true
            )
            return
        }

        transcriptHistory.insert(
            TranscriptSegment(
                sourceText: sourceText,
                translatedText: translatedText,
                timestamp: Date(),
                isFinal: true
            ),
            at: 0
        )
    }

    private func shouldMerge(sourceText: String, with existingText: String) -> Bool {
        let newText = normalize(sourceText)
        let oldText = normalize(existingText)
        return newText.hasPrefix(oldText) || oldText.hasPrefix(newText)
    }

    private func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func guidance(for error: Error) -> String? {
        let message = error.localizedDescription.lowercased()
        if message.contains("settings") || message.contains("permission") || message.contains("microphone") || message.contains("speech recognition") {
            return "Open iPhone Settings → EchoLingo, then enable Microphone and Speech Recognition. After that, reopen the app and try again."
        }
        if message.contains("real device") || message.contains("iphone") || message.contains("ipad") {
            return "Run EchoLingo on a real iPhone or iPad. The simulator cannot provide a proper microphone flow for this feature."
        }
        return nil
    }

    private func translationFallbackGuidance(for error: Error) -> String? {
        let message = error.localizedDescription.lowercased()
        if message.contains("timed out") || message.contains("temporarily unavailable") || message.contains("network") {
            return "LibreTranslate public testing can be unstable. If this keeps happening, switch back to Mock in Settings and continue testing the rest of the app flow."
        }
        if message.contains("not connected yet") {
            return "The selected provider is only a placeholder right now. Use Mock or LibreTranslate for this stage of the MVP."
        }
        return "If translation keeps failing, use Mock provider for demos and testing while we wire in a more stable production service."
    }
}
