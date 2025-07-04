//
//  SignInGoogle.swift
//  Farmart
//
//  Created by Anshika on 03/07/25.
//

import Foundation
import CryptoKit
import GoogleSignIn

struct SignInGoogleResult {
    let idToken: String
    let nonce: String
    let fullName: String  // New
    let email: String    // New
    let profileImageURL: URL?  // New
}

@MainActor
class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
        
    }
    
//    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
//        guard let topVC = UIApplication.getTopViewController() else {
//            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find top view controller"])))
//            return
//        }
//        
//        let nonce = randomNonceString()
//        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let user = signInResult?.user,
//                  let idToken = user.idToken else {
//                completion(.failure(NSError(domain: "AuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
//                return
//            }
//            
//            completion(.success(.init(idToken: idToken.tokenString, nonce: nonce)))
//        }
//    }
    
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: nil)))
            return
        }
        
        let nonce = randomNonceString()
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
            guard let user = signInResult?.user,
                  let idToken = user.idToken else {
                completion(.failure(error ?? NSError(domain: "AuthError", code: -2, userInfo: nil)))
                return
            }
            
            // Extract user details from Google
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"
            let profileImageURL = user.profile?.imageURL(withDimension: 200)
            
            completion(.success(
                SignInGoogleResult(
                    idToken: idToken.tokenString,
                    nonce: nonce,
                    fullName: fullName,
                    email: user.profile?.email ?? "",
                    profileImageURL: profileImageURL
                )
            ))
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            var randomBytes = [UInt8](repeating: 0, count: length)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            
            let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            
            let nonce = randomBytes.map { byte in
                // Pick a random character from the set, wrapping around if needed.
                charset[Int(byte) % charset.count]
            }
            
            return String(nonce)
        }
        
        private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                String(format: "%02x", $0)
            }.joined()
            
            return hashString
        }
        
    }
