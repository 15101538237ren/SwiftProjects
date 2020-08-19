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
let minToChangingWallpaper:CGFloat = 5
var imageCache = NSCache<NSString, NSURL>()
let decoder = JSONDecoder()
var GlobalUserName = ""
var everyDayLearningReminderNotificationIdentifier = "dailyLearningReminder"

let numberOfContDaysForMasteredAWord = 5 

typealias CompletionHandler = (_ success:Bool) -> Void
typealias CompletionHandlerWithData = (_ data: Data?, _ fromCloud: Bool) -> Void


// MARK: - Common Functions

func sm2(x:[Int], a: Float = 6.0, b: Float = -0.8, c: Float = 0.28, d: Float = 0.02, theta: Float = 0.2) -> Float{
    //Sumper Algorithm: See at : doctorpangloss/repetition_algorithm.ipynb
    let valid: Bool = false
    var correct_x:[Bool] = []
    var sum_term: Float = 0.0
    for xi in x{
        if xi < 0 || xi > 5{
            break
        }
        correct_x.append(xi >= 3)
        let xi_f = Float(xi)
        sum_term += b + c * xi_f + d * xi_f * xi_f
    }
    let last_remember: Bool? = correct_x.last
    if !valid || (last_remember != nil && !last_remember!){
        //If you got the last question incorrect, just return 1 day interavl for next review
        return 1.0
    }
    else{
        //Calculate the latest consecutive answer streak
        var num_consecutively_correct:Int = 0
        for correct in correct_x.reversed(){
            if correct {
                num_consecutively_correct += 1
            }
            else{
                break
            }
        }
        let power:Float = theta * Float(num_consecutively_correct)
        let next_review_day_interval:Float = powf(a * (max(1.3, 2.5 + sum_term)), power)
        return next_review_day_interval
    }
}

func calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: [Int]) -> Int{
    var secondDuration:Int = 0
    if cardBehaviorHistory.count <= 2{
        secondDuration = convertFloatDayDurationToSecond(dayDuration: 0.5)
    }
    else{
        secondDuration = convertFloatDayDurationToSecond(dayDuration: sm2(x: cardBehaviorHistory))
    }
    return secondDuration
}

func convertFloatDayDurationToSecond(dayDuration: Float)-> Int{
    return Int(dayDuration * 24.0 * 60.0 * 60.0)
}


func get_vocab_rec_need_to_be_review() -> [VocabularyRecord]{
    var vocab_rec_need_to_be_review:[VocabularyRecord] = []
    
    if GlobalVocabRecords.count == 0{
        loadVocabRecords()
    }
    let current_book_id:String = getPreference(key: "current_book_id") as! String
    let current_time = Date()
    if GlobalVocabRecords.count > 0{
        for vocabRecord in GlobalVocabRecords{
            if (vocabRecord.BookId == current_book_id) && (!vocabRecord.Mastered) && (vocabRecord.ReviewDUEDate! < current_time){
                vocab_rec_need_to_be_review.append(vocabRecord)
            }
        }
    }
    return vocab_rec_need_to_be_review
}

func build_word_head_to_json_dict() ->[String : JSON]{
    var word_head_to_json_dict: [String : JSON] = [:]
    let chapters = currentbook_json_obj["chapters"].arrayValue
    for chpt_idx in 0..<chapters.count{
        let chapter = chapters[chpt_idx]
        let word_heads = chapter["word_heads"].arrayValue.map {$0.stringValue}
        for wid in 0..<word_heads.count{
            let word = word_heads[wid]
            let word_data = chapters[chpt_idx]["data"].arrayValue[wid]
            word_head_to_json_dict[word] = word_data
        }
    }
    return word_head_to_json_dict
}

func get_words_need_to_be_review(vocab_rec_need_to_be_review: [VocabularyRecord]) -> [JSON]{
    var review_words:[JSON] = []
    let word_head_to_json_dict: [String : JSON] = build_word_head_to_json_dict()
    for vocab in vocab_rec_need_to_be_review{
        review_words.append(word_head_to_json_dict[vocab.VocabHead]!)
    }
    return review_words
}

