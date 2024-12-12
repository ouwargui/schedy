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
}