//
//  MenuBarItemListView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 10/12/24.
//

import Foundation
import SwiftUI
import SentrySwiftUI

struct MenuBarItemListView: View {
    var sectionTitle: String
    var events: [GoogleEvent]

    var body: some View {
        Text(self.sectionTitle)

        Divider()

        SentryTracedView("Menu bar: \(sectionTitle) section") {
            ForEach(self.events) { event in
                MenuBarItemView(event: event)
            }
        }
    }
}
