//
//  MenuBarViewModel.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 07/12/24.
//

import Foundation
import SwiftData
import KeyboardShortcuts
import SwiftUI
import Sentry

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published private(set) var currentTime = Date()
    @Published var todaysPastEvents: [GoogleEvent] = []
    @Published var currentEvent: GoogleEvent?
    @Published var currentEvents: [GoogleEvent] = []
    @Published var todaysNextEvents: [GoogleEvent] = []
    @Published var todaysEvents: [GoogleEvent] = []
    @Published var tomorrowsEvents: [GoogleEvent] = []
    private var timer: Timer?

    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self.currentTime)!
    }

    var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.currentTime)
    }

    var tomorrowFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.tomorrow)
    }

    var todaysEventsWithoutCurrent: [GoogleEvent] {
        let currentEventGoogleId = self.currentEvent?.googleId ?? ""
        if let eventsWithouCurrent = try? self.todaysEvents.filter(#Predicate<GoogleEvent> {
            $0.googleId != currentEventGoogleId
        }) {
            return eventsWithouCurrent
        }

        return self.todaysEvents
    }

    var isThereAnyEvents: Bool {
        return !self.todaysEvents.isEmpty || !self.tomorrowsEvents.isEmpty
    }

    var titleBarEvent: GoogleEvent? {
        return self.currentEvent ?? self.todaysNextEvents.first
    }

    init() {
        KeyboardShortcuts
            .onKeyUp(for: .openEventUrl) { [self] in
                print("got open event url shortcut")
                if let currentEvent = self.titleBarEvent {
                    NSWorkspace.shared.open(currentEvent.getLinkDestination() ?? currentEvent.getHtmlLinkWithAuthUser())
                }
            }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.update()
            }
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    private func update() {
        let transaction = SentrySDK.startTransaction(name: "update-menubar", operation: "update-call")
        self.currentTime = Date()
        self.updateEarlierEvents(transaction)
        self.updateCurrentEvent(transaction)
        self.updateTodaysEvents(transaction)
        self.updateTodaysNextEvents(transaction)
        self.updateTomorrowsEvents(transaction)
        transaction.finish()
    }

    private func updateEarlierEvents(_ transaction: any Span) {
        let span = transaction.startChild(operation: "update-earlier-events")
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.pastPredicate,
            sortBy: [SortDescriptor(\.start)]
        )

        guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
            span.finish(status: .internalError)
            return
        }

        self.todaysPastEvents = events
        span.finish(status: .ok)
    }

    private func updateCurrentEvent(_ transaction: any Span) {
        let span = transaction.startChild(operation: "update-current-event")
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.currentsPredicate,
            sortBy: [SortDescriptor(\.end)]
        )

        guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
            span.finish(status: .internalError)
            return
        }

        self.currentEvent = events.first
        self.currentEvents = events
        span.finish(status: .ok)
    }

    private func updateTodaysNextEvents(_ transaction: any Span) {
        let span = transaction.startChild(operation: "update-next-event")
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.todaysNextPredicate,
            sortBy: [SortDescriptor(\.start)]
        )

        guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
            span.finish(status: .internalError)
            return
        }

        self.todaysNextEvents = events
        span.finish(status: .ok)
    }

    private func updateTodaysEvents(_ transaction: any Span) {
        let span = transaction.startChild(operation: "update-todays-events")
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.todaysPredicate,
            sortBy: [SortDescriptor(\.start)]
        )

        guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
            span.finish(status: .internalError)
            return
        }

        self.todaysEvents = events
        span.finish(status: .ok)
    }

    private func updateTomorrowsEvents(_ transaction: any Span) {
        let span = transaction.startChild(operation: "update-tomorrows-events")
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.tomorrowsPredicate,
            sortBy: [SortDescriptor(\.start)]
        )

        guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
            span.finish(status: .internalError)
            return
        }

        self.tomorrowsEvents = events
        span.finish(status: .ok)
    }
}
