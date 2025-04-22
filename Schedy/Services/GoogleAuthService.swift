//
//  GoogleAuthSerice.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import GTMAppAuth
import AppAuth
import Foundation
import GTMSessionFetcherCore

struct GoogleAuthService {
    static let shared = GoogleAuthService()

    enum SignInError: Error {
        case noWindow
    }

    private init() {}

    func signIn(appDelegate: AppDelegate) -> (OIDExternalUserAgentSession?) {
        let configuration = AuthSession.configurationForGoogle()

        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: Constants.clientId,
            clientSecret: Constants.clientSecret,
            scopes: Constants.scopes,
            redirectURL: URL(string: Constants.redirectURI)!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )

        guard let window = NSApplication.shared.windows.first else {
            return nil
        }

        return OIDAuthState.authState(byPresenting: request, presenting: window) { (authState, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let authState = authState {
                let auth = AuthSession(authState: authState)

                if auth.canAuthorize && (auth.userEmail != nil) {

                    DispatchQueue.main.async {
                        SessionManager.shared.createNewSession(auth: auth)
                    }
                }
            }
        }
    }

    @MainActor
    func signOut(user: GoogleUser) {
        SessionManager.shared.deleteSession(for: user)
    }
}
