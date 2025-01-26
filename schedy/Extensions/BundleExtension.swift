//
//  BundleExtension.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 11/12/24.
//

import Foundation

extension Bundle {
    var releaseVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var schedyCommit: String? {
        return infoDictionary?["SchedyCommit"] as? String
    }

    var isBeta: Bool? {
        return infoDictionary?["Beta"] as? Bool
    }
}
