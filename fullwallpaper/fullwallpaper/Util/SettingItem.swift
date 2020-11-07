//
//  SettingItem.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/7/20.
//

import Foundation
import UIKit

class SettingItem
{
    var icon: UIImage
    var name: String
    
    init(symbol_name:String, name: String) {
        if let image = UIImage(systemName: symbol_name, withConfiguration: UIImage.SymbolConfiguration(weight: .regular)) {
            self.icon = image
        }else{
            let image: UIImage = UIImage(named: symbol_name) ?? UIImage()
            self.icon = image
        }
        self.name = name
    }
}
