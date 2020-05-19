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

var npw_key = "number_of_word_per_day"
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

func load_json(fileName: String) -> JSON{
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(fileName).json")

       let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
       let json = try JSON(data: data) as! JSON
       return json
    } catch {
        print(error.localizedDescription)
    }
    let json: JSON = []
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


func uploadRecordsIfNeeded(){
    let uploadFailedKey = "uploadFailed"
    if let user = LCApplication.default.currentUser {
        if let username = user.get("username"){
            
            if isKeyPresentInUserDefaults(key: uploadFailedKey){
                let uploadfailed:Bool = UserDefaults.standard.bool(forKey: uploadFailedKey)
                if uploadfailed == true{
                    let collectedRecords = loadCollectedRecords()
                    saveCollectedRecordsToCloud(collectedRecords: collectedRecords, username: username.stringValue!)
                    let reviewRecords = loadReviewRecords()
                    saveReviewRecordsToClould(reviewRecord: reviewRecords, username: username.stringValue!)
                    let vocabRecords = loadVocabRecords()
                    saveVocabRecordsToClould(vocabRecords: vocabRecords, username: username.stringValue!)
                    let learningRecords = loadLearningRecords()
                    saveLearningRecordsToClould(learningRecord: learningRecords, username: username.stringValue!)
                }
            }
        }
    }
    else{
        UserDefaults.standard.set(true, forKey: uploadFailedKey)
        uploadRecordsIfNeeded()
    }
    
}


func getCurrentBookId() -> String{
    let current_bookKey = "current_book"
    if isKeyPresentInUserDefaults(key: current_bookKey){
        let book_id:String = UserDefaults.standard.string(forKey: current_bookKey) ?? current_book_id
        return book_id
    }
    else{
        return current_book_id
    }
}

func learntVocabRanks() -> [Int]{
    var vocabRanks:[Int] = []
    let book_id:String = getCurrentBookId()
    let vocabRecords: [VocabularyRecord] = loadVocabRecords()
    for vocabRec in vocabRecords{
        if vocabRec.BookId == book_id{
            vocabRanks.append(vocabRec.WordRank)
        }
    }
    return vocabRanks
}

func timeString(time: Int) -> String {
    let hour = time / 3600
    let minute = time / 60 % 60
    let second = time % 60

    // return formated string
    return String(format: "%02i:%02i:%02i", hour, minute, second)
}

func getUSPhone() -> Bool{
    let usphoneKey = "usphone"
    if isKeyPresentInUserDefaults(key: usphoneKey){
        let usphone:Bool = UserDefaults.standard.bool(forKey: usphoneKey)
        return usphone
    }
    else{
        let usphone:Bool = true
        UserDefaults.standard.set(usphone, forKey: usphoneKey)
        return usphone
    }
}

func setUSPhone(usphone: Bool){
    let usphoneKey = "usphone"
    UserDefaults.standard.set(usphone, forKey: usphoneKey)
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

func saveStringTo(fileName: String, jsonStr: String){
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(fileName)")

        try jsonStr.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        print("write \(fileName) successful!")
    } catch {
        print(error.localizedDescription)
    }
}

var GlobalCollectedRecords:[CollectedRecord] = []
var GlobalReviewRecords:[ReviewRecord] = []
var GlobalVocabRecords:[VocabularyRecord] = []
var GlobalLearningRecords:[LearningRecord] = []

func getDefaultFilePath(fileName: String) -> String?{
    do {
        let fileURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(fileName)
        return fileURL.path
    } catch {
        print(error.localizedDescription)
    }
    return nil
}

let collectedRecordJsonFp = "collectedRecord.json"
let reviewRecordJsonFp = "reviewRecord.json"
let vocabRecordJsonFp = "vocabRecord.json"
let learningRecordJsonFp = "learningRecord.json"

var currentbook_json_obj: JSON = load_json(fileName: "current_book")
var words:[JSON] = []

