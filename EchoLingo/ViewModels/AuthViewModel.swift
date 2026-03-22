import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var lastAuthCallbackURL: URL?

    private let authService: AuthProviding

    init(authService: AuthProviding = AuthService()) {
        self.authService = authService
    }

    var isSignedIn: Bool {
        currentUser != nil
    }

    func signIn() async {
        await performAuth {
            try await authService.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        }
    }

    func signUp() async {
        await performAuth {
            try await authService.signUp(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        }
    }

    func continueAsGuest() {
        errorMessage = nil
    }

    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleIncomingURL(_ url: URL) {
        lastAuthCallbackURL = url
        if url.scheme == "echolingo" {
            errorMessage = nil
        }
    }

    private func performAuth(_ action: () async throws -> AuthUser) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser = try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
