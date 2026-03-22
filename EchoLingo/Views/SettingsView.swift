import SwiftUI

struct SettingsView: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    @Binding var translationProvider: TranslationProvider
    @ObservedObject var authViewModel: AuthViewModel
    let onSignedOut: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                accountSection
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

    private var accountSection: some View {
        Section("Account") {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(initials)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUser?.email ?? "Guest")
                        .font(.headline)
                    Text(authViewModel.isSignedIn ? "Signed in" : "Guest mode")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            if authViewModel.isSignedIn {
                Button("Log Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                        onSignedOut()
                    }
                }
            } else {
                Text("Sign in from the auth screen to unlock account-based features later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
            Text("EchoLingo is being built for work and study scenarios where users need live captions, translation, and reusable notes.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
            Label("Auth is working in optional-login mode", systemImage: "person.crop.circle.badge.checkmark")
                .foregroundStyle(.green)
            Label("Local sessions are temporarily scoped by user on this device", systemImage: "externaldrive.badge.person.crop")
                .foregroundStyle(.orange)
            Label("Real cloud session sync should be added later", systemImage: "icloud.slash")
                .foregroundStyle(.secondary)
        }
    }

    private var initials: String {
        if let email = authViewModel.currentUser?.email, let first = email.first {
            return String(first).uppercased()
        }
        return "G"
    }
}

#Preview {
    SettingsView(
        sourceLanguage: .constant("en-US"),
        targetLanguage: .constant("zh-CN"),
        translationProvider: .constant(.mock),
        authViewModel: .shared,
        onSignedOut: {}
    )
}
