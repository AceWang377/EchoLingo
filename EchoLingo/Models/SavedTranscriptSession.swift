import Foundation

struct SavedTranscriptSession: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    let createdAt: Date
    var updatedAt: Date
    var sourceLanguage: String
    var targetLanguage: String
    var items: [TranscriptSegmentRecord]

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sourceLanguage: String,
        targetLanguage: String,
        items: [TranscriptSegmentRecord]
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.items = items
    }
}

struct TranscriptSegmentRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var sourceText: String
    var translatedText: String
    let timestamp: Date
    let isFinal: Bool

    init(from segment: TranscriptSegment) {
        self.id = segment.id
        self.sourceText = segment.sourceText
        self.translatedText = segment.translatedText
        self.timestamp = segment.timestamp
        self.isFinal = segment.isFinal
    }

    func toSegment() -> TranscriptSegment {
        TranscriptSegment(
            id: id,
            sourceText: sourceText,
            translatedText: translatedText,
            timestamp: timestamp,
            isFinal: isFinal
        )
    }
}
