//
//  SwiftDataManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 05/12/24.
//

import Foundation
import SwiftData

@MainActor
struct SwiftDataManager {
    static let shared = SwiftDataManager()
    var container: ModelContainer
    
    private init() {
        let configuration = ModelConfiguration(for: GoogleUser.self, isStoredInMemoryOnly: false)
        
        let schema = Schema([GoogleUser.self])
        
        self.container = try! ModelContainer(for: schema, configurations: [configuration])
    }
    
    func fetchAll<T: PersistentModel>(fetchDescriptor: FetchDescriptor<T>) -> [T]? {
        return try? self.container.mainContext.fetch(fetchDescriptor)
    }
    
    func insert<T: PersistentModel>(model: T) {
        self.container.mainContext.insert(model)
        self.save()
    }
    
    func delete<T: PersistentModel>(model: T) {
        self.container.mainContext.delete(model)
        self.save()
    }
    
    func delete<T: PersistentModel>(model: T.Type, where predicate: Predicate<T>) throws {
        try self.container.mainContext.delete(model: model, where: predicate)
        self.save()
    }
    
    func batchInsert<T: PersistentModel>(models: [T]) {
        models.forEach { model in
            self.container.mainContext.insert(model)
        }
        self.save()
    }
    
    func update() {
        self.save()
    }
    
    private func save() {
        try! self.container.mainContext.save()
    }
}