func get_number_of_word_per_day() -> Int{
    let number_of_word_per_day_exist = isKeyPresentInUserDefaults(key: npw_key)
    var number_of_word_per_day: Int = 20
    if number_of_word_per_day_exist{
        number_of_word_per_day = UserDefaults.standard.integer(forKey: npw_key)
    }
    else{
        UserDefaults.standard.set(number_of_word_per_day, forKey: npw_key)
    }
    return number_of_word_per_day
}


func getFeildsOfWord(word: JSON, usphone: Bool) -> CardWord{
    let wordRank: Int = word["wordRank"].intValue
    let headWord: String = word["headWord"].stringValue
    let content = word["content"]["word"]["content"].dictionaryValue
    var meaning = ""
    if let trans = content["trans"]?.arrayValue
    {
        var stringArr:[String] = []
        for tran in trans{
            let pos = tran["pos"].stringValue
            let current_meaning = tran["tranCn"].stringValue
            let current_meaning_replaced = current_meaning.replacingOccurrences(of: "；", with: "\n")
            stringArr.append("\(pos).\(current_meaning_replaced)")
            meaning = stringArr.joined(separator: "\n")
        }
    }
    let speech = "\(current_book_id)__\(wordRank)_0"
    let phoneType = (usphone == true)  ? "usphone" : "ukphone"
    let phone = content[phoneType]?.stringValue ?? ""
    let accent = (usphone == true)  ? "美" : "英"
    let cardWord = CardWord(wordRank: wordRank, headWord: headWord, meaning: meaning, phone: phone, speech: speech, accent: accent)
    return cardWord
}

func update_words(){
    let vocabRanks:[Int] = learntVocabRanks()
    let number_of_word_per_day = get_number_of_word_per_day()
    let word_list = currentbook_json_obj["data"]
    let word_ids = Array(0...word_list.count)
    
    let diff_ids:[Int] = word_ids.difference(from: vocabRanks)
    let sampling_number:Int = min(number_of_word_per_day, diff_ids.count)
    
    let sampled_ids = diff_ids.choose(sampling_number)
    
    saveStringTo(fileName: "words.json", jsonStr: sampled_ids.map { String($0) }.joined(separator: ","))
}

func loadIntArrayFromFile(filename: String) -> [Int] {
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(filename)")

       let intStr = try String(contentsOf: fileURL, encoding: .utf8)
        let stringArr: [String] = intStr.components(separatedBy: ",")
       return stringArr.map { Int($0)!}
    } catch {
        print(error.localizedDescription)
    }
    return []
}

