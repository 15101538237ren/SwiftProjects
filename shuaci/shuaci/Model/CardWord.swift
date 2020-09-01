//
//  CardWord.swift
//  shuaci
//
//  Created by 任红雷 on 5/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

class CardWord
{
    var headWord: String
    var meaning: String
    var phone: String
    var accent: String
    var memMethod: String
    init(headWord: String, meaning:String, phone: String,accent: String="美", memMethod: String = "") {
        self.headWord = headWord
        self.phone = phone
        self.accent = accent
        self.meaning = meaning
        self.memMethod = memMethod
    }
}
