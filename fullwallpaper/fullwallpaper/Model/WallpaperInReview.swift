//
//  WallpaperInReview.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/5/20.
//

import Foundation

struct WallpaperInReview: Codable {
    var objectId: String
    var caption: String
    var category: String
    var status: Int
    var collectionName: String
    var imgUrl: String
    var thumbnailUrl: String
    var createdAt: String
    
    init(objectId: String, caption: String, status: Int, category: String, collectionName: String, thumbnailUrl: String, imgUrl: String, createdAt: String) {
        self.objectId = objectId
        self.caption = caption
        self.status = status
        self.category = category
        self.collectionName = collectionName
        self.thumbnailUrl = thumbnailUrl
        self.imgUrl = imgUrl
        self.createdAt = createdAt
    }
}