func get_words(){
    do {
        let wordJsonURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("words.json")
        if words.count == 0{
            let word_list = currentbook_json_obj["data"]
            if !FileManager.default.fileExists(atPath: wordJsonURL.path) {
                update_words()
            }
            let sampled_ids:[Int] = loadIntArrayFromFile(filename: "words.json")
            
            for i in 0..<sampled_ids.count{
                words.append(word_list[sampled_ids[i]])
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

func getWordPronounceURL(word: String) -> URL?{
    let usphone = getUSPhone() == true ? 0 : 1
    if word != ""{
        let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(word)"
        let mp3_url:URL = URL(string: url_string)!
        return mp3_url
    }
    return nil
}

func syncRecords(){
    if let user = LCApplication.default.currentUser {
        if let userName = user.get("username"){
            if let collectedRecordpath = getDefaultFilePath(fileName: collectedRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: collectedRecordpath) {
                    DispatchQueue.global(qos: .background).async {
                    do {
                        let collectedQuery = LCQuery(className: "CollectedRecord")
                        collectedQuery.whereKey("username", .equalTo(userName))
                        _ = collectedQuery.find { result in
                                    switch result {
                                    case .success(objects: let collectedRecords):
                                        if collectedRecords.count > 0
                                        {
                                            if let jsonStr = collectedRecords[0].get("jsonStr")?.stringValue{
                                                saveStringTo(fileName: collectedRecordJsonFp, jsonStr: jsonStr)
                                                GlobalCollectedRecords = loadCollectedRecords()
                                            }
                                        }
                                        
                                        break
                                    case .failure(error: let error):
                                        print(error)
                                }
                        }
                    }
                   }
                }
            }
            if let reviewRecordpath = getDefaultFilePath(fileName: reviewRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: reviewRecordpath) {
                DispatchQueue.global(qos: .background).async {
                do {
                    let reviewRecordQuery = LCQuery(className: "ReviewRecord")
                    reviewRecordQuery.whereKey("username", .equalTo(userName))
                    _ = reviewRecordQuery.find { result in
                                switch result {
                                case .success(objects: let reviewRecords):
                                    if reviewRecords.count > 0
                                    {
                                        if let jsonStr = reviewRecords[0].get("jsonStr")?.stringValue{
                                            saveStringTo(fileName: reviewRecordJsonFp, jsonStr: jsonStr)
                                            GlobalReviewRecords = loadReviewRecords()
                                        }
                                    }
                                    
                                    break
                                case .failure(error: let error):
                                    print(error)
                            }
                    }
                    }}
                }
            }
            if let vocabRecordPath = getDefaultFilePath(fileName: vocabRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: vocabRecordPath) {
                DispatchQueue.global(qos: .background).async {
                do {
                    let vocabRecordsQuery = LCQuery(className: "VocabRecord")
                    vocabRecordsQuery.whereKey("username", .equalTo(userName))
                    _ = vocabRecordsQuery.find { result in
                                switch result {
                                case .success(objects: let vocabRecords):
                                    if vocabRecords.count > 0
                                    {
                                        if let jsonStr = vocabRecords[0].get("jsonStr")?.stringValue{
                                            saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonStr)
                                            GlobalVocabRecords = loadVocabRecords()
                                        }
                                    }
                                    
                                    break
                                case .failure(error: let error):
                                    print(error)
                            }
                    }
                    }}
                }
            }
            if let learningRecordPath = getDefaultFilePath(fileName: learningRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: learningRecordPath) {
                DispatchQueue.global(qos: .background).async {
                do {
                    let learningRecordsQuery = LCQuery(className: "LearningRecord")
                    learningRecordsQuery.whereKey("username", .equalTo(userName))
                    _ = learningRecordsQuery.find { result in
                                switch result {
                                case .success(objects: let learningRecords):
                                    if learningRecords.count > 0
                                    {
                                        if let jsonStr = learningRecords[0].get("jsonStr")?.stringValue{
                                            saveStringTo(fileName: learningRecordJsonFp, jsonStr: jsonStr)
                                            GlobalLearningRecords = loadLearningRecords()
                                        }
                                    }
                                    
                                    break
                                case .failure(error: let error):
                                    print(error)
                            }
                    }
                    }}
                }
            }
        }
    }
}

