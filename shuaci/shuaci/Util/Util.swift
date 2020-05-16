//
//  Util.swift
//  shuaci
//
//  Created by 任红雷 on 5/2/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import SwiftyJSON

let theme_category_string = "theme_category"
let last_theme_category_string = "last_theme_category"
let trans_string = "trans"
let word_string = "word"
var selected_category:Int = 1
var selected_subcategory: Int = 0
var imageCache = NSCache<NSString, NSURL>()
var books: [Book] = []
var global_total_books: [Book] = []
var global_total_items: [LCObject] = []
var resultsItems: [LCObject] = []

var currentSelectedCategory:Int = 0
var currentSelectedSubCategory:Int = 0
var category_items:[Int: String] = [0:"全部"]
var current_book_id:String = "Level4_1"
let categories:[Int: [String: [Int: String]]] = [ 0: ["category": [0:"全部"], "subcategory": [0:"全部"]], 
    1 : ["category":  [0:"出国"], "subcategory": [0:"全部", 1: "雅思", 2: "托福", 3: "GRE", 4: "SAT", 5: "GMAT", 6: "MBA", 7: "其他"]],
    2: ["category": [0:"高中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "北师大版", 5: "牛津译林版", 6: "牛津上海版", 7: "其他"]],
    3: ["category": [0:"考研"], "subcategory": [0:"全部"]],
    4: ["category": [0:"四六级"], "subcategory": [0:"全部", 1: "四级", 2: "六级"]],
    5: ["category": [0:"英专"], "subcategory": [0:"全部", 1: "专四", 2: "专八"]],
    6: ["category": [0:"初中"], "subcategory": [0:"全部", 1: "考纲核心", 2: "人教版", 3: "外研社版", 4: "沪教牛津版", 5: "苏教牛津版", 6: "仁爱版", 7: "鲁教版", 8: "牛津译林版", 9: "其他"]],
    7: ["category": [0:"词组"], "subcategory": [0:"全部"]],
    8: ["category": [0:"小学"], "subcategory": [0:"全部", 1: "人教版"]],
    9: ["category": [0:"实用"], "subcategory": [0:"全部", 1: "职场商务", 2: "日常交流", 3: "旅游英语"]]]

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

var cardBackgrounds: [Int: String] = [
    1 : "light-blue",
    5 : "red",
    6 : "orange",
    4 : "green",
    7 : "blue",
    2 : "dark_blue"
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

func savejson(fileName: String, jsonData: Data){
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(fileName).json")

        try jsonData.write(to: fileURL)
        print("write \(fileName).json successful!")
    } catch {
        print(error.localizedDescription)
    }
}

func load_json(book_id: String) -> JSON{
    if let path = Bundle.main.path(forResource: book_id, ofType: "json") {
        do {
              let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
              let json = try JSON(data: data) as! JSON
              return json
          } catch {
               // handle error
          }
    }
    let json: JSON =  []
    return json
}

func savePhoto(image: UIImage, name_of_photo: String) -> UIImage?{
    do {
        let imageFileURL = getDocumentsDirectory().appendingPathComponent(name_of_photo)
        try? image.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        return image
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
    
}

func loadPhoto(name_of_photo: String) -> UIImage?{
    let imageFileURL = getDocumentsDirectory().appendingPathComponent(name_of_photo)
    do {
        let imageData = try Data(contentsOf: imageFileURL)
        return UIImage(data: imageData)
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func fetchBooks(){
    DispatchQueue.global(qos: .background).async {
    do {
        let query = LCQuery(className: "Book")
        _ = query.find { result in
            switch result {
            case .success(objects: let results):
                // Books 是包含满足条件的 (className: "Book") 对象的数组
                for item in results{
                    let identifier = item.get("identifier")?.stringValue
                    let level1_category = item.get("level1_category")?.intValue
                    let level2_category = item.get("level2_category")?.intValue
                    let name = item.get("name")?.stringValue
                    let desc = item.get("description")?.stringValue
                    let word_num = item.get("word_num")?.intValue
                    let recite_user_num = item.get("recite_user_num")?.intValue
                    
                    let book:Book = Book(identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0)
                    books.append(book)
                    resultsItems.append(item)
                }
                if global_total_books.count == 0 && books.count != 0{
                    global_total_books = books
                    global_total_items = resultsItems
                }
                break
            case .failure(error: let error):
                print(error)
            }
        }
    }
    }
}
