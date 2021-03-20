//
//  UIColor+Ext.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/17/20.
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
}