func loadCollectedRecords() -> [CollectedRecord]{
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(collectedRecordJsonFp)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let collectedRecords = try decoder.decode([CollectedRecord].self, from: data)
            return collectedRecords
        }
    } catch {
        print(error.localizedDescription)
    }
    
    let collectedRecords: [CollectedRecord] =  []
    return collectedRecords
}
func saveCollectedRecordsLocally(){
    do {
        let jsonData = try! JSONEncoder().encode(GlobalCollectedRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        saveStringTo(fileName: collectedRecordJsonFp, jsonStr: jsonString)
    } catch {
        print(error.localizedDescription)
    }
}

func saveCollectedRecordsToCloud(collectedRecords: [CollectedRecord], username: String){
    DispatchQueue.global(qos: .background).async {
    do {
        let jsonData = try! JSONEncoder().encode(collectedRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        // 构建对象
        let collectedRecordsObj = LCObject(className: "CollectedRecord")

        // 为属性赋值
        try collectedRecordsObj.set("username", value: username)
        try collectedRecordsObj.set("jsonStr", value: jsonString)

        // 将对象保存到云端
        _ = collectedRecordsObj.save { result in
            switch result {
            case .success:
                // 成功保存之后，执行其他逻辑
                print("CollectedRecord saved successfully ")
                break
            case .failure(error: let error):
                // 异常处理
                print(error)
            }
        }
    } catch {
        print(error.localizedDescription)
        }}
}

func loadReviewRecords() -> [ReviewRecord]{
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(reviewRecordJsonFp)
       if FileManager.default.fileExists(atPath: fileURL.path) {
           let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
           let reviewRecords = try decoder.decode([ReviewRecord].self, from: data)
            return reviewRecords
        }
    } catch {
        print(error.localizedDescription)
    }
    let reviewRecords: [ReviewRecord] =  []
    return reviewRecords
}


func saveReviewRecordsLocally(){
    do {
        let jsonData = try! JSONEncoder().encode(GlobalReviewRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        saveStringTo(fileName: reviewRecordJsonFp, jsonStr: jsonString)
    } catch {
        print(error.localizedDescription)
    }
}

func saveReviewRecordsToClould(reviewRecord: [ReviewRecord], username: String){
    DispatchQueue.global(qos: .background).async {
    do {
        let jsonData = try! JSONEncoder().encode(reviewRecord)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        // 构建对象
        let reviewRecordObj = LCObject(className: "ReviewRecord")

        // 为属性赋值
        try reviewRecordObj.set("username", value: username)
        try reviewRecordObj.set("jsonStr", value: jsonString)

        // 将对象保存到云端
        _ = reviewRecordObj.save { result in
            switch result {
            case .success:
                // 成功保存之后，执行其他逻辑
                print("ReviewRecordObj saved successfully ")
                break
            case .failure(error: let error):
                // 异常处理
                print(error)
            }
        }
    } catch {
        print(error.localizedDescription)
        }}
}

let decoder = JSONDecoder()

func loadVocabRecords() -> [VocabularyRecord] {
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(vocabRecordJsonFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
           let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
           let vocabRecords = try decoder.decode([VocabularyRecord].self, from: data)
            return vocabRecords
        }
    } catch {
        print(error.localizedDescription)
    }
    let vocabRecords: [VocabularyRecord] =  []
    return vocabRecords
}

func saveVocabRecordsLocally(){
    do {
        let jsonData = try! JSONEncoder().encode(GlobalVocabRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonString)
    } catch {
        print(error.localizedDescription)
    }
}

func saveVocabRecordsToClould(vocabRecords: [VocabularyRecord], username: String){
    DispatchQueue.global(qos: .background).async {
    do {
        let jsonData = try! JSONEncoder().encode(vocabRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        // 构建对象
        let vocabRecordObj = LCObject(className: "VocabRecord")

        // 为属性赋值
        try vocabRecordObj.set("username", value: username)
        try vocabRecordObj.set("jsonStr", value: jsonString)

        // 将对象保存到云端
        _ = vocabRecordObj.save { result in
            switch result {
            case .success:
                // 成功保存之后，执行其他逻辑
                print("VocabRecord saved successfully ")
                break
            case .failure(error: let error):
                // 异常处理
                print(error)
            }
        }
    } catch {
        print(error.localizedDescription)
        }}
}


func loadLearningRecords() -> [LearningRecord]{
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(learningRecordJsonFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
           let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
           let learningRecord = try decoder.decode([LearningRecord].self, from: data)
            return learningRecord
        }
    } catch {
        print(error.localizedDescription)
    }
    let learningRecord: [LearningRecord] =  []
    return learningRecord
}

func saveLearningRecordsLocally(){
    do {
        let jsonData = try! JSONEncoder().encode(GlobalLearningRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        saveStringTo(fileName: learningRecordJsonFp, jsonStr: jsonString)
    } catch {
        print(error.localizedDescription)
    }
}

func saveLearningRecordsToClould(learningRecord: [LearningRecord], username: String){
    DispatchQueue.global(qos: .background).async {
    do {
        let jsonData = try! JSONEncoder().encode(learningRecord)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        // 构建对象
        let learningRecordObj = LCObject(className: "LearningRecord")

        // 为属性赋值
        try learningRecordObj.set("username", value: username)
        try learningRecordObj.set("jsonStr", value: jsonString)

        // 将对象保存到云端
        _ = learningRecordObj.save { result in
            switch result {
            case .success:
                // 成功保存之后，执行其他逻辑
                print("LearningRecord saved successfully ")
                break
            case .failure(error: let error):
                // 异常处理
                print(error)
            }
        }
    } catch {
        print(error.localizedDescription)
        }}
}
