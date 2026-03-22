import SwiftUI

struct SessionsView: View {
    @ObservedObject var sessionStore: TranscriptSessionStore

    var body: some View {
        NavigationStack {
            Group {
                if sessionStore.sessions.isEmpty {
                    ContentUnavailableView(
                        "No saved sessions",
                        systemImage: "tray",
                        description: Text("Save a transcript session from the Home tab and it will appear here for later review.")
                    )
                } else {
                    List {
                        Section("Saved Sessions") {
                            ForEach(sessionStore.sessions) { session in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text(session.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(session.sourceLanguage) → \(session.targetLanguage) · \(session.items.count) segments")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    HStack(spacing: 12) {
                                        Button("Open in Home") {
                                            sessionStore.selectSession(session)
                                        }
                                        .font(.subheadline.weight(.semibold))

                                        Button("Delete", role: .destructive) {
                                            sessionStore.deleteSession(session)
                                        }
                                        .font(.subheadline.weight(.semibold))
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sessions")
        }
    }
}

#Preview {
    SessionsView(sessionStore: .shared)
}
