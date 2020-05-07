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
var selected_category:Int = 1
var selected_subcategory: Int = 0
var imageCache = NSCache<NSString, NSURL>()
var bookCache = NSCache<NSString, Book>()
let categories:[Int: [String: [Int: String]]] = [
    1 : ["category":  [0:"出国"], "subcategory": [1: "雅思", 2: "托福", 3: "GRE", 4: "SAT", 5: "GMAT", 6: "MBA", 7: "其他"]],
    2: ["category": [0:"高中"], "subcategory": [1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "北师大版", 5: "牛津译林版", 6: "牛津上海版", 7: "其他"]],
    3: ["category": [0:"考研"]],
    4: ["category": [0:"四六级"], "subcategory": [1: "四级", 2: "六级"]],
    5: ["category": [0:"英专"], "subcategory": [1: "专四", 2: "专八"]],
    6: ["category": [0:"初中"], "subcategory": [1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "沪教牛津版", 5: "苏教牛津版", 6: "仁爱版", 7: "鲁教版", 8: "牛津译林版", 9: "其他"]],
    7: ["category": [0:"词组"]],
    8: ["category": [0:"小学"], "subcategory": [1: "人教版"]],
    9: ["category": [0:"实用"], "subcategory": [1: "职场商务", 2: "日常交流", 3: "旅游英语"]]]

let book_info_dict = [
    "BEC_2": ["level1_category": 9, "level2_category": 1],
    "BEC_3": ["level1_category": 9, "level2_category": 1],
    "BeiShiGaoZhong_1": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_2": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_3": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_4": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_5": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_6": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_7": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_8": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_9": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_10": ["level1_category": 2, "level2_category": 4],
    "BeiShiGaoZhong_11": ["level1_category": 2, "level2_category": 4],
    "CET4_1": ["level1_category": 4, "level2_category": 1],
    "CET4_2": ["level1_category": 4, "level2_category": 1],
    "CET4_3": ["level1_category": 4, "level2_category": 1],
    "CET4luan_1": ["level1_category": 4, "level2_category": 1],
    "CET4luan_2": ["level1_category": 4, "level2_category": 1],
    "CET6_1": ["level1_category": 4, "level2_category": 2],
    "CET6_2": ["level1_category": 4, "level2_category": 2],
    "CET6_3": ["level1_category": 4, "level2_category": 2],
    "CET6luan_1": ["level1_category": 4, "level2_category": 2],
    "ChuZhong_2": ["level1_category": 6, "level2_category": 9],
    "ChuZhong_3": ["level1_category": 6, "level2_category": 9],
    "ChuZhongluan_2": ["level1_category": 6, "level2_category": 9],
    "GaoZhong_2": ["level1_category": 2, "level2_category": 7],
    "GaoZhong_3": ["level1_category": 2, "level2_category": 7],
    "GaoZhongluan_2": ["level1_category": 2, "level2_category": 7],
    "GMAT_2": ["level1_category": 1, "level2_category": 5],
    "GMAT_3": ["level1_category": 1, "level2_category": 5],
    "GMATluan_2": ["level1_category": 1, "level2_category": 5],
    "GRE_2": ["level1_category": 1, "level2_category": 3],
    "GRE_3": ["level1_category": 1, "level2_category": 3],
    "IELTS_2": ["level1_category": 1, "level2_category": 1],
    "IELTS_3": ["level1_category": 1, "level2_category": 1],
    "IELTSluan_2": ["level1_category": 1, "level2_category": 1],
    "KaoYan_1": ["level1_category": 3, "level2_category": -1],
    "KaoYan_2": ["level1_category": 3, "level2_category": -1],
    "KaoYan_3": ["level1_category": 3, "level2_category": -1],
    "KaoYanluan_1": ["level1_category": 3, "level2_category": -1],
    "Level4_1": ["level1_category": 5, "level2_category": 1],
    "Level4_2": ["level1_category": 5, "level2_category": 1],
    "Level4luan_1": ["level1_category": 5, "level2_category": 1],
    "Level4luan_2": ["level1_category": 5, "level2_category": 1],
    "Level8_1": ["level1_category": 5, "level2_category": 2],
    "Level8_2": ["level1_category": 5, "level2_category": 2],
    "Level8luan_2": ["level1_category": 5, "level2_category": 2],
    "PEPChuZhong7_1": ["level1_category": 6, "level2_category": 2],
    "PEPChuZhong7_2": ["level1_category": 6, "level2_category": 2],
    "PEPChuZhong8_1": ["level1_category": 6, "level2_category": 2],
    "PEPChuZhong8_2": ["level1_category": 6, "level2_category": 2],
    "PEPChuZhong9_1": ["level1_category": 6, "level2_category": 2],
    "PEPGaoZhong_1": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_2": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_3": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_4": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_5": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_6": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_7": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_8": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_9": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_10": ["level1_category": 2, "level2_category": 2],
    "PEPGaoZhong_11": ["level1_category": 2, "level2_category": 2],
    "PEPXiaoXue3_1": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue3_2": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue4_1": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue4_2": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue5_1": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue5_2": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue6_1": ["level1_category": 8, "level2_category": 1],
    "PEPXiaoXue6_2": ["level1_category": 8, "level2_category": 1],
    "SAT_2": ["level1_category": 1, "level2_category": 4],
    "SAT_3": ["level1_category": 1, "level2_category": 4],
    "TOEFL_2": ["level1_category": 1, "level2_category": 2],
    "TOEFL_3": ["level1_category": 1, "level2_category": 2],
    "WaiYanSheChuZhong_1": ["level1_category": 6, "level2_category": 3],
    "WaiYanSheChuZhong_2": ["level1_category": 6, "level2_category": 3],
    "WaiYanSheChuZhong_3": ["level1_category": 6, "level2_category": 3],
    "WaiYanSheChuZhong_4": ["level1_category": 6, "level2_category": 3],
    "WaiYanSheChuZhong_5": ["level1_category": 6, "level2_category": 3],
    "WaiYanSheChuZhong_6": ["level1_category": 6, "level2_category": 3]
]

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
