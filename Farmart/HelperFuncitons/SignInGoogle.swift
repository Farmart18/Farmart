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
    let rawNonce: String
    let fullName: String
    let email: String
    let profileImageURL: URL?
}

@MainActor
class SignInGoogle {
    private var currentNonce: String?
    
    func startSignInWithGoogleFlow() async throws -> (idToken: String, nonce: String) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        // Configure Google Sign-In with the nonce
        let config = GIDConfiguration(
            clientID: "635795365010-5t15uihj08vfebvvhdj07vqm07uif3il.apps.googleusercontent.com",
            serverClientID: "635795365010-ifobobv1dfh67hto24sus9p4nog2h3gi.apps.googleusercontent.com"
        )
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topVC = UIApplication.getTopViewController() else {
            throw AuthError.missingViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingUserData
        }
        
        return (idToken, nonce)
    }
    
    private func signInWithGoogleFlow(nonce: String, completion: @escaping (Result<(idToken: String, nonce: String), Error>) -> Void) {
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(AuthError.missingViewController))
            return
        }
        
        // Hash the nonce before sending to Google
        let hashedNonce = sha256(nonce)
        
        // Configure the request with the hashed nonce
        guard let currentConfig = GIDSignIn.sharedInstance.configuration else {
            completion(.failure(AuthError.missingConfiguration))
            return
        }
        
        // Create a new configuration with the nonce
        let config = GIDConfiguration(
            clientID: currentConfig.clientID,
            serverClientID: currentConfig.serverClientID,
            hostedDomain: currentConfig.hostedDomain,
            openIDRealm: currentConfig.openIDRealm
        )
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC, hint: nil, additionalScopes: nil) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.missingUserData))
                return
            }
            
            // Return both the ID token and the ORIGINAL nonce (not hashed)
            completion(.success((idToken: idToken, nonce: nonce)))
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
                                        
enum AuthError: Error {
    case missingViewController
    case missingUserData
    case nonceMismatch
    case missingConfiguration
}
