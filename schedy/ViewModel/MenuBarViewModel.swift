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
    @Published var currentEvent: GoogleEvent?
    @Published var todaysEvents: [GoogleEvent] = []
    @Published var tomorrowsEvents: [GoogleEvent] = []
    private var timer: Timer?
    
    init() {
        KeyboardShortcuts
            .onKeyUp(for: .openEventUrl) { [self] in
                print("got open event url shortcut")
                if let currentEvent = self.currentEvent {
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
        self.updateCurrentEvent()
        self.updateTodaysEvents()
        self.updateTomorrowsEvents()
    }
    
    private func updateCurrentEvent() {
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: GoogleEvent.currentsPredicate,
            sortBy: [SortDescriptor(\.end)]
        )
        
        self.currentEvent = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor)?.first
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
