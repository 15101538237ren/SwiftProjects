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

var textColors:[Int:UIColor] = [ 1: UIColor.white, 2: UIColor.white, 3: UIColor.gray, 4: UIColor.white, 5: UIColor.white, 6: UIColor.white, 7: UIColor.white, 8: UIColor.white, 9: UIColor.white, 10: UIColor.white]

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
    Theme(name: "深 夜", background: "3_Night", category: 3)
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
