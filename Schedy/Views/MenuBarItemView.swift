import Foundation
import SwiftUI

struct MenuBarItemView: View {
  var event: GoogleEvent
  var currentEvent: GoogleEvent?
  var isUpdatingResponse: Bool
  var updateResponse: (GoogleEventResponseStatus) -> Void

  var body: some View {
    let label = "\(event.getStartHour()) - \(event.getEndHour())   \(event.title)"

    if event.hasPassed() {
      Text(label)
    } else if event.canRespondToInvitation {
      eventMenu(label: label)
    } else {
      openEventLink(label: label)
    }
  }

  private func eventMenu(label: String) -> some View {
    Menu(label) {
      if self.isUpdatingResponse {
        ProgressView("Updating RSVP...")
      } else {
        ForEach(GoogleEventResponseStatus.allCases) { responseStatus in
          Button {
            self.updateResponse(responseStatus)
          } label: {
            if self.event.responseStatus == responseStatus {
              Label(responseStatus.title, systemImage: "checkmark")
            } else {
              Text(responseStatus.title)
            }
          }
        }
      }

      Divider()

      openEventLink(label: self.event.meetLink == nil ? "Open event" : "Open Meet URL")
    }
  }

  @ViewBuilder
  private func openEventLink(label: String) -> some View {
    let link = Link(
      label,
      destination: self.event.getLinkDestination() ?? self.event.getHtmlLinkWithAuthUser()
    )

    if self.event.id == self.currentEvent?.id {
      link.globalKeyboardShortcut(.openEventUrl)
    } else {
      link
    }
  }
}
