import Foundation
import SwiftUI

struct AccountView: View {
    @Bindable var user: GoogleUser
    @State private var isDeleteAccountAlertPresented: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            VStack(alignment: .leading) {
                Text(user.email)

                if let lastSyncedString = user.getLastSyncRelativeTime() {
                    Text("Last synced at: \(lastSyncedString)")
                } else {
                    Text("Not synced")
                }
            }
            Spacer()
            Button(action: self.showDeleteAccountAlert) {
                Label(LocalizedString.capitalized("remove"), systemImage: "trash.fill")
            }
            .buttonBorderShape(.roundedRectangle(radius: 5))
            .alert("Remove account from Schedy?", isPresented: self.$isDeleteAccountAlertPresented, actions: {
                HStack {
                    Button(
                        "Remove account",
                        systemImage: "exclamationmark.triangle.fill",
                        role: .destructive,
                        action: self.signOut
                    )

                    Button("Cancel", role: .cancel, action: self.hideDeleteAccountAlert)
                }
            }, message: {
                Text("All calendars and events related to this account will be removed too.")
            })
        }
    }

    private func hideDeleteAccountAlert() {
        self.isDeleteAccountAlertPresented = false
    }

    private func showDeleteAccountAlert() {
        self.isDeleteAccountAlertPresented = true
    }

    private func signOut() {
        GoogleAuthService.shared.signOut(user: self.user)
    }
}
