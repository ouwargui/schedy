//
//  SwiftDataManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 05/12/24.
//

import Foundation
import SwiftData

struct SwiftDataManager {
    static let shared = SwiftDataManager()
    var container: ModelContainer
    
    private init() {
        let configuration = ModelConfiguration(for: GoogleUser.self, isStoredInMemoryOnly: false)
        
        let schema = Schema([GoogleUser.self])
        
        self.container = try! ModelContainer(for: schema, configurations: [configuration])
    }
}
