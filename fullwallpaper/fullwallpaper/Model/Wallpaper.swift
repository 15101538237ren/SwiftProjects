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
    var thumbnailUrl: String
    init(name: String, category: String, thumbnailUrl: String, imgUrl: String) {
        self.name = name
        self.category = category
        self.thumbnailUrl = thumbnailUrl
        self.imgUrl = imgUrl
    }
}
