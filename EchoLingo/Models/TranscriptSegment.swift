import Foundation

struct TranscriptSegment: Identifiable, Equatable {
    let id: UUID
    var sourceText: String
    var translatedText: String
    let timestamp: Date
    let isFinal: Bool

    init(
        id: UUID = UUID(),
        sourceText: String,
        translatedText: String,
        timestamp: Date = Date(),
        isFinal: Bool
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.timestamp = timestamp
        self.isFinal = isFinal
    }
}
