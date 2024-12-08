//
//  MenuBarItemView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 07/12/24.
//

import Foundation
import SwiftUI

struct MenuBarItemView: View {
    var event: GoogleEvent
    var isCurrentEvent: Bool? = false
    
    var body: some View {
        let label = "\(event.getStartHour()) - \(event.getEndHour())   \(event.title)"
        
        if (event.hasPassed()) {
            Text(label)
        } else {
            if (self.isCurrentEvent == true) {
                Link(label, destination: event.getLinkDestination() ?? event.getHtmlLinkWithAuthUser())
                    .keyboardShortcut("j", modifiers: [.command, .shift])
            } else {
                Link(label, destination: event.getHtmlLinkWithAuthUser())
            }
        }
    }
}
