import Foundation
import SwiftUI

struct MenuBarItemListView: View {
  var sectionTitle: String
  var events: [GoogleEvent]
  var currentEvent: GoogleEvent?
  var isUpdatingResponse: (GoogleEvent) -> Bool
  var updateResponse: (GoogleEvent, GoogleEventResponseStatus) -> Void

  var body: some View {
    Text(self.sectionTitle)

    Divider()

    ForEach(self.events) { event in
      MenuBarItemView(
        event: event,
        currentEvent: self.currentEvent,
        isUpdatingResponse: self.isUpdatingResponse(event)
      ) { responseStatus in
        self.updateResponse(event, responseStatus)
      }
    }
  }
}
