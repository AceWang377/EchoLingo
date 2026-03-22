import Foundation

enum SupabaseConfig {
    static let projectURL = "YOUR_SUPABASE_URL"
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"

    static var isConfigured: Bool {
        projectURL != "YOUR_SUPABASE_URL" && anonKey != "YOUR_SUPABASE_ANON_KEY"
    }
}
