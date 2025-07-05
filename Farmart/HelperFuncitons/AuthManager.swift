//import Foundation
//import Supabase
//import SafariServices
//
//class AuthManager: ObservableObject {
//    static let shared = AuthManager()
//    
//    private weak var safariVC: SFSafariViewController?
//    private var continuation: CheckedContinuation<Farmer, Error>?
//    
//    // Replace with your actual Supabase project URL and anon key
//    private let supabaseURL = URL(string: "https://wngwfirfyllcvxehegyd.supabase.co")!
//    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduZ3dmaXJmeWxsY3Z4ZWhlZ3lkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTI5NDYsImV4cCI6MjA2NzAyODk0Nn0.nCxnaUCZM9q6gn3meFzNfJAV-Qe6AaT740jJdFyPJdc"
//    
//    let client: SupabaseClient
//    
//    private init() {
//        
//        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
//    }
//    
//    func getCurrentSession() async throws -> Farmer {
//        let session = try await client.auth.session
//        let user = session.user
//        
//        // Extract user metadata from Supabase
//        let metadata = user.userMetadata ?? [:]
//        let fullName = metadata["full_name"] as? String ?? ""
//        let avatarUrl = metadata["avatar_url"] as? String ?? ""
//        
//        return Farmer(
//            id: user.id,  // This assumes your Farmer.id is UUID (matching Supabase's UUID)
//            name: fullName,
//            email: user.email ?? "",
//            phone: metadata["phone"] as? String,
//            profileImage: URL(string: avatarUrl),
//            createdAt: Date()  // Or extract from metadata if stored
//        )
//    }
//    
//    func signInWithGoogle(idToken: String, nonce: String) async throws -> Farmer {
//        let session = try await client.auth.signInWithIdToken(
//            credentials: .init(provider: .google, idToken: idToken, nonce: nonce)
//        )
//        
//        // Get additional user info (name, profile image) from Google
//        let user = session.user
//        let fullName = user.userMetadata["full_name"] as? String ?? "Unknown"
//        
//        return Farmer(
//            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
//            name: fullName,
//            email: user.email ?? "",
//            profileImage: URL(string: user.userMetadata["avatar_url"] as? String ?? "")
//        )
//    }
//    
//    func signInWithGoogleUsingSafari() async throws -> Farmer {
//        // 1. Use simpler callback URL
//       // let callbackURL = URL(string: "com.seekconnections.seek://")!
//       // let callbackURL = URL(string: "com.googleusercontent.apps.635795365010-BT15uihj08vfebvvhd07xqm07ufi3ll://")!
//        let callbackURL = URL(string: "gu.Farmart://")!
//        print("Attempting callback to: \(callbackURL.absoluteString)")
//        
//        // 2. Get the OAuth URL
//        let url = try await client.auth.getOAuthSignInURL(
//            provider: .google,
//            redirectTo: callbackURL
//        )
//        
//        print("Final OAuth URL: \(url.absoluteString)")
//        
//        // 3. Open URL on main thread
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
//        do {
//            let session = try await client.auth.session(from: url)
//            let farmer = Farmer(
//                id: session.user.id,
//                name: session.user.userMetadata["full_name"] as? String ?? "",
//                email: session.user.email ?? "",
//                createdAt: Date()
//            )
//            
//            await dismissSafariVC()
//            continuation?.resume(returning: farmer)
//            continuation = nil
//            
//        } catch {
//            await dismissSafariVC()
//            continuation?.resume(throwing: error)
//            continuation = nil
//        }
//    }
//    
//    func network(idToken: String, nonce: String, fullName: String, email: String, profileImageURL: URL?) async throws {
//        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=id_token")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
//        
//        let json: [String: Any] = [
//            "id_token": idToken,
//            "provider": "google",
//            "nonce": nonce,
//            "user_metadata": [
//                "full_name": fullName,
//                "avatar_url": profileImageURL?.absoluteString ?? ""
//            ]
//        ]
//        
//        request.httpBody = try JSONSerialization.data(withJSONObject: json)
//        let (data, _) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "No response")
//    }
//    
//    
//    @MainActor
//    private func dismissSafariVC() {
//        safariVC?.dismiss(animated: true)
//        safariVC = nil
//    }
//    
//}
//
//

