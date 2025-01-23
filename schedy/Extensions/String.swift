//
//  String.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 23/01/25.
//

import Foundation

extension String {
    func truncated() -> Substring {
        let truncatedString = prefix(15)
        if truncatedString.count < 15 {
            return truncatedString
        } else {
            return "\(truncatedString)..."
        }
    }
}