func obtainNextReviewDate() -> Date?{
    if GlobalVocabRecords.count == 0{
        loadVocabRecords()
    }
    if GlobalVocabRecords.count > 0{
        var vocabsNeedReview:[VocabularyRecord] = []
        for vocabRecord in GlobalVocabRecords{
            if !vocabRecord.Mastered{
                vocabsNeedReview.append(vocabRecord)
            }
        }
        if vocabsNeedReview.count > 0{
            let vocabsNeedReviewSorted:[VocabularyRecord] = vocabsNeedReview.sorted(by: {$0.ReviewDUEDate!.compare($1.ReviewDUEDate!) == .orderedAscending})
            
            let number_of_vocabs_per_group = getPreference(key: "number_of_words_per_group") as! Int
            let number_of_vocabs_to_notify = min(number_of_vocabs_per_group, vocabsNeedReviewSorted.count)
            let notification_date: Date = vocabsNeedReviewSorted[number_of_vocabs_to_notify - 1].ReviewDUEDate!
            return notification_date
        }
    }
    return nil
}

func add_notification_date(notification_date: Date) -> UNNotificationRequest?{
    let notification_trigger = obtainCalendarNotificationTriggerByDate(notification_date: notification_date)
    let notification_content = obtainNotificationContent()
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification_content, trigger: notification_trigger)
    return request
}

func obtainNotificationContent() -> UNMutableNotificationContent{
    let content = UNMutableNotificationContent()
    content.body = "小刷提醒您，根据记忆规律，现在复习单词记忆效果翻倍哦！"
    content.categoryIdentifier = "reviewReminder"
    content.sound = UNNotificationSound.default
    return content
}

func obtainCalendarNotificationTriggerByDate(notification_date: Date) -> UNCalendarNotificationTrigger{
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.year = calendar.component(.year, from: notification_date)
    dateComponents.month = calendar.component(.month, from: notification_date)
    dateComponents.day = calendar.component(.day, from: notification_date)
    dateComponents.hour = calendar.component(.hour, from: notification_date)
    dateComponents.minute = calendar.component(.minute, from: notification_date)
    dateComponents.second = calendar.component(.second, from: notification_date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    return trigger
}

func getUserName() -> String{
    if let user = LCApplication.default.currentUser {
        if let usernameObj = user.get("username") {
            if let usernameStr = usernameObj.stringValue {
                return usernameStr
            }
        }
    }
    return ""
}

func getPhoneNumber() -> String?{
    if let user = LCApplication.default.currentUser {
        if let phoneLCObj = user.get("mobilePhoneNumber") {
            return phoneLCObj.stringValue
        }else{
            return nil
        }
    } else{
        return nil
    }
}

func getEmail() -> String?{
    if let user = LCApplication.default.currentUser {
        if let emailLCObj = user.get("email") {
            return emailLCObj.stringValue
        }else{
            return nil
        }
    } else{
        return nil
    }
}



func fileExist(fileFp: String) -> Bool {
    do {
        let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(fileFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return true
        }
        else
        {
            return false
        }
    }
    catch {
        print(error.localizedDescription)
        return false
    }
}

func load_data_from_file(fileFp: String, recordClass: String, IdKey: String, completionHandlerWithData: @escaping CompletionHandlerWithData) {
    var data:Data? = nil
    do {
        let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(fileFp)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                data = try Data(contentsOf: fileURL)
                completionHandlerWithData(data, false)
            }
            else{
                let connected = Reachability.isConnectedToNetwork()
                if connected{
                    if let user = LCApplication.default.currentUser{
                        if let recId = user.get(IdKey)?.stringValue{
                            do {
                                if recId != ""{
                                    print("\(recordClass), id:\(recId)")
                                    let recordQuery = LCQuery(className: recordClass)
                                    let _ = recordQuery.get(recId) { (result) in
                                        switch result {
                                        case .success(object: let rec):
                                            let recStr:String = rec.get("jsonStr")!.stringValue!
                                            saveStringTo(fileName: fileFp, jsonStr: recStr)
                                            data = recStr.data(using: .utf8)
                                            completionHandlerWithData(data, true)
                                        case .failure(error: let error):
                                            completionHandlerWithData(data, false)
                                            print(error.localizedDescription)
                                        }
                                    }
                                }else{
                                    completionHandlerWithData(data, false)
                                }
                                
                            }
                        } else {
                            completionHandlerWithData(data, false)
                        }
                    } else{
                        completionHandlerWithData(data, false)
                    }
                    
                }
                else{
                    completionHandlerWithData(data, false)
                }
        }
    }
    catch {
        completionHandlerWithData(data, false)
        print(error.localizedDescription)
    }
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

func saveRecordStringByGivenId(recordClass: String, saveRecordFailedKey: String, recordIdKey: String, username: String, jsonString: String, completionHandler: @escaping CompletionHandler){
    // if ReviewRecordId exist in UserPreference
    let connected = Reachability.isConnectedToNetwork()
    if connected{
        let recordId: String = UserDefaults.standard.string(forKey: recordIdKey)!
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
                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: true)
                            completionHandler(true)
                            break
                        case .failure(error: let error):
                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                            completionHandler(false)
                            print(error.localizedDescription)
                        }
                    }
                } catch {
                    setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                    completionHandler(false)
                    print(error.localizedDescription)
                }
            case .failure(error: let error):
                setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                completionHandler(false)
                print(error.localizedDescription)
            }
        }}
    }
    }

}

