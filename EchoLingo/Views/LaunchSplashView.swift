import SwiftUI

struct LaunchSplashView: View {
    @State private var glow = false
    @State private var float = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.95), Color.purple.opacity(0.92), Color.indigo.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: glow ? 18 : 30)
                .scaleEffect(glow ? 1.08 : 0.94)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glow)

            VStack(spacing: 20) {
                Image("EchoLingoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 10)
                    .offset(y: float ? -8 : 8)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: float)

                Text("Live captions. Instant translation.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.86))
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
