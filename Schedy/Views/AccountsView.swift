import Foundation
import SwiftData
import SwiftUI

struct AccountsView: View {
  @EnvironmentObject private var appDelegate: AppDelegate
  @Query var users: [GoogleUser]

  var body: some View {
    if self.users.isEmpty {
      ContentUnavailableView {
        Label("You don't have any accounts yet", systemImage: "person.2.slash")
      } description: {
        Button(action: self.signIn) {
          Label("Add your first account", systemImage: "person.fill.badge.plus")
        }
      }
    } else {
      VStack {
        List(self.users) { user in
          AccountView(user: user)
        }
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: self.signIn) {
            Image(systemName: "person.fill.badge.plus")
          }
          .help("Add a new account")
        }
      }
    }
  }

  private func signIn() {
    self.appDelegate.currentAuthorizationFlow = GoogleAuthService.shared.signIn(
      appDelegate: self.appDelegate)
  }
}

// #Preview {
//    AccountsView()
//        .modelContainer(SwiftDataManager.shared.container)
// }
