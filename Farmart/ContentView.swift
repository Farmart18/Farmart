//
//  ContentView.swift
//  Farmart
//
//  Created by Batch  - 2 on 02/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isCheckingAuth = true
    
    var body: some View {
        Group {
            if isCheckingAuth {
                // Loading view while checking authentication
                ProgressView("Loading...")
            } else {
                // Show onboarding or main app based on auth status
                OnboardingView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            checkAuthStatus()
        }
    }
    
    private func checkAuthStatus() {
        Task {
            do {
               
                let _ = try await authManager.getCurrentSession()
                // If we get here, user is already authenticated
                // You might want to navigate to a different view
            } catch {
                // User is not authenticated, show onboarding
                print("No current session: \(error)")
            }
            isCheckingAuth = false
        }
    }
}

#Preview {
    ContentView()
}
