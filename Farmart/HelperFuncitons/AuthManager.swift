import Foundation
import Supabase

class AuthManager {
    static let shared = AuthManager()
    
    // Replace with your actual Supabase project URL and anon key
    private let supabaseURL = URL(string: "https://318774562828-qnd071hnv54jh8msk346pin96u408h7o.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduZ3dmaXJmeWxsY3Z4ZWhlZ3lkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTI5NDYsImV4cCI6MjA2NzAyODk0Nn0.nCxnaUCZM9q6gn3meFzNfJAV-Qe6AaT740jJdFyPJdc"
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    func signInWithGoogle(redirectTo: URL?) async throws {
        try await client.auth.signInWithOAuth(provider: .google, redirectTo: redirectTo)
    }
} 