func saveRecordStringToCloud(recordClass: String, saveRecordFailedKey: String, recordIdKey: String, username: String, jsonString: String, completionHandler: @escaping CompletionHandler){
    let connected = Reachability.isConnectedToNetwork()
    if connected{
       DispatchQueue.global(qos: .background).async {
       do {
            if !isKeyPresentInUserDefaults(key: recordIdKey)
            {
                //If cannot find Id in local, maybe stored in cloud, find it in user object. Otherwise, create and save it to local and user
                let user = LCApplication.default.currentUser!
                if let recordIdFromCloud = user.get(recordIdKey)?.stringValue{
                    UserDefaults.standard.set(recordIdFromCloud, forKey: recordIdKey)
                    saveRecordStringByGivenId(recordClass: recordClass, saveRecordFailedKey: saveRecordFailedKey, recordIdKey: recordIdKey, username: username, jsonString: jsonString, completionHandler: completionHandler)
                }
                else{
                    let recordObj = LCObject(className: recordClass)

                    // 为属性赋值
                    try recordObj.set("username", value: username)
                    try recordObj.set("jsonStr", value: jsonString)

                    // 将对象保存到云端
                    _ = recordObj.save { result in
                        switch result {
                        case .success:
                            
                            let recordId: String = recordObj.objectId?.stringValue! ?? ""
                            if recordId != ""{
                                do {
                                   try user.set(recordIdKey, value: recordId)
                                    user.save { (result) in
                                        switch result {
                                        case .success:
                                            print("\(recordClass)Obj saved successfully ")
                                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: true)
                                            completionHandler(true)
                                            break
                                        case .failure(error: let error):
                                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                                            completionHandler(false)
                                            print(error.localizedDescription)
                                        }
                                    }
                                } catch {
                                    setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                                    completionHandler(false)
                                    print(error.localizedDescription)
                                }
                                UserDefaults.standard.set(recordId, forKey: recordIdKey)
                            }
                            break
                        case .failure(error: let error):
                            setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
                            completionHandler(false)
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            else{
                saveRecordStringByGivenId(recordClass: recordClass, saveRecordFailedKey:saveRecordFailedKey, recordIdKey: recordIdKey, username: username, jsonString: jsonString, completionHandler: completionHandler)
            }
       } catch {
        setSaveRecordToClouldStatus(key: saveRecordFailedKey, status: false)
        completionHandler(false)
        print(error.localizedDescription)
       }}
    }
}


// MARK: - Card Util
enum CardBehavior : Int {
    case forget = 1
    case remember = 3
    case trash = 0
}

enum CardCollectBehavior {
    case no
    case yes
}

// MARK: - Controller Util

func presentAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
}

func getUSPhone() -> Bool{
    return getPreference(key: "us_pronunciation") as! Bool
}

func setUSPhone(usphone: Bool){
    setPreference(key: "us_pronunciation", value: usphone)
}

func getWordPronounceURL(word: String, fromMainScreen: Bool = false) -> URL?{
    let usphone = fromMainScreen ? 0 : (getUSPhone() == true ? 0 : 1)
    if word != ""{
        let replaced_word = word.replacingOccurrences(of: " ", with: "+")
        let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(replaced_word)"
        let mp3_url:URL = URL(string: url_string)!
        return mp3_url
    }
    return nil
}

// MARK: - Book Util

func fetchBooks(){
    let connected = Reachability.isConnectedToNetwork()
    if connected{
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Book")
            query.limit = 1000
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
                        let file_sz = item.get("file_sz")?.floatValue
                        let nchpt = item.get("nchpt")?.intValue
                        let avg_nwchpt = item.get("avg_nwchpt")?.intValue
                        let nwchpt = item.get("nwchpt")?.stringValue
                        
                        let book:Book = Book(identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0, file_sz: file_sz ?? 0.0, nchpt: nchpt ?? 0, avg_nwchpt: avg_nwchpt ?? 0, nwchpt: nwchpt ?? "")
                        books.append(book)
                        resultsItems.append(item)
                    }
                    if global_total_books.count == 0 && books.count != 0{
                        global_total_books = books
                        global_total_items = resultsItems
                    }
                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
        }
    }
    
}


