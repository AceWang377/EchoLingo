import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = CaptionSessionViewModel()
    @State private var isExportingTranscript = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !viewModel.focusModeEnabled {
                            headerSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        if let guidance = viewModel.permissionGuidance {
                            infoCard(title: "Permission help", systemImage: "exclamationmark.shield.fill", tint: .orange, text: guidance, actionTitle: "Open Settings") {
                                viewModel.openSystemSettings()
                            }
                        }

                        if let translationGuidance = viewModel.translationGuidance {
                            infoCard(title: "Translation provider status", systemImage: "network.badge.shield.half.filled", tint: .blue, text: translationGuidance)
                        }

                        listenCard

                        if !viewModel.focusModeEnabled {
                            translationSettingsCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        contentPanels
                        actionButtons
                        historySection
                        savedSessionsSection
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: viewModel.focusModeEnabled)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("EchoLingo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleFocusMode()
                    } label: {
                        Image(systemName: viewModel.focusModeEnabled ? "arrow.down.forward.and.arrow.up.backward" : "arrow.up.left.and.arrow.down.right")
                    }

                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(
                    sourceLanguage: $viewModel.sourceLanguage,
                    targetLanguage: $viewModel.targetLanguage,
                    translationProvider: $viewModel.translationProvider
                )
            }
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

    private var headerSection: some View {
        HStack(spacing: 14) {
            Image("EchoLingoLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("EchoLingo")
                    .font(.title2.weight(.bold))
                Text("Real-time captions and live translation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                statusPill
            }

            Spacer()
        }
        .padding(18)
        .background(cardBackground)
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(viewModel.isListening ? (viewModel.isTranslating ? Color.orange : Color.red) : Color.green)
                .frame(width: 10, height: 10)
            Text(viewModel.isListening ? (viewModel.isTranslating ? "Listening · Translating" : "Listening") : "Ready")
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(Capsule())
    }

    private var listenCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Main Action")
                    .font(.headline)
                Spacer()
                Button(viewModel.focusModeEnabled ? "Exit Focus" : "Focus Mode") {
                    viewModel.toggleFocusMode()
                }
                .font(.caption.weight(.semibold))
            }

            Button(action: { viewModel.toggleListening() }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 52, height: 52)
                        Image(systemName: viewModel.isListening ? "stop.fill" : "mic.fill")
                            .font(.title2.bold())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.isListening ? "Stop Listening" : "Start Listening")
                            .font(.title3.weight(.bold))
                        Text(viewModel.isListening ? "Tap to stop the live speech session" : "Tap to start a live caption and translation session")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.88))
                    }

                    Spacer()
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: viewModel.isListening ? [Color.red, Color.pink] : [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: (viewModel.isListening ? Color.red : Color.blue).opacity(0.26), radius: 14, x: 0, y: 10)
            }
            .buttonStyle(.plain)

            if !viewModel.transcriptHistory.isEmpty {
                Button("Save Current Session") {
                    viewModel.saveCurrentSession()
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private var translationSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
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
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private var contentPanels: some View {
        VStack(spacing: 14) {
            scrollableTextCard(title: "Live Caption", subtitle: "Incoming speech recognition output", text: viewModel.captionText, accent: .blue)
            scrollableTextCard(title: "Translated Text", subtitle: viewModel.isTranslating ? "Translation in progress" : "Current translated output", text: viewModel.translationText, accent: .purple)
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
                ShareLink(item: viewModel.transcriptExportText, subject: Text("EchoLingo Transcript"), message: Text("Shared from EchoLingo")) {
                    labelButton(title: "Share Transcript", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.transcriptHistory.isEmpty)

                Button { isExportingTranscript = true } label: {
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
            Text(title).fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.gray.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Session History")
                    .font(.headline)
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

    private var savedSessionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Saved Sessions")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.sessionStore.sessions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.sessionStore.sessions.isEmpty {
                Text("No saved sessions yet. Save a session after recording to keep it locally on this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBackground)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.sessionStore.sessions) { session in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(session.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }

                            Text("\(session.sourceLanguage) → \(session.targetLanguage) · \(session.items.count) segments")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Button("Load") {
                                    viewModel.loadSession(session)
                                }
                                .font(.subheadline.weight(.semibold))

                                Button("Delete", role: .destructive) {
                                    viewModel.deleteSavedSession(session)
                                }
                                .font(.subheadline.weight(.semibold))
                            }
                        }
                        .padding(16)
                        .background(cardBackground)
                    }
                }
            }
        }
    }

    private func infoCard(title: String, systemImage: String, tint: Color, text: String, actionTitle: String? = nil, action: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.headline)
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private func labeledPicker<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
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
}
