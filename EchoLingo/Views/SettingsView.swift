import SwiftUI

struct SettingsView: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    @Binding var translationProvider: TranslationProvider
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                translationSection
                appSection
                supportSection
                launchReadinessSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var translationSection: some View {
        Section("Translation") {
            Picker("Provider", selection: $translationProvider) {
                ForEach(TranslationProvider.allCases) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }

            Picker("Source Language", selection: $sourceLanguage) {
                Text("English").tag("en-US")
                Text("Chinese").tag("zh-CN")
            }

            Picker("Target Language", selection: $targetLanguage) {
                Text("Chinese").tag("zh-CN")
                Text("English").tag("en-US")
                Text("Spanish").tag("es-ES")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(translationProvider.displayName)
                    .font(.subheadline.weight(.semibold))
                Text(translationProvider.statusDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !translationProvider.isProductionReady {
                    Label("Not production-ready yet", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var appSection: some View {
        Section("About EchoLingo") {
            LabeledContent("App", value: AppMetadata.appName)
            LabeledContent("Version", value: AppMetadata.version)
            LabeledContent("Goal", value: AppMetadata.buildGoal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Product direction")
                    .font(.subheadline.weight(.semibold))
                Text("EchoLingo is being built as a real-time speech caption and translation app designed for conversations, study, and travel scenarios.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var supportSection: some View {
        Section("Support & Links") {
            Link("Privacy Policy (replace later)", destination: AppMetadata.privacyURL)
            Link("Support Website (replace later)", destination: AppMetadata.supportURL)
            Link("GitHub Repository (replace later)", destination: AppMetadata.githubURL)
        }
    }

    private var launchReadinessSection: some View {
        Section("Launch Readiness") {
            Label("Speech recognition and transcript export are already implemented", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("A real production translation provider still needs to be connected", systemImage: "clock.badge.exclamationmark")
                .foregroundStyle(.orange)
            Label("Replace placeholder privacy/support links before release", systemImage: "link.badge.plus")
                .foregroundStyle(.orange)
            Label("Add final app icon, screenshots, and App Store metadata", systemImage: "photo.on.rectangle")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView(
        sourceLanguage: .constant("en-US"),
        targetLanguage: .constant("zh-CN"),
        translationProvider: .constant(.mock)
    )
}
