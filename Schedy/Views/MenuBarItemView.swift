import Foundation
import SwiftUI

struct MenuBarItemView: View {
    var event: GoogleEvent
    var currentEvent: GoogleEvent?

    var body: some View {
        let label = "\(event.getStartHour()) - \(event.getEndHour())   \(event.title)"

        if event.hasPassed() {
            Text(label)
        } else if event.id == currentEvent?.id {
            Link(label, destination: event.getLinkDestination() ?? event.getHtmlLinkWithAuthUser())
                .globalKeyboardShortcut(.openEventUrl)
        } else {
            Link(label, destination: event.getLinkDestination() ?? event.getHtmlLinkWithAuthUser())
        }
    }
}
