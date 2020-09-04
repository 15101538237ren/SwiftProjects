//
//  SettingItem.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)

class SettingItem
{
    var icon: UIImage
    var name: String
    var value: String
    
    init(symbol_name:String="", name: String="", value:String = "") {
        if let image = UIImage(systemName: symbol_name, withConfiguration: UIImage.SymbolConfiguration(weight: .regular)) {
            self.icon = image
        }else{
            let image: UIImage = UIImage(named: symbol_name) ?? UIImage()
            self.icon = image
        }
        self.name = name
        self.value = value
    }
}
