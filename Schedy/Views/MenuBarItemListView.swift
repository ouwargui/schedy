import Foundation
import SwiftUI
import SentrySwiftUI

struct MenuBarItemListView: View {
    var sectionTitle: String
    var events: [GoogleEvent]
    var currentEvent: GoogleEvent?

    var body: some View {
        Text(self.sectionTitle)

        Divider()

        SentryTracedView("Menu bar: \(sectionTitle) section") {
            ForEach(self.events) { event in
                MenuBarItemView(event: event, currentEvent: self.currentEvent)
            }
        }
    }
}
