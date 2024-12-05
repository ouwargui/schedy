//
//  GoogleUser.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 05/12/24.
//

import Foundation
import SwiftData

@Model
class GoogleUser {
    var id: String
    var email: String
    @Relationship(deleteRule: .cascade) var calendars: [Calendar]
    
    init(id: String, email: String, calendars: [Calendar] = []) {
        self.id = id
        self.email = email
        self.calendars = calendars
    }
}
