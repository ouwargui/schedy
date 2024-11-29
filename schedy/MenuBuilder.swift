//
//  MenuBuilder.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import AppKit
import Foundation

class MenuBuilder {
    static func build() -> NSMenu {
        let menu = NSMenu()
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE, d MMM")
        let dateString = dateFormatter.string(from: Date())
        
        let todayText = LocalizedString.capitalized("today")
        menu.addItem(createMenuItem(title: "\(todayText) (\(dateString)):", action: nil))
        menu.addItem(.separator())
        menu.addItem(createMenuItem(title: LocalizedString.capitalized("open-settings"), action: #selector(showSettings)))
        
        return menu
    }
                     
    @objc private static func showSettings() {
        NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    private static func createMenuItem(title: String, action: Selector? = nil, keyEquivalent: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.isEnabled = action != nil
        item.target = self
        print(item.title, item.isEnabled)
        return item
    }
}