//import Foundation
//import Supabase
//import SafariServices
//import CryptoKit
//
//class AuthManager: ObservableObject {
//    static let shared = AuthManager()
//    
//    private weak var safariVC: SFSafariViewController?
//    private var continuation: CheckedContinuation<Farmer, Error>?
//    
//    // Replace with your actual Supabase project URL and anon key
//    private let supabaseURL = URL(string: "https://wngwfirfyllcvxehegyd.supabase.co")!
//    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduZ3dmaXJmeWxsY3Z4ZWhlZ3lkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTI5NDYsImV4cCI6MjA2NzAyODk0Nn0.nCxnaUCZM9q6gn3meFzNfJAV-Qe6AaT740jJdFyPJdc"
//    
//    let client: SupabaseClient
//    
//    private init() {
//        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
//    }
//    
//    func getCurrentSession() async throws -> Farmer {
//        let session = try await client.auth.session
//        let user = session.user
//        
//        // Extract user metadata from Supabase
//        let metadata = user.userMetadata ?? [:]
//        let fullName = metadata["full_name"] as? String ?? ""
//        let avatarUrl = metadata["avatar_url"] as? String ?? ""
//        
//        return Farmer(
//            id: user.id,
//            name: fullName,
//            email: user.email ?? "",
//            //phone: metadata["phone"] as? String,
//            profileImage: URL(string: avatarUrl)
//            //createdAt: Date()
//        )
//    }
//    
////    func signInWithGoogle(idToken: String, nonce: String) async throws -> Farmer {
////        let session = try await client.auth.signInWithIdToken(
////            credentials: .init(provider: .google, idToken: idToken, nonce: nonce)
////        )
////        
////        // Get additional user info (name, profile image) from Google
////        let user = session.user
////        let fullName = user.userMetadata["full_name"] as? String ?? "Unknown"
////        
////        return Farmer(
////            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
////            name: fullName,
////            email: user.email ?? "",
////            profileImage: URL(string: user.userMetadata["avatar_url"] as? String ?? "")
////        )
////    }
//    
////    func signInWithGoogle(idToken: String, nonce: String) async throws -> Farmer {
////        do {
////            // 1. Authenticate with Supabase
////            let session = try await client.auth.signInWithIdToken(
////                credentials: .init(
////                    provider: .google,
////                    idToken: idToken,
////                    nonce: nonce
////                )
////            )
////            
////            // 2. Extract user data with proper fallbacks
////            let user = session.user
////            let metadata = user.userMetadata ?? [:]
////            let email = user.email ?? ""
////            let fullName = metadata["full_name"] as? String ?? email.components(separatedBy: "@").first ?? "New Farmer"
////            let avatarUrl = metadata["avatar_url"] as? String ?? ""
////            let phoneNumber = metadata["phone"] as? String  // Keep as optional
////            
////            // 3. Upsert farmer profile (no dates needed in upsert)
////            try await client.database
////                .from("farmers")
////                .upsert([
////                    "id": user.id.uuidString,  // Convert UUID to string
////                    "full_name": fullName,
////                    "email": email,
////                    "avatar_url": avatarUrl,
////                    "phone": phoneNumber  // This will be NULL if phoneNumber is nil
////                ])
////                .execute()
////            
////            // 4. Return Farmer object
////            return Farmer(
////                id: user.id,
////                name: fullName,
////                email: email,
////                phone: phoneNumber,
////                profileImage: URL(string: avatarUrl)
////                //createdAt: Date()  // Set to current date
////            )
////        } catch {
////            print("Google sign-in failed: \(error)")
////            throw AuthError.signInFailed(underlyingError: error)
////        }
////    }
//
//    func signInWithGoogle(idToken: String, nonce: String) async throws -> Farmer {
//        do {
//            // Hash the nonce again for Supabase verification
//            let hashedNonce = sha256(nonce)
//            
//            let session = try await client.auth.signInWithIdToken(
//                credentials: .init(
//                    provider: .google,
//                    idToken: idToken,
//                    nonce: hashedNonce  // Use the hashed version
//                )
//            )
//            
//            let user = session.user
//            let metadata = user.userMetadata ?? [:]
//            
//            try await client.database
//                .from("farmers")
//                .upsert([
//                    "id": user.id.uuidString,
//                    "full_name": metadata["full_name"] as? String ?? "",
//                    "email": user.email ?? "",
//                    "avatar_url": metadata["avatar_url"] as? String ?? ""
//                ])
//                .execute()
//            
//            return Farmer(
//                id: user.id,
//                name: metadata["full_name"] as? String ?? "",
//                email: user.email ?? "",
//                profileImage: URL(string: metadata["avatar_url"] as? String ?? "")
//            )
//        } catch {
//            print("Google sign-in failed: \(error)")
//            throw error
//        }
//    }
//
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
//    }
//    
//    // Custom error type for better error handling
////    enum AuthError: Error {
////        case signInFailed(underlyingError: Error)
////    }
//    
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
//        print("🔐 Handling OAuth callback: \(url.absoluteString)")
//        
//        do {
//            let session = try await client.auth.session(from: url)
//            print("🔐 Session created successfully")
//            
//            let farmer = Farmer(
//                id: session.user.id,
//                name: session.user.userMetadata["full_name"] as? String ?? "",
//                email: session.user.email ?? ""
//                //createdAt: Date()
//            )
//            
//            print("🔐 Created farmer: \(farmer.name)")
//            
//            await dismissSafariVC()
//            continuation?.resume(returning: farmer)
//            continuation = nil
//            
//        } catch {
//            print("🔐 Session creation failed: \(error)")
//            await dismissSafariVC()
//            continuation?.resume(throwing: error)
//            continuation = nil
//        }
//    }
//    
//    func network(idToken: String, nonce: String, fullName: String, email: String, profileImageURL: URL?) async throws {
//        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=id_token")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
//        
//        let json: [String: Any] = [
//            "id_token": idToken,
//            "provider": "google",
//            "nonce": nonce,
//            "user_metadata": [
//                "full_name": fullName,
//                "avatar_url": profileImageURL?.absoluteString ?? ""
//            ]
//        ]
//        
//        request.httpBody = try JSONSerialization.data(withJSONObject: json)
//        let (data, _) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "No response")
//    }
//    
//    @MainActor
//    private func dismissSafariVC() {
//        safariVC?.dismiss(animated: true)
//        safariVC = nil
//    }
//}


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
    
