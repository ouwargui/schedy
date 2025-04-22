//
//  LocalizedString.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import Foundation

class LocalizedString {
    static func capitalized(_ key: String.LocalizationValue) -> String {
        return String(localized: key).capitalized
    }

    static func localized(_ key: String.LocalizationValue) -> String {
        return String(localized: key)
    }
}
