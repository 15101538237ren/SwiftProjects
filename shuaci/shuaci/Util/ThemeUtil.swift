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

var theme_category_to_name:[Int : theme] = [ 1: .lightWhite, 2: .dark, 3: .night, 4: .lightWhite, 5: .lightWhite, 6: .lightWhite, 7: .lightWhite, 8: .lightWhite, 9: .lightWhite, 10: .lightWhite]

var themes:[Theme] = [
    Theme(name: lightText, background: "1_Light", category: 1),
    Theme(name: darkText, background: "2_Dark", category: 2),
    Theme(name: pinkText, background: "8_Pink", category: 8),
    Theme(name: redText, background: "5_Red", category: 5),
    Theme(name: orangeText, background: "6_Orange", category: 6),
    Theme(name: greenText, background: "4_Green", category: 4),
    Theme(name: blueText, background: "7_Blue", category: 7),
    Theme(name: purpleText, background: "10_Purple", category: 10),
    Theme(name: brownText, background: "9_Brown", category: 9),
    Theme(name: nightText, background: "3_Night", category: 3)
]

var theme_card_colors:[Int:[String]] = [
    1 : ["#ed5a65", "#f0a1a8", "#e3b4b8", "#c45a65", "#ed556a", "#ce5777", "#cc163a", "#eeb8c3", "#ba2f7b", "#9b1e64", "#ec4e8a", "#3b818c", "#51c4d3", "#0f95b0", "#1a94bc", "#66a9c9", "#93b5cf", "#144a74", "#61649f", "#8076a3", "#815c94", "#813c85", "#983680", "#c08eaf", "#869d9d", "#93d5dc", "#12aa9c", "#12a182", "#428675", "#223e36", "#248067", "#45b787", "#2bae85", "#92b3a5", "#a4cab6", "#579572", "#b9dec9", "#43b244", "#8cc269", "#d2d97a", "#5bae23", "#b7d07a", "#eed045", "#f2ce2b", "#8e804b", "#f8d86a", "#e8b004", "#ebb10d", "#ffa60f", "#f7cdbc", "#f6ad8f", "#eeaa9c", "#efafad", "#b2cf87", "#9eccab", "#10aec2", "#63bbd0", "#ef498b", "#c5708b"], //Colorful
    2 : ["#1f2623", "#144a74", "#101f30", "#1f2040", "#2d2e36", "#132c33", "#2e317c", "#322f3b"],// Dark blue
    3 : ["#1f2623", "#4e2a40", "#411c35", "#1f2040", "#132c33", "#15231b", "#393733", "#513c20", "#4b2e2b", "#481e1c", "#363433" ], //Black
    4 : ["#428675", "#1ba784", "#314a43", "#45b787", "#20a162", "#1a6840", "#61ac85", "#a4cab6", "#83cbac", "#229453", "#83a78d", "#8cc269", "#add5a2", "#253d24", "#96c24e", "#d2d97a", "#bacf65" ], //Green
    5 : ["#63071c", "#5a1216", "#7c1823", "#a7535a", "#a61b29", "#ee3f4d", "#c04851", "#f07c82", "#ee4863", "#e77c8e", "#c27c88", "#ec9bad", "#eb3c70", "#ec2c64", "#ec8aa4", "#c5708b", "#951c48", "#62102e", "#e16c96", "#de3f7c", "#461629", "#ba2f7b"], //Red
    6 : ["#d2b42c", "#fbda41", "#d2b116", "#fcc307", "#f8d86a", "#e8b004", "#d9a40e", "#feba07", "#d6a01d", "#f8bc31", "#e5b751", "#f9d27d", "#ffa60f", "#ff9900", "#fbb957", "#dc9123", "#daa45a", "#de9e44", "#fb8b05", "#f7c173", "#fc7930", "#e16723", "#f0945d"], //Yellow/Orange
    7 : ["#134857", "#132c33", "#2f90b9", "#63bbd0", "#93b5cf", "#4e7ca1", "#2474b5", "#51c4d3", "#10aec2", "#1491a8", "#29b7cb", "#1781b5", "#144a74"], //Blue
    8: ["#eea2a4", "#f0a1a8", "#e3b4b8", "#f1c4cd", "#ec9bad", "#ed9db2", "#ea7293", "#eb3c70", "#eb507e", "#de7897", "#ea517f", "#e16c96", "#ef3473", "#ec4e8a"], //Pink
    9 : ["#835e1d", "#533c1b", "#826b48", "#c09351", "#806332", "#815f25", "#553b18", "#e3bd8d", "#97846c", "#4a4035", "#5d3d21", "#d99156", "#c1651a", "#964d22", "#b7511d", "#71361d", "#b89485", "#8b614d", "#bdaead" ], //Brown
    10 : ["#2e317c", "#61649f", "#525288", "#74759b", "#8076a3", "#815c94", "#7e1671", "#894276", "#681752", "#ad6598", "#411c35", "#8b2671", "#bc84a8", "#c08eaf", "#5d3f51", "#ba2f7b", "#9b1e64", "#c06f98"] //Purple
]

var default_wallpapers:[Wallpaper] = [
    Wallpaper(word: "leaves", trans: "叶", category: 1), //Light
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


var scene_backgrounds: [Int: String] = [
    1 : "#fffef8",  //Light
    2 : "#222531", //Dark
    3 : "#040404", //Black
    4 : "#dfecd5", // Green
    5 : "#f0c9cf", // Red
    6 : "#f9f4dc",  //Yellow
    7 : "#d0dfe6",  //Blue
    8 : "#ede3e7",  //Pink
    9 : "#81776e", // Brown
    10 : "#e9d7df",  // Purple
]

var cardBackgrounds: [Int: String] = [
    1 : "light-blue",
    2 : "dark-blue",
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
