//
//  ThemeUtil.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import SwiftyJSON
import SwiftTheme

enum theme: String {
    case lightGray = "Light_Gray"
    case lightBlack = "Light_Black"
    case lightWhite = "Light_White"
    case dark = "Dark"
    case night = "Night"
}

var theme_category_to_name:[Int : theme] = [ 1: .lightBlack, 2: .dark, 3: .night, 4: .lightWhite, 5: .lightWhite, 6: .lightWhite, 7: .lightWhite, 8: .lightGray, 9: .lightWhite, 10: .lightWhite]

var themes:[Theme] = [
    Theme(name: "明 亮", background: "1_Light", category: 1),
    Theme(name: "深 邃", background: "2_Dark", category: 2),
    Theme(name: "粉 色", background: "8_Pink", category: 8),
    Theme(name: "红 色", background: "5_Red", category: 5),
    Theme(name: "橙 色", background: "6_Orange", category: 6),
    Theme(name: "绿 色", background: "4_Green", category: 4),
    Theme(name: "蓝 色", background: "7_Blue", category: 7),
    Theme(name: "紫 色", background: "10_Purple", category: 10),
    Theme(name: "棕 色", background: "9_Brown", category: 9),
    Theme(name: "夜 晚", background: "3_Night", category: 3)
]

var default_wallpapers:[Wallpaper] = [
    Wallpaper(word: "peony", trans: "牡丹", category: 1), //Light
    Wallpaper(word: "firework", trans: "烟花", category: 2), //Dark
    Wallpaper(word: "moon", trans: "月球", category: 3), //Black
    Wallpaper(word: "leaf", trans: "叶子", category: 4), // Green
    Wallpaper(word: "canyon", trans: "峡谷", category: 5), // Red
    Wallpaper(word: "pawpaw", trans: "木瓜", category: 6), //Yellow
    Wallpaper(word: "santorini", trans: "[希腊]圣托里尼", category: 7), //Blue
    Wallpaper(word: "blossom", trans: "花开", category: 8), //Pink
    Wallpaper(word: "latte", trans: "拿铁", category: 9), // Brown
    Wallpaper(word: "lavender", trans: "薰衣草", category: 10), // Purple
]


var cardBackgrounds: [Int: String] = [
    1 : "light-blue",
    2 : "dark_blue",
    3 : "black",
    4 : "green",
    5 : "red",
    6 : "orange",
    7 : "blue",
    8 : "pink",
    9 : "brown",
    10 : "purple",
]



func getBlurEffect() -> UIBlurEffect {
    if let blurEffectName = ThemeManager.currentTheme?.value(forKeyPath: "Global.blurEffectStyle") as! String?{
        switch blurEffectName {
            case "light":
                return UIBlurEffect(style: UIBlurEffect.Style.light)
            case "dark":
                return UIBlurEffect(style: UIBlurEffect.Style.dark)
            default:
                return UIBlurEffect(style: UIBlurEffect.Style.light)
        }
    }
    else{
        return UIBlurEffect(style: UIBlurEffect.Style.light)
    }
}
