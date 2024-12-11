//
//  CalendarSyncManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 06/12/24.
//

import Foundation
import SwiftData
import GTMAppAuth
import GoogleAPIClientForREST_Calendar

@MainActor
class CalendarSyncManager {
    private var eventSyncTokens = [String: String]()
    private var calendarSyncToken: String?
    private var timer: Timer?
    private var user: GoogleUser
    private var authorizer: AuthSession {
        return user.getSession()
    }
    private var timePassedSinceFirstSync: TimeInterval = 0
    
    init(user: GoogleUser) {
        self.user = user
    }
    
    func startSync() {
        Task {
            print("started syncing")
            await self.performCalendarSync()
            await self.performEventsSync()
            self.deleteOldEvents()
            self.user.lastSyncedAt = Date()
        }
        
        let TIMER_INTERVAL: Double = 30
        
        timer = Timer.scheduledTimer(withTimeInterval: TIMER_INTERVAL, repeats: true) { _ in
            print("syncing")
            Task { @MainActor in
                await self.performCalendarSync()
                await self.performEventsSync()
                
                self.timePassedSinceFirstSync += TIMER_INTERVAL
                
                if self.timePassedSinceFirstSync >= 10_800 {
                    self.deleteOldEvents()
                }
                
                self.user.lastSyncedAt = Date()
            }
        }
    }
    
    func stopSync() {
        print("stopped syncing")
        timer?.invalidate()
        timer = nil
    }
    
    private func performCalendarSync() async {
        guard let calendars = try? await GoogleCalendarService.shared.fetchUserCalendars(fetcherAuthorizer: self.authorizer, syncToken: self.calendarSyncToken) else {
            return
        }
        
        self.calendarSyncToken = calendars.nextSyncToken
        
        self.processCalendars(calendars.items ?? [])
    }
    
    private func performEventsSync() async {
        let calendars = self.user.calendars
        
        await withTaskGroup(of: Void.self) { group in
            for calendar in calendars {
                group.addTask { @MainActor in
                    guard let events = try? await GoogleCalendarService.shared.fetchEvents(for: calendar.googleId, fetcherAuthorizer: self.authorizer, syncToken: self.eventSyncTokens[calendar.googleId]) else {
                        return
                    }
                    
                    self.eventSyncTokens[calendar.googleId] = events.nextSyncToken
                    
                    self.processEvents(events.items ?? [], for: calendar)
                }
            }
            
            await group.waitForAll()
        }
    }
    
    @MainActor
    private func processCalendars(_ calendars: [GTLRCalendar_CalendarListEntry]) {
        let storedCalendars = self.user.calendars
        
        for calendar in calendars {
            if calendar.deleted == true {
                self.handleCalendarDeleted(storedCalendars: storedCalendars, calendar: calendar)
            } else {
                self.handleChangedCalendar(storedCalendars: storedCalendars, calendar: calendar)
            }
        }
    }
    
    @MainActor
    private func handleCalendarDeleted(storedCalendars: [GoogleCalendar], calendar: GTLRCalendar_CalendarListEntry) {
        if let storedCalendar = storedCalendars.first(where: {
            $0.googleId == calendar.identifier!
        }) {
            SwiftDataManager.shared.delete(model: storedCalendar)
        }
    }
    
    @MainActor
    private func handleChangedCalendar(storedCalendars: [GoogleCalendar], calendar: GTLRCalendar_CalendarListEntry) {
        if let storedCalendar = storedCalendars.first(where: { $0.googleId == calendar.identifier }) {
            storedCalendar.update(calendar: calendar)
            SwiftDataManager.shared.update()
        } else {
            let newCalendar = GoogleCalendar(calendar: calendar, account: self.user)
            SwiftDataManager.shared.insert(model: newCalendar)
        }
    }
    
    @MainActor
    private func processEvents(_ events: [GTLRCalendar_Event], for calendar: GoogleCalendar) {
        for event in events {
            if event.start?.dateTime == nil || event.end?.dateTime == nil {
                continue
            }
            
            if event.status == "cancelled" {
                self.handleCanceledEvent(event: event, calendar: calendar)
                continue
            } else {
                self.handleChangedEvent(event: event, calendar: calendar)
                continue
            }
        }
    }
    
    @MainActor
    private func handleCanceledEvent(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
        if let storedEvent = calendar.events.first(where: {
            $0.googleId == event.identifier!
        }) {
            SwiftDataManager.shared.delete(model: storedEvent)
        }
    }
    
    @MainActor
    private func handleChangedEvent(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
        if let storedEvent = calendar.events.first(where: { $0.googleId == event.identifier }) {
            storedEvent.update(event: event)
            SwiftDataManager.shared.update()
        } else {
            let newEvent = GoogleEvent(event: event, calendar: calendar)
            SwiftDataManager.shared.insert(model: newEvent)
        }
        
        return
    }
    
    @MainActor
    private func deleteOldEvents() {
        let thresholdDate = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<GoogleEvent>(
            predicate: #Predicate { event in
                event.end < thresholdDate
            }
        )
        
        let eventsToBeDeleted = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor)
        eventsToBeDeleted?.forEach(SwiftDataManager.shared.delete)
    }
}
