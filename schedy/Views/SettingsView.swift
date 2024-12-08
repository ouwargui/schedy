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
            Tab(LocalizedString.capitalized("accounts"), systemImage: "at") {
                    Spacer()
                    HStack {
                        Spacer()
                        Form {
                            
                        }
                    }
                    Spacer()
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
        .frame(maxWidth: 350, minHeight: 100)
        .windowResizeBehavior(.enabled)
    }
    
    private func signIn() {
        self.appDelegate.currentAuthorizationFlow = GoogleAuthService.shared.signIn(appDelegate: self.appDelegate)
    }
    
    private func signOut(for user: GoogleUser) {
        GoogleAuthService.shared.signOut(user: user)
    }
}

//#Preview {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    SettingsView()
//        .environmentObject(appDelegate)
//        .modelContainer(SwiftDataManager.shared.container)
//}
