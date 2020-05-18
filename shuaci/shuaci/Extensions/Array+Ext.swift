//
//  Array+Ext.swift
//  shuaci
//
//  Created by 任红雷 on 5/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
