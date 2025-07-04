import Foundation
import Supabase
import SafariServices

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private weak var safariVC: SFSafariViewController?
    private var continuation: CheckedContinuation<Farmer, Error>?
    
    // Replace with your actual Supabase project URL and anon key
    private let supabaseURL = URL(string: "https://wngwfirfyllcvxehegyd.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduZ3dmaXJmeWxsY3Z4ZWhlZ3lkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTI5NDYsImV4cCI6MjA2NzAyODk0Nn0.nCxnaUCZM9q6gn3meFzNfJAV-Qe6AaT740jJdFyPJdc"
    
    let client: SupabaseClient
    
    private init() {
        
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    func getCurrentSession() async throws -> Farmer {
        let session = try await client.auth.session
        let user = session.user
        
        // Extract user metadata from Supabase
        let metadata = user.userMetadata ?? [:]
        let fullName = metadata["full_name"] as? String ?? ""
        let avatarUrl = metadata["avatar_url"] as? String ?? ""
        
        return Farmer(
            id: user.id,  // This assumes your Farmer.id is UUID (matching Supabase's UUID)
            name: fullName,
            email: user.email ?? "",
            phone: metadata["phone"] as? String,
            profileImage: URL(string: avatarUrl),
            createdAt: Date()  // Or extract from metadata if stored
        )
    }
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> Farmer {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken, nonce: nonce)
        )
        
        // Get additional user info (name, profile image) from Google
        let user = session.user
        let fullName = user.userMetadata["full_name"] as? String ?? "Unknown"
        
        return Farmer(
            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
            name: fullName,
            email: user.email ?? "",
            profileImage: URL(string: user.userMetadata["avatar_url"] as? String ?? "")
        )
    }
    
//    func signInWithGoogleUsingSafari() async throws -> Farmer {
//           let callbackURL = URL(string: "com.seekconnections.seek://auth-callback")!
//        print("Callback URL: \(callbackURL.absoluteString)")
//           let url = try await client.auth.getOAuthSignInURL(
//               provider: .google,
//               redirectTo: callbackURL
//           )
//        print("OAuth URL: \(url.absoluteString)")
//           
//           return try await withCheckedThrowingContinuation { continuation in
//               self.continuation = continuation
//               
//               Task { @MainActor in
//                   let safariVC = SFSafariViewController(url: url)
//                   self.safariVC = safariVC
//                   
//                   if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                      let rootViewController = windowScene.windows.first?.rootViewController {
//                       rootViewController.present(safariVC, animated: true)
//                   }
//               }
//           }
//       }
    
    func signInWithGoogleUsingSafari() async throws -> Farmer {
        // 1. Use simpler callback URL
        let callbackURL = URL(string: "com.seekconnections.seek://")!
        
        // 2. Get the OAuth URL
        let url = try await client.auth.getOAuthSignInURL(
            provider: .google,
            redirectTo: callbackURL
        )
        
        print("Final OAuth URL: \(url.absoluteString)")
        
        // 3. Open URL on main thread
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            Task { @MainActor in
                let success = await UIApplication.shared.open(url)
                if !success {
                    continuation.resume(throwing: NSError(
                        domain: "AuthError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to open authentication URL"]
                    ))
                }
            }
        }
    }
    
    func handleOAuthCallback(url: URL) async throws {
        do {
            let session = try await client.auth.session(from: url)
            let farmer = Farmer(
                id: session.user.id,
                name: session.user.userMetadata["full_name"] as? String ?? "",
                email: session.user.email ?? "",
                createdAt: Date()
            )
            
            await dismissSafariVC()
            continuation?.resume(returning: farmer)
            continuation = nil
            
        } catch {
            await dismissSafariVC()
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
    
    func network(idToken: String, nonce: String, fullName: String, email: String, profileImageURL: URL?) async throws {
        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=id_token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let json: [String: Any] = [
            "id_token": idToken,
            "provider": "google",
            "nonce": nonce,
            "user_metadata": [
                "full_name": fullName,
                "avatar_url": profileImageURL?.absoluteString ?? ""
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
        let (data, _) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "No response")
    }
    
    
    @MainActor
    private func dismissSafariVC() {
        safariVC?.dismiss(animated: true)
        safariVC = nil
    }
    
}

//func signInWithGoogle(redirectTo: URL?) async throws {
//    try await client.auth.signInWithOAuth(provider: .google, redirectTo: redirectTo)
//}

