import Foundation
import UIKit

@MainActor
final class CaptionSessionViewModel: ObservableObject {
    @Published var isListening = false
    @Published var captionText = "Waiting for speech..."
    @Published var translationText = "Translation will appear here"
    @Published var errorMessage: String?
    @Published var transcriptHistory: [TranscriptSegment] = []
    @Published var sourceLanguage = "en-US"
    @Published var targetLanguage = "zh-CN"
    @Published var translationProvider: TranslationProvider = .mock

    private let speechService: SpeechRecognitionService
    private let translationService: TranslationProviding
    private var latestStableCaption = ""
    private var translationTask: Task<Void, Never>?

    init(
        speechService: SpeechRecognitionService = SpeechRecognitionService(),
        translationService: TranslationProviding = TranslationService()
    ) {
        self.speechService = speechService
        self.translationService = translationService
    }

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            Task { await startListening() }
        }
    }

    func startListening() async {
        errorMessage = nil

        do {
            try await speechService.requestPermissions()
            try speechService.startRecognition(locale: Locale(identifier: sourceLanguage)) { [weak self] text, isFinal in
                guard let self else { return }
                Task { await self.handleRecognition(text: text, isFinal: isFinal) }
            }
            isListening = true
            captionText = "Listening..."
            translationText = "Waiting for translated text..."
        } catch {
            errorMessage = error.localizedDescription
            isListening = false
        }
    }

    func stopListening() {
        speechService.stopRecognition()
        translationTask?.cancel()
        isListening = false
    }

    func clearSession() {
        stopListening()
        captionText = "Waiting for speech..."
        translationText = "Translation will appear here"
        transcriptHistory.removeAll()
        latestStableCaption = ""
        errorMessage = nil
    }

    func copyTranscript() {
        let text = transcriptHistory
            .reversed()
            .map { "Original: \($0.sourceText)\nTranslated: \($0.translatedText)" }
            .joined(separator: "\n\n")
        UIPasteboard.general.string = text
    }

    private func handleRecognition(text: String, isFinal: Bool) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

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
        do {
            let translated = try await translationService.translate(text, from: sourceLanguage, to: targetLanguage, provider: translationProvider)
            guard !Task.isCancelled else { return }
            translationText = translated

            if isFinal && text != latestStableCaption {
                latestStableCaption = text
                transcriptHistory.insert(
                    TranscriptSegment(
                        sourceText: text,
                        translatedText: translated,
                        timestamp: Date(),
                        isFinal: true
                    ),
                    at: 0
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
