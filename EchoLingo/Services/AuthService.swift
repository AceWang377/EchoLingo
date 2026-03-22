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
    case invalidURL
    case invalidResponse
    case noUserReturned

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase Auth is not configured yet. Add your Supabase URL and anon key first."
        case .invalidCredentials:
            return "Invalid email or password."
        case .weakPassword:
            return "Password should be at least 8 characters."
        case .invalidURL:
            return "Supabase Auth URL is invalid."
        case .invalidResponse:
            return "Supabase Auth returned an invalid response."
        case .noUserReturned:
            return "No user was returned from Supabase Auth."
        }
    }
}

struct AuthService: AuthProviding {
    func signIn(email: String, password: String) async throws -> AuthUser {
        guard SupabaseConfig.isConfigured else { throw AuthError.notConfigured }
        return try await performAuth(path: "/auth/v1/token?grant_type=password", email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        guard SupabaseConfig.isConfigured else { throw AuthError.notConfigured }
        guard password.count >= 8 else { throw AuthError.weakPassword }
        return try await performAuth(path: "/auth/v1/signup", email: email, password: password)
    }

    func signOut() async throws {
        // Session persistence/token revocation can be added in the next step.
    }

    private func performAuth(path: String, email: String, password: String) async throws -> AuthUser {
        guard let url = URL(string: SupabaseConfig.projectURL + path) else {
            throw AuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")

        let body = AuthRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
            if let user = decoded.user {
                return AuthUser(id: UUID(uuidString: user.id) ?? UUID(), email: user.email ?? email)
            }
            throw AuthError.noUserReturned
        case 400, 401:
            throw AuthError.invalidCredentials
        default:
            if let apiError = try? JSONDecoder().decode(SupabaseAPIError.self, from: data) {
                throw NSError(domain: "SupabaseAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: apiError.msg ?? apiError.error_description ?? "Authentication failed"])
            }
            throw AuthError.invalidResponse
        }
    }
}

private struct AuthRequest: Codable {
    let email: String
    let password: String
}

private struct AuthResponse: Codable {
    let access_token: String?
    let refresh_token: String?
    let user: AuthResponseUser?
}

private struct AuthResponseUser: Codable {
    let id: String
    let email: String?
}

private struct SupabaseAPIError: Codable {
    let msg: String?
    let error_description: String?
}
