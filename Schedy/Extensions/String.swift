//
//  String.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 23/01/25.
//

import Foundation

extension String {
    func truncated(maxLength: Int = 25, trailing: String = "...") -> String {
        return (self.count > maxLength) ? self.prefix(maxLength) + trailing : self
    }
}