// MARK: - Photo Util

func savePhoto(image: UIImage, name_of_photo: String) -> UIImage?{
    let imageFileURL = getDocumentsDirectory().appendingPathComponent(name_of_photo)
    try? image.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
    return image
}

func deletePhoto(name_of_photo: String){
    let imageFileURL = getDocumentsDirectory().appendingPathComponent(name_of_photo)
    
    if FileManager.default.fileExists(atPath: imageFileURL.path) {
        do {
            try FileManager.default.removeItem(at: imageFileURL)
            print("\(name_of_photo) deleted")
        } catch {
            print("Error deleting Image : \(error)")
        }
    }
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
    if fileExist(fileFp: wordsJsonFp)
    {
        do {
            let wordJsonURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(wordsJsonFp)
            if words.count == 0{
                if let bookId = getPreference(key: "current_book_id") as? String {
                    if currentbook_json_obj.count == 0{
                        currentbook_json_obj = load_json(fileName: bookId)
                    }
                    
                    if !FileManager.default.fileExists(atPath: wordJsonURL.path) {
                        update_words()
                    }
                    loadVocabRecords()
                    let learnt_vocabRecs:[VocabularyRecord] = GlobalVocabRecords
                    let learnt_word_heads: Set = Set<String>(learnt_vocabRecs.map{ $0.VocabHead })
                    
                    let chapters = currentbook_json_obj["chapters"].arrayValue
                    var words_left:[String] = []
                    var word_left_chpt_inds: [Int] = []
                    var word_left_indexs_in_chpt: [Int] = []
                    
                    for chpt_idx in 0..<chapters.count{
                        let chapter = chapters[chpt_idx]
                        let word_heads = chapter["word_heads"].arrayValue.map {$0.stringValue}
                        for wid in 0..<word_heads.count{
                            let word = word_heads[wid]
                            if !(learnt_word_heads.contains(word)){
                                words_left.append(word)
                                word_left_chpt_inds.append(chpt_idx)
                                word_left_indexs_in_chpt.append(wid)
                            }
                        }
                    }
                    
                    let number_of_words_per_group = getPreference(key: "number_of_words_per_group") as! Int
                    let sampling_number:Int = min(number_of_words_per_group, words_left.count)
                    
                    let selectedIndexs:[Int] = loadIntArrayFromFile(filename: wordsJsonFp)
                    
                    for ind in 0..<selectedIndexs.count{
                       let selectedInd = selectedIndexs[ind]
                       let word_head: String = words_left[selectedInd]
                       let word_chp_ind: Int = word_left_chpt_inds[selectedInd]
                       let word_in_chp_ind: Int = word_left_indexs_in_chpt[selectedInd]
                       let word_data = chapters[word_chp_ind]["data"].arrayValue[word_in_chp_ind]
                        words.append(word_data)
                    }
                }
                
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

func clear_words(){
    words = [] // clear current words array
    saveStringTo(fileName: wordsJsonFp, jsonStr: "")
}

func update_words(){
    if let bookId = getPreference(key: "current_book_id") as? String {
        loadVocabRecords()
        let learnt_vocabRecs:[VocabularyRecord] = GlobalVocabRecords
        let learnt_word_heads: Set = Set<String>(learnt_vocabRecs.map{ $0.VocabHead })
        
        let chapters = currentbook_json_obj["chapters"].arrayValue
        var words_left:[String] = []
        var word_left_chpt_inds: [Int] = []
        var word_left_indexs_in_chpt: [Int] = []
        
        for chpt_idx in 0..<chapters.count{
            let chapter = chapters[chpt_idx]
            let word_heads = chapter["word_heads"].arrayValue.map {$0.stringValue}
            for wid in 0..<word_heads.count{
                let word = word_heads[wid]
                if !(learnt_word_heads.contains(word)){
                    words_left.append(word)
                    word_left_chpt_inds.append(chpt_idx)
                    word_left_indexs_in_chpt.append(wid)
                }
            }
        }
        
        let memOrder = getPreference(key: "memOrder") as! Int
        let number_of_words_per_group = getPreference(key: "number_of_words_per_group") as! Int
        let sampling_number:Int = min(number_of_words_per_group, words_left.count)
        
        words = []
        var selectedIndexs:[Int] = []
        if memOrder == 1{//Random
            //Int(arc4random_uniform(UInt32(diff_ids.count - 1)))
           for _ in 0..<sampling_number{
                var randomIndex = Int.random(in: 0...(words_left.count - 1))
                while selectedIndexs.contains(randomIndex){
                    randomIndex = Int.random(in: 0...(words_left.count - 1))
                }
                selectedIndexs.append(randomIndex)
           }
        }else if memOrder == 2{ //Alphabet
            for ind in 0..<sampling_number{
               selectedIndexs.append(ind)
            }
        } else{ //Reversed Alphabet
            for ind in 0..<sampling_number{
               selectedIndexs.append(words_left.count - 1 - ind)
            }
        }
        for ind in 0..<sampling_number{
           let selectedInd = selectedIndexs[ind]
           let word_head: String = words_left[selectedInd]
           let word_chp_ind: Int = word_left_chpt_inds[selectedInd]
           let word_in_chp_ind: Int = word_left_indexs_in_chpt[selectedInd]
           let word_data = chapters[word_chp_ind]["data"].arrayValue[word_in_chp_ind]
           words.append(word_data)
        }
        saveStringTo(fileName: wordsJsonFp, jsonStr: selectedIndexs.map { String($0) }.joined(separator: ","))
    }
}

func getFeildsOfWord(word: JSON, usphone: Bool) -> CardWord{
    let word_data = word.arrayValue
    let headWord: String = word_data[0].stringValue
    let content = word_data[1].dictionaryValue
    var meaning = ""
    if let trans = content["translations"]?.arrayValue
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
    let phoneType = (usphone == true)  ? "us_phone" : "uk_phone"
    let phone = content[phoneType]?.stringValue ?? ""
    let accent = (usphone == true)  ? "美" : "英"
    var memMethod = ""
    if let memDict = content["remMethod"]{
        memMethod = memDict.stringValue
    }
    
    let cardWord = CardWord(headWord: headWord, meaning: meaning, phone: phone, accent: accent, memMethod: memMethod)
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
    if hour == 0{
        return String(format: "%02i:%02i", minute, second)
    }else{
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
}

func printDate(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm E, d MMM y"
    let dateString = dateFormatter.string(from: date)
    print(dateString)
    return dateString
}

enum DurationType{
    case second
    case minute
    case hour
    case day
    case month
    case year
}

func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

    //get both times sinces refrenced date and divide by 60 to get minutes
    let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
    let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

    //then return the difference
    return CGFloat(newDateMinutes - oldDateMinutes)
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
