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
    @State var gCalendars: [GoogleCalendar] = []
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VStack(spacing: 20) {
                    Text(LocalizedString.capitalized("settings"))
                        .font(.largeTitle)
                    
                    if !self.users.isEmpty {
                        Text("Signed as: \(self.users.first?.email ?? "")")
                        Button("Fetch calendars") {
                            fetchCalendars(for: self.users.first!)
                        }
                        Button("Sign out", action: signOut)
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
            
            Tab("Teste", systemImage: "calendar") {
                List(self.gCalendars) { calendar in
                    Text(calendar.name)
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
    
    private func fetchCalendars(for account: GoogleUser) {
        Task {
            self.gCalendars = await CalendarManager.shared.fetchUserCalendars(for: account)
        }
    }
    
    private func signOut() {
        // GoogleAuthService.signOut()
        self.appDelegate.isSignedIn = false
//        self.appDelegate.user = nil
        self.appDelegate.calendars = []
        self.appDelegate.events = []
    }
}
