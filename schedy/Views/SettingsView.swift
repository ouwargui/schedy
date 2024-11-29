//
//  SettingsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import Foundation
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SettingsView: View {
    @State private var isSignedIn = false
    @State private var userEmail: String?
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VStack(spacing: 20) {
                    Text(LocalizedString.capitalized("settings"))
                        .font(.largeTitle)
                    
                    if isSignedIn {
                        Text("Signed as: \(userEmail ?? "Unknown")")
                        Button("Sign out", action: signOut)
                    } else {
                        GoogleSignInButton {
                            signIn()
                        }
                    }
                }
            }
            Tab("Advanced", systemImage: "star") {
                Text("Advanced Settings")
            }
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 250)
        .windowResizeBehavior(.enabled)
        .onAppear(perform: checkSignInStatus)
    }
    
    private func signIn() {
        GoogleAuthService.signIn() { response in
            switch response {
            case .success(let user):
                self.isSignedIn = true
                self.userEmail = user.profile?.email
                break
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func signOut() {
        GoogleAuthService.signOut()
        self.isSignedIn = false
        self.userEmail = nil
    }
    
    private func checkSignInStatus() {
        GoogleAuthService.checkPreviousSignIn { user in
            if let user = user {
                self.isSignedIn = true
                self.userEmail = user.profile?.email
            }
        }
    }
}