//    func signInWithGoogle(idToken: String) async throws  {
//        do {
//            // Hash the nonce before sending to Supabase
//            //let hashedNonce = sha256(nonce)
//            
//            let session = try await client.auth.signInWithIdToken(
//                credentials: .init(
//                    provider: .google,
//                    idToken: idToken
//                    //nonce: hashedNonce  // Use the hashed nonce
//                    //nonce: nonce
//                )
//            )
//            
//            let user = session.user
//            let metadata = user.userMetadata
//            
//            // Upsert to farmers table
//            try await client
//                .from("farmer")
//                .upsert([
//                    "id": user.id.uuidString,
//                    "name": metadata["name"] as? String ?? "",
//                    "email": user.email ?? "",
//                    "profile_image": metadata["profile_image"] as? String ?? ""
//                ])
//                .execute()
//            
////            return Farmer(
////                id: user.id,
////                name: metadata["full_name"] as? String ?? "",
////                email: user.email ?? "",
////                profileImage: URL(string: metadata["avatar_url"] as? String ?? "")
////            )
//        } catch {
//            print("Google sign-in failed: \(error)")
//            throw error
//        }
//    }
    
    func signInWithGoogle(idToken: String) async throws -> Farmer {
        do {
            // 1. Authenticate with Google
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(provider: .google, idToken: idToken)
            )
            
            let user = session.user
            
            // 2. Extract user data with proper typing
            struct FarmerUpsert: Encodable {
                let id: String
                let name: String
                let email: String
                let profile_image: String?
                let created_at: String
            }
            
            let name = (user.userMetadata["name"] as? String) ??
            (user.userMetadata["full_name"] as? String) ?? "New Farmer"
            
            let profileImage = (user.userMetadata["picture"] as? String) ??
            (user.userMetadata["avatar_url"] as? String) ?? ""
            
            // 3. Create Encodable struct
            let farmerData = FarmerUpsert(
                id: user.id.uuidString,
                name: name,
                email: user.email ?? "",
                profile_image: profileImage.isEmpty ? nil : profileImage,
                created_at: Date().ISO8601Format()
            )
            
            // 4. Upsert with strongly-typed data
            let result = try await client.database
                .from("farmer")
                .upsert(farmerData)
                .execute()
            
            print("Upsert successful:", result)
            
            return Farmer(
                id: user.id,
                name: name,
                email: user.email ?? "",
                profileImage: profileImage.isEmpty ? nil : URL(string: profileImage)
            )
        } catch {
            print("Google sign-in failed:", error)
            throw error
        }
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func signInWithGoogleUsingSafari() async throws -> Farmer {
        // Use simple callback URL - this should match your URL scheme
        let callbackURL = URL(string: "gu.Farmart://")!
        print("Attempting callback to: \(callbackURL.absoluteString)")
        
        // Get the OAuth URL
        let url = try await client.auth.getOAuthSignInURL(
            provider: .google,
            redirectTo: callbackURL
        )
        
        print("Final OAuth URL: \(url.absoluteString)")
        
        // Open URL on main thread
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
        print("🔐 Handling OAuth callback: \(url.absoluteString)")
        
        do {
            let session = try await client.auth.session(from: url)
            print("🔐 Session created successfully")
            
            let farmer = Farmer(
                id: session.user.id,
                name: session.user.userMetadata["full_name"] as? String ?? "",
                email: session.user.email ?? ""
            )
            
            print("🔐 Created farmer: \(farmer.name)")
            
            await dismissSafariVC()
            continuation?.resume(returning: farmer)
            continuation = nil
            
        } catch {
            print("🔐 Session creation failed: \(error)")
            await dismissSafariVC()
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
    
//    func network(idToken: String, nonce: String, fullName: String, email: String, profileImageURL: URL?) async throws {
//        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=id_token")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
//        
//        let json: [String: Any] = [
//            "id_token": idToken,
//            "provider": "google",
//            "nonce": nonce,
//            "user_metadata": [
//                "full_name": fullName,
//                "avatar_url": profileImageURL?.absoluteString ?? ""
//            ]
//        ]
//        
//        request.httpBody = try JSONSerialization.data(withJSONObject: json)
//        let (data, _) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "No response")
//    }

    
    
    func network(idToken: String, fullName: String, email: String, profileImageURL: URL?) async throws {
        let url = URL(string: "https://<your-project>.supabase.co/auth/v1/token?grant_type=id_token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let json: [String: Any] = [
            "provider": "google",
            "id_token": idToken,
            // 🚫 omit nonce to skip the check (or provide a dummy one)
            "user_metadata": [
                "full_name": fullName,
                "avatar_url": profileImageURL?.absoluteString ?? ""
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "No response")
    }

    
    @MainActor
    private func dismissSafariVC() {
        safariVC?.dismiss(animated: true)
        safariVC = nil
    }
}
