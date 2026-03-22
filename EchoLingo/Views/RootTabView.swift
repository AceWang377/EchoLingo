import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 0
    @StateObject private var sessionStore = TranscriptSessionStore.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(sessionStore: sessionStore, onOpenSessionsTab: {
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
    }
}

#Preview {
    RootTabView()
}
