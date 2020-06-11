//
//  FunctionUtil.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import SwiftyJSON

// MARK: - Global Variables

var imageCache = NSCache<NSString, NSURL>()
let decoder = JSONDecoder()

var GlobalUserName = ""

// MARK: - Common Functions

func getUserName() -> String{
    let user = LCApplication.default.currentUser!
    let username = user.get("username")!.stringValue!
    return username
}


func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func getSaveRecordToClouldStatus(key: String) -> Bool{
    if isKeyPresentInUserDefaults(key: key){
        return UserDefaults.standard.bool(forKey: key)
    }
    else{
        UserDefaults.standard.set(false, forKey: key)
        return false
    }
}

func setSaveRecordToClouldStatus(key: String, status: Bool){
    UserDefaults.standard.set(status, forKey: key)
}

func saveRecordStringByGivenId(recordClass: String, saveRecordFailedKey: String, username: String, jsonString: String){
    // if ReviewRecordId exist in UserPreference
    let recordId: String = UserDefaults.standard.string(forKey: ReviewRecordIdKey)!
    
    DispatchQueue.global(qos: .background).async {
    do {
        let recordQuery = LCQuery(className: recordClass)
        let _ = recordQuery.get(recordId) { (result) in
            switch result {
            case .success(object: let rec):
                do {
                    try rec.set("username", value: username)
                    try rec.set("jsonStr", value: jsonString)
                    rec.save { (result) in
                        switch result {
                        case .success:
                            print("\(recordClass)Obj saved successfully ")
                            break
                        case .failure(error: let error):
                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                            print(error.localizedDescription)
                        }
                    }
                } catch {
                    setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                    print(error)
                }
            case .failure(error: let error):
                setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                print(error)
            }
        }}
    }
}

