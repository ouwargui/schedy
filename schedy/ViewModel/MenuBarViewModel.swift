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

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published private(set) var currentTime = Date()
    @Published var todaysPastEvents: [GoogleEvent] = []
    @Published var currentEvent: GoogleEvent?
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
        self.currentTime = Date()
        self.updateEarlierEvents()
        self.updateCurrentEvent()
        self.updateTodaysEvents()
        self.updateTodaysNextEvents()
        self.updateTomorrowsEvents()
    }
    
    private func updateEarlierEvents() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.pastPredicate,
            sortBy: [SortDescriptor(\.start)]
        )
        
        self.todaysPastEvents = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor) ?? []
    }
    
    private func updateCurrentEvent() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.currentsPredicate,
            sortBy: [SortDescriptor(\.end)]
        )
        
        self.currentEvent = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor)?.first
    }
    
    private func updateTodaysNextEvents() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.todaysNextPredicate,
            sortBy: [SortDescriptor(\.start)]
        )
        
        self.todaysNextEvents = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor) ?? []
    }
    
    private func updateTodaysEvents() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.todaysPredicate,
            sortBy: [SortDescriptor(\.start)]
        )
        
        self.todaysEvents = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor) ?? []
    }
    
    private func updateTomorrowsEvents() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.tomorrowsPredicate,
            sortBy: [SortDescriptor(\.start)]
        )
        
        self.tomorrowsEvents = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor) ?? []
    }
}
