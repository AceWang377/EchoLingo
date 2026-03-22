import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

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
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .center, spacing: 14) {
                            Image("EchoLingoLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)

                            Text("Welcome to EchoLingo")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("A simple real-time speech caption and translation app for conversations, study, and travel.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        onboardingCard(
                            title: "What EchoLingo does",
                            icon: "captions.bubble.fill",
                            lines: [
                                "Listens to your speech in real time.",
                                "Turns speech into live captions.",
                                "Shows translated text side by side."
                            ]
                        )

                        onboardingCard(
                            title: "Permissions you need to allow",
                            icon: "lock.shield.fill",
                            lines: [
                                "Microphone access: needed to capture your voice.",
                                "Speech Recognition: needed to convert speech into captions.",
                                "If you deny permission, you can enable it later in Settings."
                            ]
                        )

                        Button(action: onContinue) {
                            HStack {
                                Spacer()
                                Text("Continue to EchoLingo")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
        }
    }

    private func onboardingCard(title: String, icon: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(lines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .padding(.top, 2)
                        Text(line)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView(onContinue: {})
}
