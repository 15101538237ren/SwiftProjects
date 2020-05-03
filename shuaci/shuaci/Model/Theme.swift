//
//  Theme.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    var name: String = ""
    var background: String = ""
    var category: Int = 0

    init(name: String, background: String, category: Int) {
        self.name = name
        self.background = background
        self.category = category
    }
}
