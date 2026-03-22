import Foundation

struct AuthUser: Identifiable, Equatable {
    let id: UUID
    let email: String
}
