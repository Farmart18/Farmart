import Foundation
import Supabase
import SafariServices
import CryptoKit

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
        let metadata = user.userMetadata
        let name = metadata["name"] as? String ?? ""
        let profileImage = metadata["profile_image"] as? String ?? ""
        
        return Farmer(
            id: user.id,
            name:  name,
            email: user.email ?? "",
            profileImage: URL(string: profileImage)
        )
    }
    
    func signInWithGoogle(idToken: String) async throws{
        do {
            // Authenticate with Google
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(provider: .google, idToken: idToken)
            )
            let user = session.user
            
            // Convert AnyJSON metadata to regular dictionary
            let metadataDict: [String: Any] = user.userMetadata.reduce(into: [String: Any]()) { result, item in
                result[item.key] = item.value.value
            } ?? [:]
            
            let name: String = {
                if let name = metadataDict["name"] as? String { return name }
                if let fullName = metadataDict["full_name"] as? String { return fullName }
                if let givenName = metadataDict["given_name"] as? String,
                   let familyName = metadataDict["family_name"] as? String {
                    return "\(givenName) \(familyName)"
                }
                return "New Farmer"
            }()
            
            
            let profileImage: String? = {
                if let picture = metadataDict["picture"] as? String { return picture }
                if let avatar = metadataDict["avatar_url"] as? String { return avatar }
                return nil
            }()
            
           
            struct FarmerUpsert: Encodable {
                let id: String
                let name: String
                let email: String
                let profile_image: String?
                let created_at: String
            }
            
            let farmerData = FarmerUpsert(
                id: user.id.uuidString,
                name: name,
                email: user.email ?? "",
                profile_image: profileImage,
                created_at: Date().ISO8601Format()
            )
            
           
            let result = try await client.database
                .from("farmer")
                .upsert(farmerData)
                .execute()
        } catch {
            print("Detailed Google sign-in error:", error)
            throw error
        }
    }
    
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
//    }
    
//    func signInWithGoogleUsingSafari() async throws -> Farmer {
//        // Use simple callback URL - this should match your URL scheme
//        let callbackURL = URL(string: "gu.Farmart://")!
//        print("Attempting callback to: \(callbackURL.absoluteString)")
//        
//        // Get the OAuth URL
//        let url = try await client.auth.getOAuthSignInURL(
//            provider: .google,
//            redirectTo: callbackURL
//        )
//        
//        print("Final OAuth URL: \(url.absoluteString)")
//        
//        // Open URL on main thread
//        return try await withCheckedThrowingContinuation { continuation in
//            self.continuation = continuation
//            
//            Task { @MainActor in
//                let success = await UIApplication.shared.open(url)
//                if !success {
//                    continuation.resume(throwing: NSError(
//                        domain: "AuthError",
//                        code: -1,
//                        userInfo: [NSLocalizedDescriptionKey: "Failed to open authentication URL"]
//                    ))
//                }
//            }
//        }
//    }
//    
//    func handleOAuthCallback(url: URL) async throws {
//        print("Handling OAuth callback: \(url.absoluteString)")
//        
//        do {
//            let session = try await client.auth.session(from: url)
//            print("Session created successfully")
//            
//            let farmer = Farmer(
//                id: session.user.id,
//                name: session.user.userMetadata["full_name"] as? String ?? "",
//                email: session.user.email ?? ""
//            )
//            
//            print("Created farmer: \(farmer.name)")
//            
//            await dismissSafariVC()
//            continuation?.resume(returning: farmer)
//            continuation = nil
//            
//        } catch {
//            print("Session creation failed: \(error)")
//            await dismissSafariVC()
//            continuation?.resume(throwing: error)
//            continuation = nil
//        }
//    }
//    
//
//    func network(idToken: String, fullName: String, email: String, profileImageURL: URL?) async throws {
//        let url = URL(string: "https://<your-project>.supabase.co/auth/v1/token?grant_type=id_token")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
//
//        let json: [String: Any] = [
//            "provider": "google",
//            "id_token": idToken,
//            
//            "user_metadata": [
//                "full_name": fullName,
//                "avatar_url": profileImageURL?.absoluteString ?? ""
//            ]
//        ]
//        
//        request.httpBody = try JSONSerialization.data(withJSONObject: json)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "No response")
//    }
//
//    
//    @MainActor
//    private func dismissSafariVC() {
//        safariVC?.dismiss(animated: true)
//        safariVC = nil
//    }
}
