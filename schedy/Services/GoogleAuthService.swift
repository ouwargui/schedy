//
//  GoogleAuthSerice.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import GoogleSignIn

struct GoogleAuthService {
    static func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: NSApplication.shared.keyWindow!) { response, error in
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
