import Foundation

enum SupabaseConfig {
    static let projectURL = "https://cztrdidkvvknwgpjlneh.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6dHJkaWRrdnZrbndncGpsbmVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMDQ0NjIsImV4cCI6MjA4OTc4MDQ2Mn0._8G19svGqs7X-FerC5kWHwl_wk-pLU-m4om-Rd9EL8Q"

    static var isConfigured: Bool {
        !projectURL.isEmpty && !anonKey.isEmpty
    }
}
