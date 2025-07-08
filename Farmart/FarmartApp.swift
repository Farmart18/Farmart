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
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            FarmerView()
                .environmentObject(authManager)
                .onAppear {
                    configureGoogleSignIn()
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
