import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    @Published var lastAuthCallbackURL: URL?

    private let authService: AuthProviding

    init(authService: AuthProviding) {
        self.authService = authService
    }

    convenience init() {
        self.init(authService: AuthService())
    }

    var isSignedIn: Bool {
        currentUser != nil
    }

    func signIn() async {
        successMessage = nil
        await performAuth {
            try await authService.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        }
    }

    func signUp() async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            currentUser = try await authService.signUp(email: trimmedEmail, password: password)
        } catch let authError as AuthError where authError == .noUserReturned {
            successMessage = "Confirmation email sent to \(trimmedEmail). Please check your inbox and tap the link to continue."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func continueAsGuest() {
        errorMessage = nil
        successMessage = nil
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
            successMessage = "EchoLingo opened from the confirmation link. You can now sign in with your account."
        }
    }

    private func performAuth(_ action: () async throws -> AuthUser) async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser = try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
