import AppAuth
import AppKit
import Foundation
import GTMAppAuth
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

  func hasCalendarWriteAccess(user: GoogleUser) -> Bool {
    guard let session = SessionManager.shared.getSession(for: user.email),
      let scopes = session.authState.scope
    else {
      return false
    }

    return scopes.components(separatedBy: " ").contains(Constants.calendarEventsScope)
  }

  @MainActor
  func requestCalendarWriteAccess(
    user: GoogleUser,
    appDelegate: AppDelegate
  ) async -> Bool {
    let configuration = AuthSession.configurationForGoogle()
    let scopes = Constants.scopes + [Constants.calendarEventsScope]

    let request = OIDAuthorizationRequest(
      configuration: configuration,
      clientId: Constants.clientId,
      clientSecret: Constants.clientSecret,
      scopes: scopes,
      redirectURL: URL(string: Constants.redirectURI)!,
      responseType: OIDResponseTypeCode,
      additionalParameters: [
        "include_granted_scopes": "true",
        "login_hint": user.email,
      ]
    )

    return await withCheckedContinuation { continuation in
      let callback: OIDAuthStateAuthorizationCallback = { authState, error in
        if let error = error {
          print(error.localizedDescription)
          continuation.resume(returning: false)
          return
        }

        guard let authState = authState else {
          continuation.resume(returning: false)
          return
        }

        let auth = AuthSession(authState: authState)

        guard auth.userEmail == user.email else {
          continuation.resume(returning: false)
          return
        }

        do {
          try KeychainStore(itemName: user.email).save(authSession: auth)
          continuation.resume(returning: self.hasCalendarWriteAccess(user: user))
        } catch let error {
          print("Failed to save upgraded session to keychain: \(error.localizedDescription)")
          continuation.resume(returning: false)
        }
      }

      if let window = NSApplication.shared.windows.first {
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(
          byPresenting: request,
          presenting: window,
          callback: callback
        )
      } else {
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(
          byPresenting: request,
          callback: callback
        )
      }
    }
  }

  @MainActor
  func signOut(user: GoogleUser) {
    SessionManager.shared.deleteSession(for: user)
  }
}
