//
//  AppDelegate.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import AppKit
import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Calendar

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var user: GIDGoogleUser?
    @Published var events: [GTLRCalendar_Event] = []
    @Published var calendars: [GoogleCalendar] = []
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        GoogleAuthService.checkPreviousSignIn { user in
            if let user = user {
                self.isSignedIn = true
                self.user = user
                print("User has previous sign in")
                Task {
                    let (events, calendars) = await CalendarManager.shared.fetchAllCalendarEvents(fetcherAuthorizer: user.fetcherAuthorizer as! GTMSessionFetcherAuthorizer)
                    self.events = events
                    self.calendars = calendars
                }
                return
            }
            
            print("User has no previous sign in")
        }
    }
}
