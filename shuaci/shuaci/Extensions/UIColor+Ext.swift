//
//  UIColor+Ext.swift
//  FoodPin
//
//  Created by 任红雷 on 3/27/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

extension UIColor{
    convenience init(red: Int, green: Int, blue: Int, alpha: Float) {
        let redV = CGFloat(red)/255.0
        let greenV = CGFloat(green)/255.0
        let blueV = CGFloat(blue)/255.0
        
        self.init(red: redV, green: greenV, blue: blueV, alpha: CGFloat(alpha))
    }
}
