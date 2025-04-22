import Foundation
import GoogleAPIClientForREST_Calendar
import GTMAppAuth
import SwiftData

protocol CalendarServiceProtocol {
    func fetchUserCalendars(
        fetcherAuthorizer: AuthSession,
        syncToken: String?
    ) async throws -> GTLRCalendar_CalendarList

    func fetchEvents(
        for calendarId: String,
        fetcherAuthorizer: AuthSession,
        syncToken: String?
      ) async throws -> GTLRCalendar_Events
}

@MainActor
protocol DataManaging {
    func insert<T: PersistentModel>(model: T)
    func update()
    func delete<T: PersistentModel>(model: T)
    func fetchAll<T: PersistentModel>(
    fetchDescriptor: FetchDescriptor<T>
    ) -> Result<[T], Error>
}
