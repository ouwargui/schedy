import Foundation
import SwiftData

@MainActor
struct SwiftDataManager: DataManaging {
  static let shared = SwiftDataManager()
  var container: ModelContainer

  private init() {
    let configuration = ModelConfiguration(for: GoogleUser.self, isStoredInMemoryOnly: false)

    let schema = Schema([GoogleUser.self])

    self.container = Result {
      try ModelContainer(for: schema, configurations: [configuration])
    }.unwrapOrFatalError(message: "Error creating modelContainer")
  }

  func fetchAll<T: PersistentModel>(fetchDescriptor: FetchDescriptor<T>) -> Result<[T], Error> {
    return Result { try self.container.mainContext.fetch(fetchDescriptor) }
  }

  func insert<T: PersistentModel>(model: T) {
    self.container.mainContext.insert(model)
    guard self.save().unwrapOrNil() != nil else {
      return
    }
  }

  func delete<T: PersistentModel>(model: T) {
    self.container.mainContext.delete(model)
    guard self.save().unwrapOrNil() != nil else {
      return
    }
  }

  /**
     If called without Predicate, everything will be deleted for the model
     */
  func delete<T: PersistentModel>(model: T.Type, where predicate: Predicate<T>? = nil) throws {
    try self.container.mainContext.delete(model: model, where: predicate)
    guard self.save().unwrapOrNil() != nil else {
      return
    }
  }

  func batchInsert<T: PersistentModel>(models: [T]) {
    models.forEach { model in
      self.container.mainContext.insert(model)
    }
    guard self.save().unwrapOrNil() != nil else {
      return
    }
  }

  func update() {
    guard self.save().unwrapOrNil() != nil else {
      return
    }
  }

  private func save() -> Result<Void, Error> {
    return Result { try self.container.mainContext.save() }
  }
}
