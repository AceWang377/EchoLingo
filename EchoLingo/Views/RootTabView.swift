import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 0
    @StateObject private var sessionStore = TranscriptSessionStore.shared
    @ObservedObject var authViewModel: AuthViewModel
    let onSignedOut: () -> Void

    init(authViewModel: AuthViewModel = .shared, onSignedOut: @escaping () -> Void = {}) {
        self.authViewModel = authViewModel
        self.onSignedOut = onSignedOut
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(sessionStore: sessionStore, authViewModel: authViewModel, onSignedOut: onSignedOut, onOpenSessionsTab: {
                selectedTab = 1
            })
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            SessionsView(sessionStore: sessionStore)
                .tabItem {
                    Label("Sessions", systemImage: "text.bubble.fill")
                }
                .tag(1)
        }
        .onAppear {
            sessionStore.switchUser(to: authViewModel.storageUserKey)
        }
        .onChange(of: authViewModel.storageUserKey) { _, newValue in
            sessionStore.switchUser(to: newValue)
        }
    }
}

#Preview {
    RootTabView()
}
