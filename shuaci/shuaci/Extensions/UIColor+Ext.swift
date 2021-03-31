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
    
    convenience init?(hex: String, alpha: CGFloat = 1) {
        var chars = Array(hex.hasPrefix("#") ? hex.dropFirst() : hex[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: alpha)
    }
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)

            return (red, green, blue, alpha)
        }
}

