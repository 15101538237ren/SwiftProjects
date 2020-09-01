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

public protocol Queue { associatedtype Q }

/// FIFO (first-in first-out) Queue
extension Array: Queue {

  public typealias Q = Element

  // /Add this element at the end of the queue
  public mutating func enqueue(_ element: Q) {
    self.append(element)
  }

  /// Returns and remove the first element of the quemutating ue
  public mutating func dequeue() -> Q? {
    return self.removeFirst()
  }

  /// Returns the first element of the queue
  public func peekQueue() -> Q? {
    return self.first
  }
}
