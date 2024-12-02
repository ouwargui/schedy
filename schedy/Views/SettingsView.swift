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
    @EnvironmentObject private var appDelegate: AppDelegate
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VStack(spacing: 20) {
                    Text(LocalizedString.capitalized("settings"))
                        .font(.largeTitle)
                    
                    if self.appDelegate.isSignedIn {
                        Text("Signed as: \(self.appDelegate.user!.profile?.email ?? "Unknown")")
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
                    List(self.$appDelegate.calendars) { $calendar in
                        Toggle(isOn: $calendar.isOn) {
                            Text(calendar.calendar.summaryOverride ?? calendar.calendar.summary ?? "")
                        }
                    }
                }
            }
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 250)
        .windowResizeBehavior(.enabled)
    }
    
    private func signIn() {
        GoogleAuthService.signIn() { response in
            switch response {
            case .success(let user):
                self.appDelegate.isSignedIn = true
                self.appDelegate.user = user
                self.fetchCalendar()
                break
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func fetchCalendar() {
        if self.appDelegate.user == nil {
            print("Error fetching calendars: User is nil")
            return
        }
        
        Task {
            let (events, calendars) = await CalendarManager.shared.fetchAllCalendarEvents(
                fetcherAuthorizer: self.appDelegate.user!.fetcherAuthorizer as! GTMSessionFetcherAuthorizer
            )
            self.appDelegate.events = events
            self.appDelegate.calendars = calendars
        }
    }
    
    private func signOut() {
        GoogleAuthService.signOut()
        self.appDelegate.isSignedIn = false
        self.appDelegate.user = nil
        self.appDelegate.calendars = []
        self.appDelegate.events = []
    }
}
