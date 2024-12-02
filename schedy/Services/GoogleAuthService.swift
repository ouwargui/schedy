//
//  GoogleAuthSerice.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import GoogleSignIn

struct GoogleAuthService {
    private static var ADDIITIONAL_SCOPES: [String] = [
        "https://www.googleapis.com/auth/calendar.readonly",
        "https://www.googleapis.com/auth/calendar.events.readonly"
    ]
    
    static func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: NSApplication.shared.keyWindow!, hint: nil, additionalScopes: ADDIITIONAL_SCOPES) { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = response?.user {
                completion(.success(user))
            }
        }
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    static func checkPreviousSignIn(completion: @escaping (GIDGoogleUser?) -> Void) {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                completion(user)
            }
        } else {
            completion(nil)
        }
    }
}
