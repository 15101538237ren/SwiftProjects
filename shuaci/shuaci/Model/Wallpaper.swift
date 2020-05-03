//
//  Wallpaper.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct Wallpaper {
    var word: String = ""
    var trans: String = ""
    var category: Int = 0

    init(word: String, trans: String, category: Int) {
        self.word = word
        self.trans = trans
        self.category = category
    }
}
