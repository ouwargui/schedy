//
//  GoogleOAuthCredentials.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 04/12/24.
//

import Foundation
import AppAuthCore

class GoogleOAuthCredentials {
    static let clientId: String = {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            fatalError("Google Client ID not found on Info.plist")
        }
        
        return clientId
    }()
    
    static let redirectURI: String = {
        guard let redirectUri = Bundle.main.object(forInfoDictionaryKey: "GIDRedirectURI") as? String else {
            fatalError("Google Redirect URI not found on Info.plist")
        }
        
        return redirectUri
    }()
    
    static let clientSecret: String = ""
    
    static let scopes: [String] = [
        "https://www.googleapis.com/auth/calendar.readonly",
        "https://www.googleapis.com/auth/calendar.events.readonly",
        OIDScopeEmail,
        OIDScopeOpenID,
        OIDScopeProfile
    ]
}
