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
    init(name: String, eng: String) {
        self.name = name
        self.eng = eng
    }
}
