//
//  FarmartApp.swift
//  Farmart
//
//  Created by Batch  - 2 on 02/07/25.
//

import SwiftUI
import GoogleSignIn

@main
struct FarmartApp: App {
    @StateObject var authManager = AuthManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                   GIDSignIn.sharedInstance.handle(url)
               }
               // Handle Supabase OAuth callback URL
               .onOpenURL { url in
                   Task {
                       do {
                           try await authManager.handleOAuthCallback(url: url)
                       } catch {
                           print("Error handling OAuth callback: \(error)")
                       }
                   }
               }
               .environmentObject(authManager)
            
                
        }
    }
}
