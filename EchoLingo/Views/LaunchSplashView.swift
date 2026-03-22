import SwiftUI

struct LaunchSplashView: View {
    @State private var appear = false
    @State private var float = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("EchoLingoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
                    .scaleEffect(appear ? 1.0 : 0.94)
                    .opacity(appear ? 1.0 : 0.0)
                    .offset(y: float ? -4 : 4)
                    .animation(.easeOut(duration: 0.65), value: appear)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: float)

                Text("Live captions. Instant translation.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.black.opacity(0.68))
                    .opacity(appear ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.9).delay(0.08), value: appear)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            appear = true
            float = true
        }
    }
}

#Preview {
    LaunchSplashView()
}
