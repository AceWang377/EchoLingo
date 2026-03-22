import Foundation

protocol AuthProviding {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
}

enum AuthError: LocalizedError {
    case notConfigured
    case invalidCredentials
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase Auth is not configured yet. Add your Supabase URL and anon key first."
        case .invalidCredentials:
            return "Invalid email or password."
        case .weakPassword:
            return "Password should be stronger."
        }
    }
}

struct AuthService: AuthProviding {
    func signIn(email: String, password: String) async throws -> AuthUser {
        guard SupabaseConfig.isConfigured else { throw AuthError.notConfigured }
        return AuthUser(id: UUID(), email: email)
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        guard SupabaseConfig.isConfigured else { throw AuthError.notConfigured }
        guard password.count >= 8 else { throw AuthError.weakPassword }
        return AuthUser(id: UUID(), email: email)
    }

    func signOut() async throws {
        guard SupabaseConfig.isConfigured else { throw AuthError.notConfigured }
    }
}
