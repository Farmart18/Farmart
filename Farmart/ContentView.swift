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
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isCheckingAuth {
                ProgressView("Loading")
            } else {
                OnboardingView(isLoggedIn: $isLoggedIn)
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
                isLoggedIn = true
            } catch {
                // User is not authenticated, show onboarding
                print("No current session: \(error)")
                isLoggedIn = false
            }
            isCheckingAuth = false
        }
    }
}

#Preview {
    ContentView()
}
