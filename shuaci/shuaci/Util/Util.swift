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
