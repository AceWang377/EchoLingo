import Foundation

struct TranscriptSegment: Identifiable, Equatable {
    let id = UUID()
    let sourceText: String
    let translatedText: String
    let timestamp: Date
    let isFinal: Bool
}
