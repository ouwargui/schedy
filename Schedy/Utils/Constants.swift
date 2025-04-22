import Foundation
import KeyboardShortcuts
import AppAuthCore

class Constants {
    static var sentryIngestUrl: String {
        guard let sentryIngestUrl = Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String else {
            fatalError("Sentry DSN not found on Info.plist")
        }

        return sentryIngestUrl
    }

    static var clientId: String {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            fatalError("Google Client ID not found on Info.plist")
        }

        return clientId
    }

    static var redirectURI: String {
        guard let redirectUri = Bundle.main.object(forInfoDictionaryKey: "GIDRedirectURI") as? String else {
            fatalError("Google Redirect URI not found on Info.plist")
        }

        return redirectUri
    }

    static let clientSecret: String = ""

    static let scopes: [String] = [
        "https://www.googleapis.com/auth/calendar.readonly",
        "https://www.googleapis.com/auth/calendar.events.readonly",
        OIDScopeEmail,
        OIDScopeOpenID,
        OIDScopeProfile
    ]
}

extension KeyboardShortcuts.Name {
    static let openEventUrl = Self("openEventUrl", default: .init(.m, modifiers: [.command, .shift]))
}
