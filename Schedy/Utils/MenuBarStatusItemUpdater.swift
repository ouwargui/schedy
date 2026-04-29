import AppKit

@MainActor
enum MenuBarStatusItemUpdater {
  static func updateTitle(_ title: String, matchingPreviousTitle previousTitle: String?) {
    guard let statusItem = self.statusItem(matchingPreviousTitle: previousTitle) else { return }

    statusItem.length = NSStatusItem.variableLength
    statusItem.button?.title = title
  }

  private static func statusItem(matchingPreviousTitle previousTitle: String?) -> NSStatusItem? {
    let statusItems = self.statusItems()

    if let previousTitle,
      let matchingStatusItem = statusItems.first(where: { $0.button?.title == previousTitle })
    {  // swiftlint:disable:this opening_brace
      return matchingStatusItem
    }

    return statusItems.first
  }

  private static func statusItems() -> [NSStatusItem] {
    let selector = NSSelectorFromString("_statusItems")
    guard NSStatusBar.system.responds(to: selector),
      let pointerArray = NSStatusBar.system.perform(selector)?.takeUnretainedValue()
        as? NSPointerArray
    else {
      return []
    }

    return pointerArray.allObjects.compactMap { $0 as? NSStatusItem }
  }
}
