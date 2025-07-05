////
////  FarmartApp.swift
////  Farmart
////
////  Created by Batch  - 2 on 02/07/25.
////
//
//import SwiftUI
//import GoogleSignIn
//
//@main
//struct FarmartApp: App {
//    @StateObject var authManager = AuthManager.shared
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .onOpenURL { url in
//                   GIDSignIn.sharedInstance.handle(url)
//               }
//               // Handle Supabase OAuth callback URL
//               .onOpenURL { url in
//                   Task {
//                       do {
//                           try await authManager.handleOAuthCallback(url: url)
//                       } catch {
//                           print("Error handling OAuth callback: \(error)")
//                       }
//                   }
//               }
//               .environmentObject(authManager)
//            
//                
//        }
//    }
//}


import SwiftUI
import GoogleSignIn

@main
struct FarmartApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onAppear {
                    // Configure Google Sign-In
                    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                       let plist = NSDictionary(contentsOfFile: path),
                       let clientId = plist["CLIENT_ID"] as? String {
                        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
                    }
                }
                .onOpenURL { url in
                    // Handle incoming URLs
                    handleURL(url)
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        print("🔗 Received URL: \(url.absoluteString)")
        print("🔗 URL Scheme: \(url.scheme ?? "none")")
        print("🔗 URL Host: \(url.host ?? "none")")
        print("🔗 URL Path: \(url.path)")
        print("🔗 URL Query: \(url.query ?? "none")")
        
        // Check if this is our custom scheme callback
        if url.scheme == "gu.Farmart" {
            print("🔗 Handling custom scheme callback")
            Task {
                do {
                    try await AuthManager.shared.handleOAuthCallback(url: url)
                    print("🔗 OAuth callback handled successfully")
                } catch {
                    print("🔗 OAuth callback error: \(error)")
                }
            }
        }
        
        // Also handle Google Sign-In URLs (if using direct Google Sign-In)
        GIDSignIn.sharedInstance.handle(url)
    }
}
