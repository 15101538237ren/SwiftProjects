//
//  Util.swift
//  shuaci
//
//  Created by 任红雷 on 5/2/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

let theme_category_string = "theme_category"
let last_theme_category_string = "last_theme_category"
let trans_string = "trans"
let word_string = "word"

let categories = [
    1 : ["category":  "出国", "subcategory": [1: "雅思", 2: "托福", 3: "GRE", 4: "SAT", 5: "GMAT", 6: "MBA", 7: "其他"]],
    2: ["category": "高中", "subcategory": [1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "北师大版", 5: "牛津译林版", 6: "牛津上海版", 7: "其他"]],
    3: ["category": "考研"],
    4: ["category": "四六级", "subcategory": [1: "四级", 2: "六级"]],
    5: ["category": "英专", "subcategory": [1: "专四", 2: "专八"]],
    6: ["category": "初中", "subcategory": [1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "沪教牛津版", 5: "苏教牛津版", 6: "仁爱版", 7: "鲁教版", 8: "牛津译林版", 9: "其他"]],
    7: ["category": "词组"],
    8: ["category": "小学", "subcategory": [1: "人教版"]],
    9: ["category": "实用", "subcategory": [1: "职场商务", 2: "日常交流", 3: "旅游英语"]]]

var default_wallpapers:[Wallpaper] = [
    Wallpaper(word: "lilac", trans: "紫丁香", category: 1),
    Wallpaper(word: "astronaut", trans: "宇航员", category: 2),
    Wallpaper(word: "rocket", trans: "火箭", category: 3),
    Wallpaper(word: "pineapple", trans: "菠萝", category: 4),
    Wallpaper(word: "rose", trans: "玫瑰", category: 5),
    Wallpaper(word: "pawpaw", trans: "木瓜", category: 6),
    Wallpaper(word: "ocean", trans: "海洋", category: 7),
    Wallpaper(word: "peony", trans: "牡丹", category: 8),
    Wallpaper(word: "latte", trans: "拿铁", category: 9)
]
var current_wallpaper: Wallpaper = default_wallpapers[0]
var current_wallpaper_image: UIImage = UIImage()

var themes:[Theme] = [
    Theme(name: "明亮", background: "1_light", category: 1),
    Theme(name: "热情", background: "2_passionate", category: 5),
    Theme(name: "暖秋", background: "3_fall", category: 6),
    Theme(name: "盛夏", background: "4_summer", category: 4),
    Theme(name: "海洋", background: "5_sea_blue", category: 7),
    Theme(name: "夜空", background: "6_dark_night", category: 2)
]

var textColors:[Int:UIColor] = [ 1: UIColor.black, 2: UIColor.white, 3: UIColor.gray, 4: UIColor.white, 5: UIColor.white, 6: UIColor.white, 7: UIColor.white, 8: UIColor.white, 9: UIColor.white]

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func loadUserPhoto() -> UIImage?{
    let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
    do {
        let imageData = try Data(contentsOf: imageFileURL)
        return UIImage(data: imageData)
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}
