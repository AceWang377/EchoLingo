import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CaptionSessionViewModel()
    @State private var isExportingTranscript = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.06), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroSection
                        controlPanel
                        livePanels
                        actionButtons
                        historySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("EchoLingo")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Something went wrong", isPresented: Binding(get: {
                viewModel.errorMessage != nil
            }, set: { newValue in
                if !newValue { viewModel.errorMessage = nil }
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .fileExporter(
                isPresented: $isExportingTranscript,
                document: TranscriptDocument(text: viewModel.transcriptExportText),
                contentType: .plainText,
                defaultFilename: exportFileName
            ) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private var exportFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return "EchoLingo-Transcript-\(formatter.string(from: Date()))"
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Real-time captions, translated live")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("A polished speech translation assistant for fast conversations, study sessions, and travel use cases.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                statusPill
            }

            HStack(spacing: 12) {
                metricPill(title: "Source", value: languageLabel(for: viewModel.sourceLanguage))
                metricPill(title: "Target", value: languageLabel(for: viewModel.targetLanguage))
                metricPill(title: "Provider", value: viewModel.translationProvider.displayName)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        )
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(viewModel.isListening ? Color.red : Color.green)
                .frame(width: 10, height: 10)
            Text(viewModel.isListening ? "Listening" : "Ready")
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(viewModel.isListening ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
        .clipShape(Capsule())
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Session Controls")

            VStack(alignment: .leading, spacing: 14) {
                labeledPicker(title: "Translation Provider") {
                    Picker("Provider", selection: $viewModel.translationProvider) {
                        ForEach(TranslationProvider.allCases) { provider in
                            Text(provider.displayName).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                labeledPicker(title: "Source Language") {
                    Picker("Source", selection: $viewModel.sourceLanguage) {
                        Text("English").tag("en-US")
                        Text("Chinese").tag("zh-CN")
                    }
                    .pickerStyle(.segmented)
                }

                labeledPicker(title: "Target Language") {
                    Picker("Target", selection: $viewModel.targetLanguage) {
                        Text("Chinese").tag("zh-CN")
                        Text("English").tag("en-US")
                        Text("Spanish").tag("es-ES")
                    }
                    .pickerStyle(.segmented)
                }

                Button(action: { viewModel.toggleListening() }) {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.isListening ? "stop.fill" : "mic.fill")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.isListening ? "Stop Listening" : "Start Listening")
                                .font(.headline.weight(.semibold))
                            Text(viewModel.isListening ? "Live captions are active" : "Begin a live speech translation session")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: viewModel.isListening ? [Color.red, Color.pink] : [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: (viewModel.isListening ? Color.red : Color.blue).opacity(0.25), radius: 12, x: 0, y: 8)
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private var livePanels: some View {
        VStack(spacing: 16) {
            scrollableTextCard(
                title: "Live Caption",
                subtitle: "Incoming speech recognition output",
                text: viewModel.captionText,
                accent: .blue
            )

            scrollableTextCard(
                title: "Translated Text",
                subtitle: "Current translated output",
                text: viewModel.translationText,
                accent: .purple
            )
        }
    }

    private func scrollableTextCard(title: String, subtitle: String, text: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Circle()
                    .fill(accent.opacity(0.9))
                    .frame(width: 10, height: 10)
            }

            ScrollView {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding(14)
            }
            .frame(minHeight: 120, maxHeight: 220)
            .background(accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(18)
        .background(cardBackground)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button("Clear Session", role: .destructive) {
                    viewModel.clearSession()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button("Copy Transcript") {
                    viewModel.copyTranscript()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            HStack(spacing: 12) {
                ShareLink(
                    item: viewModel.transcriptExportText,
                    subject: Text("EchoLingo Transcript"),
                    message: Text("Shared from EchoLingo")
                ) {
                    labelButton(title: "Share Transcript", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.transcriptHistory.isEmpty)

                Button {
                    isExportingTranscript = true
                } label: {
                    labelButton(title: "Export .txt", systemImage: "doc.text")
                }
                .disabled(viewModel.transcriptHistory.isEmpty)
            }
        }
        .buttonStyle(.plain)
    }

    private func labelButton(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.gray.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionTitle("Session History")
                Spacer()
                Text("\(viewModel.transcriptHistory.count) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.transcriptHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No saved transcript yet")
                        .font(.headline)
                    Text("Finalized caption segments will appear here after recognition stabilizes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBackground)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.transcriptHistory) { segment in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(segment.sourceText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Text(segment.translatedText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(segment.timestamp.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardBackground)
                    }
                }
            }
        }
    }

    private func labeledPicker<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private func languageLabel(for code: String) -> String {
        switch code {
        case "en-US": return "English"
        case "zh-CN": return "Chinese"
        case "es-ES": return "Spanish"
        default: return code
        }
    }
}

#Preview {
    ContentView()
}
