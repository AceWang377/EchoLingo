import SwiftUI

struct LaunchSplashView: View {
    @State private var glow = false
    @State private var float = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: glow ? 18 : 32)
                .scaleEffect(glow ? 1.08 : 0.92)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glow)

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)

                    // Replace this later with your own brand image asset if you want.
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .offset(y: float ? -8 : 8)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: float)

                VStack(spacing: 8) {
                    Text("EchoLingo")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Live captions. Instant translation.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
        .onAppear {
            glow = true
            float = true
        }
    }
}

#Preview {
    LaunchSplashView()
}
