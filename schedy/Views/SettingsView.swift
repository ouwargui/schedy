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
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Query var users: [GoogleUser]
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VStack(spacing: 20) {
                    Text(LocalizedString.capitalized("settings"))
                        .font(.largeTitle)
                    
                    if !self.users.isEmpty {
                        Text("Signed as: \(self.users.first?.email ?? "")")
                        Button("Sign out") {
                            signOut(for: self.users.first!.email)
                        }
                    } else {
                        GoogleSignInButton {
                            signIn()
                        }
                    }
                }
            }
            if !self.users.isEmpty {
                Tab("Calendars", systemImage: "calendar") {
                    let user = self.users.first!
                    List(user.calendars) { calendar in
                        Text(calendar.name)
                    }
                }
            }
            
            if !self.users.isEmpty {
                Tab("events", systemImage: "calendar") {
                    let user = self.users.first!
                    let events = user.calendars.flatMap(\.events)
                    List(events) { event in
                        Text(event.title)
                    }
                }
            }
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 250)
        .windowResizeBehavior(.enabled)
    }
    
    private func signIn() {
        self.appDelegate.currentAuthorizationFlow = GoogleAuthService.shared.signIn(appDelegate: self.appDelegate)
    }
    
    private func signOut(for email: String) {
        GoogleAuthService.shared.signOut(email: email)
    }
}
