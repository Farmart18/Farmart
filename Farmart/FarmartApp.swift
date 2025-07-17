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
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var farmerId: UUID? = {
        if let idString = UserDefaults.standard.string(forKey: "farmerId") {
            return UUID(uuidString: idString)
        }
        return nil
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    FarmerView()
                        .environmentObject(authManager)
                } else {
                    OnboardingView(isLoggedIn: $isLoggedIn)
                        .environmentObject(authManager)
                }
            }
            .onAppear {
                if let savedId = farmerId {
                    authManager.currentFarmerId = savedId
                }
            }
        }
    }
    
    private func configureGoogleSignIn() {
           if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String {
               GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
           }
       }
}
