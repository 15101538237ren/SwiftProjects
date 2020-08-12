//
//  SettingItem.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

class SettingItem
{
    var icon: UIImage
    var name: String
    var value: String
    
    init(icon:UIImage=UIImage(), name: String="", value:String = "") {
        self.icon = icon
        self.name = name
        self.value = value
    }
}
