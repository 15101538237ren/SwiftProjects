//
//  Wallpaper.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/6/20.
//

import Foundation

struct Wallpaper: Codable {
    var name: String
    var category: String
    var imgUrl: String
    init(name: String, category: String, imgUrl: String) {
        self.name = name
        self.category = category
        self.imgUrl = imgUrl
    }
}
