import Foundation

@MainActor
final class CaptionSessionViewModel: ObservableObject {
    @Published var isListening = false
    @Published var captionText = "Waiting for speech..."
    @Published var translationText = "Translation will appear here"
    @Published var errorMessage: String?
    @Published var transcriptHistory: [TranscriptSegment] = []
    @Published var sourceLanguage = "en-US"
    @Published var targetLanguage = "zh-CN"

    private let speechService: SpeechRecognitionService
    private let translationService: TranslationProviding
    private var latestStableCaption = ""

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
        isListening = false
    }

    private func handleRecognition(text: String, isFinal: Bool) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        captionText = trimmed

        do {
            let translated = try await translationService.translate(trimmed, from: sourceLanguage, to: targetLanguage)
            translationText = translated

            if isFinal && trimmed != latestStableCaption {
                latestStableCaption = trimmed
                transcriptHistory.insert(
                    TranscriptSegment(
                        sourceText: trimmed,
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
