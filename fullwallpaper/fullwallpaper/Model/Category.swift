//
//  Category.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation

struct Category: Codable {
    var name: String
    var eng: String
    var coverUrl: String
    var pro: Bool
    init(name: String, eng: String, coverUrl: String, pro:Bool) {
        self.name = name
        self.eng = eng
        self.coverUrl = coverUrl
        self.pro = pro
    }
}
