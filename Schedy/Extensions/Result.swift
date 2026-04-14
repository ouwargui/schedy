import Foundation

// We're already checking if the result is a failure
// swiftlint:disable force_try
extension Result {
  func unwrapOrFatalError(message: String) -> Success {
    if case .failure(let failure) = self {
      fatalError("\(message): \(failure.localizedDescription)")
    }

    return try! self.get()
  }

  func unwrapOrNil() -> Success? {
    if case .failure(let failure) = self {
      print("Error: \(failure.localizedDescription)")
      return nil
    }

    return try! self.get()
  }
}
// swiftlint:enable force_try