func saveRecordStringToCloud(recordClass: String, saveRecordFailedKey: String, recordIdKey: String, username: String, jsonString: String){
    if Reachability.isConnectedToNetwork(){
       DispatchQueue.global(qos: .background).async {
       do {
            if !isKeyPresentInUserDefaults(key: recordIdKey)
            {
                //If cannot find Id in local, maybe stored in cloud, find it in user object. Otherwise, create and save it to local and user
                let user = LCApplication.default.currentUser!
                if let reviewRecordIdFromCloud = user.get(recordIdKey)?.stringValue{
                    UserDefaults.standard.set(reviewRecordIdFromCloud, forKey: recordIdKey)
                    saveRecordStringByGivenId(recordClass: recordClass, saveRecordFailedKey: saveRecordFailedKey, username: username, jsonString: jsonString)
                }
                else{
                    let reviewRecordObj = LCObject(className: recordClass)

                    // 为属性赋值
                    try reviewRecordObj.set("username", value: username)
                    try reviewRecordObj.set("jsonStr", value: jsonString)

                    // 将对象保存到云端
                    _ = reviewRecordObj.save { result in
                        switch result {
                        case .success:
                            
                            let ReviewRecordId: String = reviewRecordObj.objectId?.stringValue! ?? ""
                            if ReviewRecordId != ""{
                                do {
                                   try user.set(recordIdKey, value: ReviewRecordId)
                                    user.save { (result) in
                                        switch result {
                                        case .success:
                                            print("\(recordClass)Obj saved successfully ")
                                            break
                                        case .failure(error: let error):
                                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                                            print(error.localizedDescription)
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                                UserDefaults.standard.set(ReviewRecordId, forKey: recordIdKey)
                            }
                            print("\(recordClass)Obj saved successfully ")
                            break
                        case .failure(error: let error):
                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                            print(error)
                        }
                    }
                }
            }
            else{
                saveRecordStringByGivenId(recordClass: recordClass, saveRecordFailedKey:saveRecordFailedKey, username: username, jsonString: jsonString)
            }
       } catch {
        setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
        print(error.localizedDescription)
       }}
    }
}


// MARK: - Card Util

var cardBackgrounds: [Int: String] = [
    1 : "light-blue",
    5 : "red",
    6 : "orange",
    4 : "green",
    7 : "blue",
    2 : "dark_blue"
]

enum CardBehavior {
    case forget
    case remember
    case trash
}

enum CardCollectBehavior {
    case no
    case yes
}

// MARK: - Controller Util
var npw_key = "number_of_word_per_day"

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

func presentAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
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

func getWordPronounceURL(word: String) -> URL?{
    let usphone = getUSPhone() == true ? 0 : 1
    if word != ""{
        let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(word)"
        let mp3_url:URL = URL(string: url_string)!
        return mp3_url
    }
    return nil
}

// MARK: - Book Util

func setCurrentBookId(bookId: String){
    let current_bookKey = "current_book"
    current_book_id = bookId
    UserDefaults.standard.setValue(bookId, forKey: current_bookKey)
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

func fetchBooks(){
    if Reachability.isConnectedToNetwork(){
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
    
}


// MARK: - Photo Util

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


// MARK: - Words Util
var words:[JSON] = []
let wordsJsonFp = "words.json"

func get_words(){
    do {
        let wordJsonURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(wordsJsonFp)
        if words.count == 0{
            let word_list = currentbook_json_obj["data"]
            if !FileManager.default.fileExists(atPath: wordJsonURL.path) {
                update_words()
            }
            let sampled_ids:[Int] = loadIntArrayFromFile(filename: wordsJsonFp)
            
            for i in 0..<sampled_ids.count{
                words.append(word_list[sampled_ids[i]])
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}


func update_words(){
    let vocabRanks:[Int] = learntVocabRanks()
    let number_of_word_per_day = get_number_of_word_per_day()
    let word_list = currentbook_json_obj["data"]
    let word_ids = word_list.count == 0 ? [] : Array(0...word_list.count)
    
    let diff_ids:[Int] = word_ids.difference(from: vocabRanks)
    let sampling_number:Int = min(number_of_word_per_day, diff_ids.count)
    
    let sampled_ids = diff_ids.choose(sampling_number)
    words = []
    for i in 0..<sampled_ids.count{
        words.append(word_list[sampled_ids[i]])
    }
    saveStringTo(fileName: wordsJsonFp, jsonStr: sampled_ids.map { String($0) }.joined(separator: ","))
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
    let phoneType = (usphone == true)  ? "usphone" : "ukphone"
    let phone = content[phoneType]?.stringValue ?? ""
    let accent = (usphone == true)  ? "美" : "英"
    var memMethod = ""
    if let memDict = content["remMethod"] {
        memMethod = memDict["val"].stringValue
    }
    
    let cardWord = CardWord(wordRank: wordRank, headWord: headWord, meaning: meaning, phone: phone, accent: accent, memMethod: memMethod)
    return cardWord
}

// MARK: - Date Util

func initDateByString(dateString: String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    guard let dateTime = formatter.date(from: dateString) else { return formatter.date(from: "3030/01/01 00:00")! }
    return dateTime
}

func timeString(time: Int) -> String {
    let hour = time / 3600
    let minute = time / 60 % 60
    let second = time % 60

    // return formated string
    return String(format: "%02i:%02i:%02i", hour, minute, second)
}

enum DurationType{
    case second
    case minute
    case hour
    case day
    case month
    case year
}

// MARK: - File Util

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
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

func loadIntArrayFromFile(filename: String) -> [Int] {
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(filename)")

       let intStr = try String(contentsOf: fileURL, encoding: .utf8)
        if intStr == ""{
            return []
        }
        else{
            let stringArr: [String] = intStr.components(separatedBy: ",")
            return stringArr.map { Int($0)!}
        }
        
    } catch {
        print(error.localizedDescription)
    }
    return []
}

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

// MARK: - Network Util

var non_network_preseted = false

func presentNoNetworkAlert() -> UIAlertController{
    return presentAlert(title: "没有网络", message: "没有网络,请检查网络连接", okText: "好的")
}

// MARK: - JSON Util

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
