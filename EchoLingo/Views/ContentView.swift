import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CaptionSessionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerCard
                    controlsCard
                    captionCard(title: "Live Caption", text: viewModel.captionText)
                    captionCard(title: "Translated Text", text: viewModel.translationText)
                    historyCard
                }
                .padding()
            }
            .navigationTitle("EchoLingo")
            .alert("Something went wrong", isPresented: Binding(get: {
                viewModel.errorMessage != nil
            }, set: { newValue in
                if !newValue { viewModel.errorMessage = nil }
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Real-time captions + translation")
                .font(.title2.bold())
            Text("V1 goal: live speech recognition, translated text, and reusable transcript history.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Source", selection: $viewModel.sourceLanguage) {
                Text("English").tag("en-US")
                Text("Chinese").tag("zh-CN")
            }
            .pickerStyle(.segmented)

            Picker("Target", selection: $viewModel.targetLanguage) {
                Text("Chinese").tag("zh-CN")
                Text("English").tag("en-US")
                Text("Spanish").tag("es-ES")
            }
            .pickerStyle(.segmented)

            Button(action: { viewModel.toggleListening() }) {
                HStack {
                    Image(systemName: viewModel.isListening ? "stop.circle.fill" : "mic.circle.fill")
                    Text(viewModel.isListening ? "Stop Listening" : "Start Listening")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isListening ? Color.red : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func captionCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session History")
                .font(.headline)

            if viewModel.transcriptHistory.isEmpty {
                Text("Your confirmed caption segments will appear here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.transcriptHistory) { segment in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(segment.sourceText)
                            .font(.subheadline.weight(.medium))
                        Text(segment.translatedText)
                            .foregroundStyle(.secondary)
                        Text(segment.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
