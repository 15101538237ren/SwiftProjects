//
//  BookUtil.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import SwiftyJSON

var category_items:[Int: String] = [0:"全部"]
var selected_category:Int = 1
var selected_subcategory: Int = 0

var currentSelectedCategory:Int = 0
var currentSelectedSubCategory:Int = 0

var books: [Book] = []
var global_total_books: [Book] = []
var global_total_items: [LCObject] = []
var resultsItems: [LCObject] = []
var currentbook_json_obj: JSON = []

let categories:[Int: [String: [Int: String]]] = [
    0: ["category": [0:"全部"], "subcategory": [0:"全部"]],
    1 : ["category":  [0:"出国"], "subcategory": [0:"全部", 1: "雅思", 2: "托福", 3: "GRE", 4: "SAT", 5: "GMAT", 6: "MBA", 7: "ACT", 8: "其他"]],
    2: ["category": [0:"高中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "北师大版", 5: "牛津译林版", 6: "牛津上海版", 7: "其他"]],
    3: ["category": [0:"大学"], "subcategory": [0:"全部", 1: "四级", 2: "六级", 3: "考研", 4: "考博", 5: "大学教材"]],
    4: ["category": [0:"英专"], "subcategory": [0:"全部", 1: "专四", 2: "专八"]],
    5: ["category": [0:"初中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "沪教版", 4: "外研版", 5: "上海版", 6: "译林版", 7: "鲁教版", 8: "仁爱版", 9: "冀教版"]],
    6: ["category": [0:"小学"], "subcategory": [0:"全部", 1: "人教版", 2: "北京版", 3: "北师大版", 4: "译林版", 5: "沪教版" , 6: "冀教版", 7: "湘少版", 8: "教科版", 9: "外研版", 10: "广州版" , 11: "闽教版", 12: "科普版", 13: "广东版", 14: "陕西版", 15: "其他"]],
    7: ["category": [0:"实用"], "subcategory": [0:"全部", 1: "职场商务", 2: "日常交流", 3: "旅游英语"]],
    8: ["category": [0:"其他"], "subcategory": [0:"全部", 1: "词组", 2: "新概念", 3: "老版词书", 4: "词汇量", 9: "全国等级考试", 10: "其他"]],
]

let categories_with_fullnames:[Int] = [2, 5, 6]

let color_categories:[Int :[Int:String]] = [1 : [1: "red1", 2: "red1", 3: "red1", 4: "red2", 5: "red2", 6: "red2", 7: "red2", 8: "red2"],
                        2: [1: "blue1", 2: "blue2", 3: "blue3", 4: "blue4", 5: "blue4", 6: "blue1", 7: "blue2"],
                        3: [1: "purple1", 2: "purple2", 3: "purple3", 4: "purple4", 5: "purple4"],
                        4: [1: "blue5", 2: "green6"],
                        5: [1: "green1", 2: "green2", 3: "green3",
                                                               4: "green4", 5: "green5", 6: "green6",
                                                               7: "green1", 8: "green2", 9: "green3"],
                        6: [1: "pink1", 2: "pink2", 3: "red2", 4: "orange1", 5: "orange2"
                            , 6: "yellow2", 7: "yellow1", 8: "blue2", 9: "blue3", 10: "yellow2"
                            , 11: "green1", 12: "red1", 13: "blue1", 14: "purple1", 15: "purple2"],
                        7: [1: "brown1", 2: "brown2", 3: "brown3"],
                        8: [1: "orange1", 2: "orange1", 3: "yellow2", 4: "yellow1", 9: "yellow1", 10: "yellow2"]]

let light_color_palatte = ["pink1": "f6bed6", "pink2": "ffc1fa",
                           "red1": "cf1b1b", "red2": "f67280",
                           "orange1": "fa7d09", "orange2": "ffcdab", "orange3": "ff8585",
                           "yellow1": "edbc49", "yellow2": "f7b679",
                           "green1": "76bd69", "green2": "a2de96", "green3": "a7d7c5", "green4": "cdffeb", "green5": "c6e377", "green6": "b9e937",
                          "blue1": "b2ebf2", "blue2": "bbe1fa", "blue3": "1e56a0", "blue4": "2e94b9", "blue5": "c7eeff",
                          "purple1": "8186d5", "purple2": "a06ee1", "purple3": "caabd8", "purple4": "9873b9",
                          "brown1": "905858", "brown2": "d2c8c8", "brown3": "d65f00"]

let dark_color_palatte = ["pink1": "e79cc2", "pink2": "f09ae9",
                          "red1": "900d0d", "red2": "c06c84",
                          "orange1": "ff4301", "orange2": "ffcdab", "orange3": "ff5757",
                          "yellow1": "e79c2a", "yellow2": "ffd00c",
                          "green1": "46914e", "green2": "3ca59d", "green3": "74b49b", "green4": "009f9d", "green5": "729d39", "green6": "57d131",
                          "blue1": "00bcd4", "blue2": "3282b8", "blue3": "163172", "blue4": "005691", "blue5": "2e94b9",
                          "purple1": "494ca2", "purple2": "421b9b", "purple3": "9873b9", "purple4": "0077c0",
                          "brown1": "5d3a3a", "brown2": "a3816a", "brown3": "c04d00"]

func getCurrentBook(preference: Preference) -> Book?{
    if let bookId = preference.current_book_id{
        if currentbook_json_obj.count == 0{
            currentbook_json_obj = load_json(fileName: bookId)
        }
        
        let chapters = currentbook_json_obj["chapters"].arrayValue
        var word_num:Int = 0
        for chpt_idx in 0..<chapters.count{
            let chapter = chapters[chpt_idx]
            word_num += chapter["word_heads"].arrayValue.count
        }
        
        let level1_category = currentbook_json_obj["level1_category"].intValue
        let level2_category = currentbook_json_obj["level2_category"].intValue
        let book_name = currentbook_json_obj["name"].stringValue
        let description = currentbook_json_obj["description"].stringValue
        let recite_user_num = currentbook_json_obj["recite_user_num"].intValue
        let file_sz = currentbook_json_obj["file_sz"].floatValue
        let nchpt = chapters.count
        let avg_nwchpt = currentbook_json_obj["avg_nwchpt"].intValue
        let nwchpt = currentbook_json_obj["nwchpt"].stringValue
        let book:Book = Book(objectId: bookId, identifier: bookId, level1_category: level1_category, level2_category: level2_category, name: book_name, description: description, word_num: word_num, recite_user_num: recite_user_num, file_sz: file_sz, nchpt: nchpt, avg_nwchpt: avg_nwchpt, nwchpt: nwchpt)

        return book
    }
    return nil
}
