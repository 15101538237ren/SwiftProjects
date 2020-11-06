//
//  Category.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import UIKit

struct Category: Codable {
    var name: String
    var eng: String
    var coverUrl: String
    init(name: String, eng: String, coverUrl: String) {
        self.name = name
        self.eng = eng
        self.coverUrl = coverUrl
    }
}
