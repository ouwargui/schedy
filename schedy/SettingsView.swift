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
        GIDSignIn.sharedInstance.signIn(withPresenting: NSApplication.shared.keyWindow!) { response, error in
                if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            self.isSignedIn = true
            self.userEmail = response?.user.profile?.email
        }
    }
    
    private func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isSignedIn = false
        self.userEmail = nil
    }
    
    private func checkSignInStatus() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let user = user {
                    self.isSignedIn = true
                    self.userEmail = user.profile?.email
                }
            }
        }
    }
}
