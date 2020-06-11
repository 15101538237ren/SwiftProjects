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

var current_book_id:String = "Level4_1"
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
    1 : ["category":  [0:"出国"], "subcategory": [0:"全部", 1: "雅思", 2: "托福", 3: "GRE", 4: "SAT", 5: "GMAT", 6: "MBA", 7: "其他"]],
    2: ["category": [0:"高中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "北师大版", 5: "牛津译林版", 6: "牛津上海版", 7: "其他"]],
    3: ["category": [0:"考研"], "subcategory": [0:"全部"]],
    4: ["category": [0:"四六级"], "subcategory": [0:"全部", 1: "四级", 2: "六级"]],
    5: ["category": [0:"英专"], "subcategory": [0:"全部", 1: "专四", 2: "专八"]],
    6: ["category": [0:"初中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "沪教牛津版", 5: "苏教牛津版", 6: "仁爱版", 7: "鲁教版", 8: "牛津译林版", 9: "其他"]],
    7: ["category": [0:"词组"], "subcategory": [0:"全部"]],
    8: ["category": [0:"小学"], "subcategory": [0:"全部", 1: "人教版"]],
    9: ["category": [0:"实用"], "subcategory": [0:"全部", 1: "职场商务", 2: "日常交流", 3: "旅游英语"]]
]

