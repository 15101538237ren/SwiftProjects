//
//  MenuItem.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import Foundation
import UIKit

class MenuItem
{
    var icon: UIImage
    var name: String
    
    init(icon_name:String="", name: String="") {
        if let image = UIImage(systemName: icon_name, withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) {
            self.icon = image
        }else{
            let image: UIImage = UIImage(named: icon_name) ?? UIImage()
            self.icon = image
        }
        self.name = name
    }
}
