import SwiftUI

struct SettingsView: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    @Binding var translationProvider: TranslationProvider

    var body: some View {
        NavigationStack {
            Form {
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
                }

                Section("About EchoLingo") {
                    LabeledContent("Version", value: "1.0 MVP")
                    LabeledContent("Build Goal", value: "Real-time captions + translation")
                }

                Section("Support") {
                    Link("Privacy Policy (placeholder)", destination: URL(string: "https://example.com/privacy")!)
                    Link("Support Website (placeholder)", destination: URL(string: "https://example.com/support")!)
                }
            }
            .navigationTitle("Settings")
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
