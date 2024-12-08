//
//  AccountsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 08/12/24.
//

import Foundation
import SwiftUI
import SwiftData

struct AccountsView: View {
    @Query var users: [GoogleUser]
    
    var body: some View {
        List(self.users) { user in
            HStack {
                Image(systemName: "person.fill")
                Spacer()
                VStack(alignment: .leading) {
                    Text(user.email)
                    
                    if let lastSyncedString = user.getLastSyncRelativeTime() {
                        Text("Last synced at: \(lastSyncedString)")
                    } else {
                        Text("Not synced")
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Button("Sync now") {}
                    Button("Sign out", role: .destructive) {}
                }
            }
        }
    }
}
