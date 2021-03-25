//
//  Collection+Ext.swift
//  shuaci
//
//  Created by 任红雷 on 5/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation


extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}

extension RangeReplaceableCollection {
    /// Returns a new Collection shuffled
    var shuffled: Self { .init(shuffled()) }
    /// Shuffles this Collection in place
    @discardableResult
    mutating func shuffledInPlace() -> Self  {
        self = shuffled
        return self
    }
    func choose(_ n: Int) -> SubSequence { shuffled.prefix(n) }
}
