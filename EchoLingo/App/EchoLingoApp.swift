import SwiftUI

@main
struct EchoLingoApp: App {
    @StateObject private var launchViewModel = AppLaunchViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    LaunchSplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showSplash = false
                                }
                            }
                        }
                } else if !launchViewModel.hasCompletedOnboarding {
                    OnboardingView {
                        launchViewModel.completeOnboarding()
                    }
                    .transition(.opacity)
                } else {
                    AuthGateView()
                        .transition(.opacity)
                }
            }
        }
    }
}
