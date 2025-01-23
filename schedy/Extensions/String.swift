//
//  String.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 23/01/25.
//

import Foundation

extension String {
    func truncated(maxLength: Int = 25) -> Substring {
        let truncatedString = prefix(maxLength)
        if truncatedString.count < 15 {
            return truncatedString
        } else {
            return "\(truncatedString)..."
        }
    }
}
