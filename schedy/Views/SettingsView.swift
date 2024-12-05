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
                        Button("Sign out", action: signOut)
                    } else {
                        GoogleSignInButton {
                            signIn()
                        }
                    }
                }
            }
            if self.appDelegate.isSignedIn {
                Tab("Calendars", systemImage: "calendar") {
//                    List(self.$appDelegate.calendars) { $calendar in
//                        Toggle(isOn: $calendar.isOn) {
//                            Text(calendar.calendar.summaryOverride ?? calendar.calendar.summary ?? "")
//                        }
//                    }
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
    
//    private func fetchCalendar() {
//        if self.appDelegate.users == nil {
//            print("Error fetching calendars: User is nil")
//            return
//        }
//        
//        Task {
//            let (events, calendars) = await CalendarManager.shared.fetchAllCalendarEvents(
//                fetcherAuthorizer: self.appDelegate.user!.fetcherAuthorizer as! GTMSessionFetcherAuthorizer
//            )
//            self.appDelegate.events = events
//            self.appDelegate.calendars = calendars
//        }
//    }
    
    private func signOut() {
        // GoogleAuthService.signOut()
        self.appDelegate.isSignedIn = false
//        self.appDelegate.user = nil
        self.appDelegate.calendars = []
        self.appDelegate.events = []
    }
}
