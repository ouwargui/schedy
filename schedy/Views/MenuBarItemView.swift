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
    
    var body: some View {
        let label = "\(event.getStartHour()) - \(event.getEndHour())   \(event.title)"
        
        if (event.hasPassed()) {
            Text(label)
                .font(Font.system(size: 12).monospacedDigit())
        } else {
            Link(label, destination: event.getLinkDestination() ?? event.getHtmlLinkWithAuthUser())
                .font(Font.system(size: 12).monospacedDigit())
        }
    }
}
