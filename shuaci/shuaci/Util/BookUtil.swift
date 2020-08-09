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
var currentbook_json_obj: JSON = load_json(fileName: "current_book")

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

