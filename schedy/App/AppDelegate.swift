//
//  AppDelegate.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import AppKit
import AppAuth
import SwiftData
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var shouldQuit = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared()
            .setEventHandler(self,
                             andSelector: #selector(self.handleUrlEvent(getURLEvent:replyEvent:)),
                             forEventClass: AEEventClass(kInternetEventClass),
                             andEventID: AEEventID(kAEGetURL)
            )
        
        let users = SwiftDataManager.shared.fetchAll(fetchDescriptor: FetchDescriptor<GoogleUser>())
        users?.forEach({ user in
            user.startSync()
        })
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        let users = SwiftDataManager.shared.fetchAll(fetchDescriptor: FetchDescriptor<GoogleUser>())
        users?.forEach({ user in
            user.stopSync()
        })
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if self.shouldQuit {
            return .terminateNow
        } else {
            NSApplication.shared.setActivationPolicy(.accessory)
            return .terminateCancel
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApplication.shared.setActivationPolicy(.regular)
        return true
    }
    
    @objc
    private func handleUrlEvent(getURLEvent event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        if let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
           let url = URL(string: string) {
            self.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url)
        }
    }
}
