//
//  AppDelegate.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import AppKit
import SwiftUI
import GoogleSignIn
import AppAuth
import GoogleAPIClientForREST_Calendar

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var users: [String] = []
    @Published var events: [GoogleEvent] = []
    @Published var calendars: [GoogleCalendar] = []
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared()
            .setEventHandler(self,
                             andSelector: #selector(self.handleUrlEvent(getURLEvent:replyEvent:)),
                             forEventClass: AEEventClass(kInternetEventClass),
                             andEventID: AEEventID(kAEGetURL)
            )
    }
    
    @objc
    private func handleUrlEvent(getURLEvent event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        if let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
           let url = URL(string: string) {
            self.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url)
        }
    }
}
