//
//  String+Ext.swift
//  fullwallpaper
//
//  Created by ByteDance on 8/29/24.
//

import Foundation

extension String {
    
    func splitIntoArray(by separators: CharacterSet = CharacterSet(charactersIn: ",; .")) -> [String] {
        return self.components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func isAlphanumeric() -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics
        return self.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
    }
}
