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
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

