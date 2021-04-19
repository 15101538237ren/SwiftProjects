//
//  GlobalFunctions.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/2.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation
import Disk
import LeanCloud
import SwiftyJSON
import Accelerate
import SwiftTheme
import SwiftyStoreKit

func load_DICT(){
    do {
        let data = try Data(contentsOf: DICT_URL, options: [])//.mappedIfSafe
        let AllData:[String:JSON] = try JSON(data: data)["data"].dictionary!
        let key_arr = try JSON(data: data)["keys"].arrayValue
        let oalecd8_arr = try JSON(data: data)["oalecd8"].arrayValue
        for kid in 0..<key_arr.count{
            let key = key_arr[kid].stringValue
            Word_indexs_In_Oalecd8[key] = [kid, oalecd8_arr[kid].intValue]
            AllData_keys.append(key)
            AllInterp_keys.append(AllData[key]!.stringValue)
        }
       print("Load \(DICT_URL) successful!")
    } catch {
        print(error.localizedDescription)
    }
}

func setInvitationCodeUsed(invitationCode: String, user: LCUser){
    let query = LCQuery(className: "Invitation")
    query.whereKey("Code", .equalTo(invitationCode))
    _ = query.getFirst { result in
        switch result {
        case .success(object: let invitation):
            
            do {
                try invitation.set("Used", value: true)
                try invitation.set("Usedby", value: user)
                _ = invitation.save { result in
                    switch result {
                    case .success:
                        print("updated invitation code status successful!")
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error)
            }
        case .failure(error: let error):
            print(error)
        }
    }
}

func loadSwitchesSetting(){
    DispatchQueue.global(qos: .background).async {
    do {
        let query = LCQuery(className: "Switch")
        query.limit = 100
        _ = query.find { result in
            switch result {
            case .success(objects: let results):
                for item in results{
                    let name = item.get("name")!.stringValue!
                    let switchOn = item.get("on")!.boolValue!
                    if switchOn{
                        switch name {
                        case "invitation":
                            invitationMode = true
                        case "loadLearning":
                            loadLearning = true
                        case "loadLearnFinish":
                            loadLearnFinish = true
                        case "loadPurchaseVIP":
                            loadPurchaseVIP = true
                        default:
                            break
                        }
                    }
                }
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    }
}

func setOnlineStatus(user: LCUser, status: OnlineStatus){
    do {
        try user.set("online", value: status.rawValue)
        _ = user.save { result in
            switch result {
            case .success:
                print("updated online status successful!")
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    } catch {
        print(error)
    }
}

func loadURL(url: URL){
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

func initIndicator(view: UIView){
    hud.textLabel.text = loadingText
    hud.textLabel.theme_textColor = "IndicatorColor"
    hud.backgroundColor = .clear
    hud.show(in: view)
}

func stopIndicator(){
    hud.dismiss()
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func getThemeColor(key: String) -> String{
    let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: key) as! String
    return viewBackgroundColor
}

// MARK: - VIP Util

func checkIfVIPSubsciptionValid(successCompletion: @escaping Completion, failedCompletion: @escaping Completion){
    successCompletion()
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy/MM/dd HH:mm"
//    let DUETIME = formatter.date(from: "2021/06/01 00:00")!
//    let vip = VIP(purchase: .MonthlySubscribed)
//    let product = vip.purchase
//    let productID = makeProductId(purchase: product)
//    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//        switch result {
//        case .success(let receipt):
//            // Verify the purchase of a Subscription
//            let purchaseResult = SwiftyStoreKit.verifySubscription(
//                ofType: .autoRenewable,
//                productId: productID,
//                inReceipt: receipt)
//                
//            switch purchaseResult {
//            case .purchased(let expiryDate, let items):
//                print("\(productID) is valid until \(expiryDate)\n\(items)\n")
//                successCompletion()
//            case .expired(let expiryDate, let items):
//                print("\(productID) is expired since \(expiryDate)\n\(items)\n")
//                failedCompletion()
//            case .notPurchased:
//                print("The user has never purchased \(productID)")
//                failedCompletion()
//            }
//
//        case .error(let error):
//            print("Receipt verification failed: \(error)")
//            failedCompletion()
//        }
//    }
    
}

func makeProductId(purchase: RegisteredPurchase)-> String{
    return "\(bundleId).\(purchase.rawValue)"
}

func getTimeInterval(product: RegisteredPurchase) -> TimeInterval{
    switch product {
    case .MonthlySubscribed:
        return 3600 * 24 * 30
    }
}

// MARK: - Preference Util

/**
 
 Load Preference from disk to memory, if not exist, initallize.

 - Parameter userId: The objectId of user on LeanCloud

 - Returns: A loaded or initiallized Preference object.
 
 */

func loadPreference(userId: String) -> Preference{
    
    let preference_fp:String = "\(userId)_pref.json"
    
    if !Disk.exists(preference_fp, in: .documents)
    {
        let preference: Preference = Preference()
        
        do {
            try Disk.save(preference, to: .documents, as: preference_fp)
            print("Init and Saved Preference Successful!")
        } catch {
            print("Save Preference Failed, \(error.localizedDescription)!")
        }
        return preference
    }
    else
    {
        do {
            let preference:Preference = try Disk.retrieve(preference_fp, from: .documents, as: Preference.self)
            print("Loaded Preference Successful!")
            return preference
        } catch {
            print("Loaded Preference Failed, \(error.localizedDescription)!")
            return Preference()
        }
    }
}


/**
 
 Save preference object to disk

 - Parameter userId: The objectId of user on LeanCloud

 - Parameter preference: The preference object to save

 - Returns: none
 
 */

func savePreference(userId: String, preference: Preference){
    let preference_fp:String = "\(userId)_pref.json"
    do {
        try Disk.save(preference, to: .documents, as: preference_fp)
        print("Saved Preference Successful!")
    } catch {
        print(error)
    }
}

// MARK: - Records Util
/**
 
 Save record objects to disk

 - Parameter userId: The objectId of user on LeanCloud

 - Parameter records: The record objects to save

 - Returns: none
 
 */

func saveRecordsToDisk(userId: String, withRecords:Bool = true){
    let vocab_records_fp:String = "\(userId)_vocab_records.json"
    let records_fp:String = "\(userId)_records.json"
    do {
        try Disk.save(global_vocabs_records, to: .documents, as: vocab_records_fp)
        print("Saved VocabRecords to Disk Successful!")
        if withRecords{
            try Disk.save(global_records, to: .documents, as: records_fp)
            print("Saved Records to Disk Successful!")
        }
    } catch {
        print(error)
    }
}

/**
 
 Load records from disk to memory, if not exist, try load from LeanCloud.

 - Parameter userId: The objectId of user on LeanCloud

 - Returns: none
 
 */

func loadRecords(currentUser: LCUser, completionHandler: @escaping CompletionHandler){
    
    let userId:String = currentUser.objectId!.stringValue!
    
    let vocab_records_fp:String = "\(userId)_vocab_records.json"
    
    if !Disk.exists(vocab_records_fp, in: .documents)
    {
        loadVocabRecordsFromCloud(currentUser: currentUser)
    }
    else
    {
        do {
            let vocab_records: [VocabularyRecord] = try Disk.retrieve(vocab_records_fp, from: .documents, as: [VocabularyRecord].self)
            global_vocabs_records = vocab_records
            print("Loaded VocabRecords from Disk Successful!")
        } catch {
            print(error)
        }
    }
    
    let records_fp:String = "\(userId)_records.json"
    
    if !Disk.exists(records_fp, in: .documents)
    {
        loadRecordsFromCloud(currentUser: currentUser, completionHandler: completionHandler)
    }
    else
    {
        do {
            let records: [Record] = try Disk.retrieve(records_fp, from: .documents, as: [Record].self)
            global_records = records
            loadRecordsFromCloud(currentUser: currentUser, completionHandler: { _ in})
            print("Loaded Records from Disk Successful!")
            completionHandler(true)
        } catch {
            print(error)
            completionHandler(false)
        }
    }
}


func saveRecordsToCloud(currentUser: LCUser){
    var lcRecords:[LCObject] = []
    let unsynced_records = global_records.filter {!$0.synced}
    
    for record in unsynced_records{
        do {
            
            let recordLC = LCObject(className: "Record")
            try recordLC.set("user", value: currentUser)
            try recordLC.set("uuid", value: record.uuid)
            try recordLC.set("recordType", value: record.recordType)
            try recordLC.set("startDate", value: record.startDate)
            try recordLC.set("endDate", value: record.endDate)
            let vocabHeadString = record.vocabHeads.joined(separator: ",")
            try recordLC.set("vocabHeads", value: vocabHeadString)
            lcRecords.append(recordLC)
        } catch {
            print(error)
        }
    }
    
    // 批量构建和更新
    _ = LCObject.save(lcRecords, completion: { (result) in
        switch result {
        case .success:
            print("Save \(unsynced_records.count) Unsynchronized Records to Cloud Successful!")
            for rid in 0..<global_records.count{
                if !global_records[rid].synced{
                    global_records[rid].synced = true
                }
            }
            saveRecordsToDisk(userId: currentUser.objectId!.stringValue!)
        case .failure(error: let error):
            print(error)
        }
    })
}

func saveVocabRecordsToCloud(currentUser: LCUser){
    if Reachability.isConnectedToNetwork(){
       let jsonData = try! JSONEncoder().encode(global_vocabs_records)
       let jsonString = String(data: jsonData, encoding: .utf8)!
       DispatchQueue.global(qos: .background).async {
        do {
            _ = currentUser.fetch { result in
                switch result {
                case .success:
                    if let recordId = currentUser.get("VocabRecordId")?.stringValue{
                        let recordQuery = LCQuery(className: "VocabRecord")
                        recordQuery.get(recordId) { (result) in
                            switch result {
                            case .success(object: let rec):
                                do {
                                    try rec.set("jsonStr", value: jsonString)
                                    rec.save { (result) in
                                        switch result {
                                        case .success:
                                            print("VocabRecord saved successfully ")
                                            break
                                        case .failure(error: let error):
                                            print(error.localizedDescription)
                                        }
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            case .failure(error: let error):
                                print(error.localizedDescription)
                            }
                        }
                    }else{
                        do{
                            let recordObj = LCObject(className: "VocabRecord")
                            try recordObj.set("jsonStr", value: jsonString)
                            
                            _ = recordObj.save { result in
                                switch result {
                                case .success:
                                    let recordId: String = recordObj.objectId!.stringValue!
                                    do {
                                        try currentUser.set("VocabRecordId", value: recordId)
                                        currentUser.save { result in
                                            switch result{
                                            case .success:
                                                print("VocabRecord saved successfully ")
                                                break
                                            case .failure(error: let error):
                                                print(error.reason ?? "failed to save VocabRecords")
                                            }
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                case .failure(error: let error):
                                    print(error.reason ?? "failed to save VocabRecords")
                                }
                            }
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                    }
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
       }
    }
}

func loadVocabRecordsFromCloud(currentUser: LCUser){
    if Reachability.isConnectedToNetwork(){
        DispatchQueue.global(qos: .background).async {
        do {
            _ = currentUser.fetch{
                result in
                    switch result {
                    case .success:
                        if let recordId = currentUser.get("VocabRecordId")?.stringValue{
                            let recordQuery = LCQuery(className: "VocabRecord")
                            recordQuery.get(recordId) { (result) in
                                switch result {
                                case .success(object: let rec):
                                    let jsonStr = rec.get("jsonStr")!.stringValue!
                                    let data = jsonStr.data(using: .utf8)!
                                    if let vocab_records = try? JSONDecoder().decode([VocabularyRecord].self, from: data)
                                    {
                                        global_vocabs_records = vocab_records
                                        saveRecordsToDisk(userId: currentUser.objectId!.stringValue!)
                                    } else {
                                        print("bad json in VocabRecord from LeanCloud")
                                    }
                                case .failure(error: let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
            }
        }
        }
    }
}


func loadRecordsFromCloud(currentUser: LCUser, completionHandler: @escaping CompletionHandler)
{
    if Reachability.isConnectedToNetwork(){
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Record")
            query.whereKey("user", .equalTo(currentUser))
            query.whereKey("createdAt", .ascending)
            query.limit = QueryLimit
            
            let record_count = query.count().intValue
            
            if record_count > QueryLimit{
                let query_times:Int = Int(ceil(Double(record_count) / Double(QueryLimit)))
                
                for ti in 0..<query_times{
                    let skip = Int(ti * QueryLimit)
                    fetchBatchRecordsFromCloud(currentUser: currentUser, skip: skip, completionHandler: completionHandler)
                }
            }else{
                fetchBatchRecordsFromCloud(currentUser: currentUser, completionHandler: completionHandler)
            }
        }
        }
    }else{
        print(NoNetworkStr)
        completionHandler(false)
    }
}


func fetchBatchRecordsFromCloud(currentUser: LCUser, skip: Int = 0, completionHandler: @escaping CompletionHandler){
    if Reachability.isConnectedToNetwork(){
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Record")
            query.whereKey("user", .equalTo(currentUser))
            query.whereKey("createdAt", .ascending)
            query.limit = QueryLimit
            query.skip = skip
            _ = query.find { result in
                switch result {
                case .success(objects: let items):
                    let records = parseLCRecords(items: items)
                    updateRecords(userId: currentUser.objectId!.stringValue!, records: records)
                    completionHandler(true)
                case .failure(error: let error):
                    print(error.localizedDescription)
                    completionHandler(true)
                }
            }
        }
        }
    }else{
        completionHandler(false)
        print(NoNetworkStr)
    }
}

func parseLCRecords(items: [LCObject]) -> [Record] {
    var records:[Record] = []
    for item in items
    {
        let uuid = item.get("uuid")!.stringValue! // THIS MAYBE PROBLEMATIC
        let recordTypeValue: Int = item.get("recordType")!.intValue!
        let startDate: Date = item.get("startDate")!.dateValue!
        let endDate: Date = item.get("endDate")!.dateValue!
        let vocabHeadString: String = item.get("vocabHeads")!.stringValue!
        let vocabHeads:[String] = vocabHeadString.components(separatedBy: ",")
        let record: Record = Record(uuid: uuid, recordType: recordTypeValue, startDate: startDate, endDate: endDate, vocabHeads: vocabHeads)
        records.append(record)
    }
    return records
}


func convertIntegersToCardBehaviorEnums(BehaviorHistory:[Int]) -> [CardBehavior]{
    var cardBehaviors:[CardBehavior] = []
    for behavior in BehaviorHistory{
        if behavior == 1{
            cardBehaviors.append(.forget)
        }else if behavior == 0{
            cardBehaviors.append(.trash)
        }else{
            cardBehaviors.append(.remember)
        }
    }
    return cardBehaviors
}

func updateRecords(userId:String, records: [Record]){
    var changed:Bool = false
    let uuids:[String] = global_records.map { $0.uuid }
    for record in records{
        if !uuids.contains(record.uuid){
            var record_synced = record
            record_synced.synced = true
            global_records.append(record_synced)
            changed = true
        }
    }
    if changed{
        saveRecordsToDisk(userId: userId)
    }
}

func getRecordsOfDate(date: Date) -> [Record]{
    var filtered_records:[Record] = []
    for rec in global_records{
        if Calendar.current.isDate(rec.endDate, inSameDayAs: date){
            filtered_records.append(rec)
        }
    }
    return filtered_records
}


// MARK: - Card Util
enum CardBehavior : Int {
    case forget = 1
    case trash = 0
    case remember = 3
}

enum WordMemStage : Int {
    case memory = 1
    case enToCn = 2
    case cnToEn = 3
}

enum CardCollectBehavior {
    case no
    case yes
}

enum DateType {
    case learn
    case master
    case collect
}

enum VocabDatePeriod {
    case Unlimited
    case OneDay
    case ThreeDays
    case OneWeek
}

enum MemConstraint {
    case Unlimited
    case Overdue
    case Withindue
}

// MARK: - Book Util

func fetchBooks(){
    if Reachability.isConnectedToNetwork(){
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Book")
            query.limit = 1000
            _ = query.find { result in
                switch result {
                case .success(objects: let results):
                    books = []
                    resultsItems = []
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
                        
                        let book:Book = Book(objectId: item.objectId!.stringValue!, identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0, file_sz: file_sz ?? 0.0, nchpt: nchpt ?? 0, avg_nwchpt: avg_nwchpt ?? 0, nwchpt: nwchpt ?? "")
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

func updateGlobalVocabRecords(vocabs_updated: [VocabularyRecord]){
    var vocab_new_heads:[String] = []
    for vocab in vocabs_updated{
        vocab_new_heads.append(vocab.VocabHead)
    }
    var temp_GlobalVocabRec:[VocabularyRecord] = []
    for vi in 0..<global_vocabs_records.count{
        let vocab:VocabularyRecord = global_vocabs_records[vi]
        if !vocab_new_heads.contains(vocab.VocabHead){
            temp_GlobalVocabRec.append(vocab)
        }
    }
    
    for vocab in vocabs_updated{
        temp_GlobalVocabRec.append(vocab)
    }
    global_vocabs_records = temp_GlobalVocabRec
}

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


// MARK: - Other Functions
func hasSpecialCharacters(str: String) -> Bool {

    do {
        let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9+-].*", options: .caseInsensitive)
        if let _ = regex.firstMatch(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, str.count)) {
            return true
        }

    } catch {
        debugPrint(error.localizedDescription)
        return false
    }

    return false
}



func getMinMaxDateOfVocabRecords() -> [Date]{
    let minDate = Date().adding(durationVal: -numOfDayInStatCurve + 1, durationType: .day)
    return [minDate, Date()]
}

func getDatesLearned() -> [Date]{
    var datesLearned:[Date] = []
    let LearningRecords:[Record] = global_records.filter { $0.recordType == 1 }
    for lrec in LearningRecords{
        datesLearned.append(lrec.endDate)
    }
    return datesLearned
}

func getDatesReviewed() -> [Date]{
    var datesReviewed:[Date] = []
    let ReviewRecords:[Record] = global_records.filter { $0.recordType == 2 }
    for lrec in ReviewRecords{
        datesReviewed.append(lrec.endDate)
    }
    return datesReviewed
}


func getDaysDaka() -> [String]{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    var datesDakaSet:Set = Set<String>()
    var datesDaka:[String] = []
    let datesLearned = getDatesLearned()
    for date in datesLearned{
        let date_str = formatter.string(from: date)
        datesDakaSet.insert(date_str)
    }
    let datesReviewed = getDatesReviewed()
    for date in datesReviewed{
        let date_str = formatter.string(from: date)
        datesDakaSet.insert(date_str)
    }
    for dateStr in datesDakaSet{
        datesDaka.append(dateStr)
    }
    return datesDaka
    
}


func getNumOfDayInsist() -> Int {
    let datesDaka = getDaysDaka()
    return datesDaka.count
}

func getVocabDate(vocab: VocabularyRecord, dateType: DateType) -> String?{
    let formatter = DateFormatter()
    formatter.dateFormat = "MM月dd日-yyyy"
    switch dateType {
        case .learn:
            if let date = vocab.LearnDate {
                return formatter.string(from: date)
            }
            else{
                return nil
            }
        case .master:
            if let date = vocab.MasteredDate {
                return formatter.string(from: date)
            }
            else{
                return nil
            }
        case .collect:
            if let date = vocab.CollectDate {
                return formatter.string(from: date)
            }
            else{
                return nil
            }
    }
}

func formatDateAsCategory(dates: [Date], byDay: Bool = true) -> [String] {
    let formatter = DateFormatter()
    var categories:[String] = []
    for date in dates{
        if byDay{
            if Calendar.current.isDate(date, inSameDayAs: Date()){
                categories.append("今天")
            }else{
                formatter.dateFormat = "MM-dd"
                let dateStr = formatter.string(from: date)
                categories.append(dateStr)
            }
        } else{
            if date.isInSameMonth(as: Date()){
                categories.append("本月")
            }else{
                formatter.dateFormat = "MM月"
                let dateStr = formatter.string(from: date)
                categories.append(dateStr)
            }
        }
        
    }
    return categories
}

func getTimeSlotIndex(t0:Date, t1:Date) -> Int{
    let hour = Double(t1.hours(from: t0))
    var index: Int = -1
    for hi in 1..<hoursOfEbbinhaus.count{
        if hour < hoursOfEbbinhaus[hi]{
            index = hi - 1
            break
        }
    }
    return index
}

func getNumerOfVocabsWithinDate(date: Date) -> Double{
    var numOfVocabRemembered:Double = 0.0
    for vocab in global_vocabs_records{
        if vocab.Mastered{
            numOfVocabRemembered += 1.0
        }
        else{
            if let dueDate = vocab.ReviewDUEDate{
                if dueDate > date{
                    numOfVocabRemembered += 1.0
                }
            }
        }
    }
    return numOfVocabRemembered
}

func getDeviceId(deviceToken: Data){
    var deviceId = String()
    if #available(iOS 13.0, *) {
        let bytes = [UInt8](deviceToken)
        for item in bytes {
            deviceId += String(format:"%02x", item&0x000000FF)
        }
        print("iOS 13 deviceToken：\(deviceId)")
    } else {
        let device = NSData(data: deviceToken)
        deviceId = device.description.replacingOccurrences(of:"<", with:"").replacingOccurrences(of:">", with:"").replacingOccurrences(of:" ", with:"")
        print("我的deviceToken：\(deviceId)")
    }
}

func getLongTermMemNumbers() -> [Double]{
    var vocabNums:[Double] = []
    let dateNow = Date()
    for di in 0..<daysOfLongTerm.count{
        let futureDate = dateNow.adding(durationVal: daysOfLongTerm[di], durationType: .day)
        vocabNums.append(getNumerOfVocabsWithinDate(date: futureDate))
    }
    return vocabNums
}

func getRetentionsFromVocabRecords() -> [Double]{
    var vocabs:[VocabularyRecord] = []
    
    //Get the vocab records that are forgotten at the first learning time
    for vocab in global_vocabs_records{
        if vocab.BehaviorHistory.count > 1{
            if vocab.BehaviorHistory[0] == CardBehavior.forget.rawValue{
                vocabs.append(vocab)
            }
        }
    }
    var hoursSlotCountOfRemember:[Double] = [] // Count the number of remembered words for each time slot
    var hoursSlotCountOfTotal:[Double] = [] // Count the number of total words for each time slot
    
    //Init
    for _ in 0..<hoursOfEbbinhaus.count-1{
        hoursSlotCountOfRemember.append(0)
        hoursSlotCountOfTotal.append(0)
    }
    
    for vocab in vocabs{
        if vocab.BehaviorHistory.count > 1{
            let card_bhvs = vocab.BehaviorHistory
            let card_bhv_dates = vocab.BehaviorDates
            let t0 = vocab.BehaviorDates[0]
            for ci in 1..<card_bhv_dates.count{
                let behav_date = card_bhv_dates[ci]
                let time_slot_ind = getTimeSlotIndex(t0: t0, t1: behav_date)
                if time_slot_ind > -1{
                    let card_bhv = card_bhvs[ci]
                    if card_bhv == CardBehavior.remember.rawValue{
                        hoursSlotCountOfRemember[time_slot_ind] += 1
                    }
                    hoursSlotCountOfTotal[time_slot_ind] += 1
                }
            }
        }
    }
    
    var values:[Float] = [100.0]
    var indices:[Float] = [0.0]
    
    for hi in 0..<hoursSlotCountOfTotal.count{
        let n_rem = hoursSlotCountOfRemember[hi]
        let n_tot = hoursSlotCountOfTotal[hi]
        if n_tot > minNumOfVocabsForRetentionCalc{
            values.append(Float(n_rem*100.0/n_tot))
            indices.append(Float(hoursOfEbbinhaus[hi + 1]))
        }
    }
    let maxIndex: Float = indices.max()!
    for hour in hoursOfEbbinhaus{
        if Float(hour) > maxIndex{
            indices.append(Float(hour))
            values.append(Float(0.0))
        }
    }
    let n = vDSP_Length(Int(hoursOfEbbinhaus.max()!))
    let stride = vDSP_Stride(1)
    var result = [Float](repeating: 0,
                           count: Int(n))
    vDSP_vgenp(values, stride,
               indices, stride,
               &result, stride,
               n,
               vDSP_Length(values.count))
    var retentions:[Double] = [100.0]
    for hi in 0..<hoursOfEbbinhaus.count-1{
        let hour: Int = Int(hoursOfEbbinhaus[hi+1])
        retentions.append(Double(result[hour-1]))
    }
    return retentions
}

func generateDatesForMinMaxDates(minMaxDates:[Date], byDay: Bool = true)-> [Date]{
    if minMaxDates.count != 2{
        return []
    }
    else {
        var minDate = minMaxDates[0]
        let maxDate = minMaxDates[1]
        if byDay{
            let diffDay = Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day
            if diffDay != nil && diffDay! < 6{
                minDate = maxDate.adding(durationVal: -6, durationType: .day)
            }
            return Date.dates(from: minDate, to: maxDate)
        } else{
            let diffMon = Calendar.current.dateComponents([.month], from: minDate, to: maxDate).month
            if diffMon != nil && diffMon! < 5{
                minDate = maxDate.adding(durationVal: -5, durationType: .month)
            }
            let dates = generateDatesByMonth(fromDate: minDate, endDate: maxDate)
            return dates
        }
        
    }
}

func generateDatesByMonth(fromDate: Date, endDate: Date) -> [Date]{
    var dates: [Date] = []
    
    var dc = Calendar.current.dateComponents([.year, .month], from: fromDate)
    dc.day = 1
    dc.timeZone = TimeZone(identifier: TimeZone.current.identifier)
    dc.hour = 0
    dc.minute = 0
    dc.second = 1
    
    let initialDate = Calendar.current.date(from: dc) ?? endDate
    var monthCount = 0
    while initialDate.adding(durationVal: monthCount, durationType: .month) < endDate {
        dates.append(initialDate.adding(durationVal: monthCount, durationType: .month))
        monthCount += 1
    }
    return dates
}

func isSameDay(date1: Date, date2: Date) -> Bool {
    let diffDay = Calendar.current.dateComponents([.day, .month, .year], from: date1, to: date2)
    
    if diffDay.day == 0 && diffDay.month == 0 && diffDay.year == 0{
        return true
    } else {
        return false
    }
}

func filterBehaviorsInDiffDays(bhvs:[Int], dates:[Date]) -> [Int]{
    var dateIndexsInDiffDays:[Int] = []
    var lastDate:Date = Date().adding(durationVal: -100, durationType: .year)
    let fiftyYrsAgo:Date = Date().adding(durationVal: -50, durationType: .year)
    for di in 0..<dates.count{
        if lastDate < fiftyYrsAgo{
            lastDate = dates[di]
            dateIndexsInDiffDays.append(di)
        }else{
            if !isSameDay(date1: dates[di], date2: lastDate){
                lastDate = dates[di]
                dateIndexsInDiffDays.append(di)
            }
        }
    }
    
    var bhvsInDiffDays:[Int] = []
    for dindex in dateIndexsInDiffDays{
        bhvsInDiffDays.append(bhvs[dindex])
    }
    return bhvsInDiffDays
}

func isExactSeqMemory(vocab: VocabularyRecord) -> Bool{
    let behaviors:[Int] = filterBehaviorsInDiffDays(bhvs: vocab.BehaviorHistory, dates: vocab.BehaviorDates)//vocab.BehaviorHistory//
    if behaviors.count < numberOfContDaysForMasteredAWord{
        return false
    }
    else{
        let tempalateArr:[String] = Array(repeating: CardBehavior.remember.rawValue, count: numberOfContDaysForMasteredAWord).map { String($0) }
        let templateStrStr = tempalateArr.joined(separator: "")
        let behaviorArr:[String] = behaviors.map { String($0) }
        let behaviorStr: String = behaviorArr.joined(separator: "")
        
        if let range = behaviorStr.range(of: templateStrStr) {
            let endPos = behaviorStr.distance(from: behaviorStr.startIndex, to: range.upperBound)
            if endPos >= behaviorStr.count - 1{
                return true
            }
            else{
                return false
            }
        } else {
            return false
        }
    }
}


/**
 
 For a VocabRecord, calculate the number of max sequentially memorized times.

 - Parameter vocab: The vocabulary record to calculate

 - Returns: the number of max sequentially memorized times
 
 */

func getNumOfSeqMem(vocab: VocabularyRecord) -> Int{
    var numOfSeqMem:Int = 0
    let behaviors:[Int] = filterBehaviorsInDiffDays(bhvs: vocab.BehaviorHistory, dates: vocab.BehaviorDates).reversed()//vocab.BehaviorHistory.reversed()//
    
    var idx = 0
    while idx < behaviors.count && behaviors[idx] == CardBehavior.remember.rawValue{
        numOfSeqMem += 1
        idx += 1
    }
    
    return numOfSeqMem
}


func get_vocab_rec_need_to_be_review() -> [VocabularyRecord]{
    
    let vocab_rec_need_to_be_review:[VocabularyRecord] = global_vocabs_records.filter{ !$0.Mastered && !isExactSeqMemory(vocab: $0) && ($0.ReviewDUEDate ?? Date().adding(durationVal: 1, durationType: .hour) < Date())}
    
    return vocab_rec_need_to_be_review
}

func get_vocab_rec_need_to_be_review_for_record(vocabHeads:[String]) ->[VocabularyRecord]{
    var vocab_rec_need_to_be_review:[VocabularyRecord] = []
    for vocab in global_vocabs_records{
        if vocabHeads.contains(vocab.VocabHead) && !vocab.Mastered{
            vocab_rec_need_to_be_review.append(vocab)
        }
    }
    return vocab_rec_need_to_be_review
}

func printRecords(){
    let wordhead:String = "leather"
    
    for record in global_records{
        if record.vocabHeads.contains(wordhead){
            let vocabs:[VocabularyRecord] = global_vocabs_records.filter {record.vocabHeads.contains($0.VocabHead)}
            for vocab in vocabs{
                print("\(vocab.VocabHead):\(vocab.Mastered)\t\(vocab.BehaviorHistory)")
            }
        }
    }
}

func get_recent_vocab_rec_need_to_be_review() -> [VocabularyRecord]{
    var vocab_rec_need_to_be_review:[VocabularyRecord] = []
    if let recentRecord:Record = global_records.max(by: ({ $0.endDate < $1.endDate })){
        vocab_rec_need_to_be_review = get_vocab_rec_need_to_be_review_for_record(vocabHeads: recentRecord.vocabHeads)
    }
    
    return vocab_rec_need_to_be_review
}

func getCumulatedMasteredByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true) -> [Double]{
    
    var reviewedVocabIdDateDict:[String: Date] = [:]
    
    let ReviewRecords:[Record] = global_records.filter { $0.recordType == 2 }
    
    for revRec in ReviewRecords{
        for vocabHead in revRec.vocabHeads{
            reviewedVocabIdDateDict[vocabHead] = revRec.endDate
        }
    }
    
    var masteredVocabs:[VocabularyRecord] = []
    
    var datesWithSequentialMemorized:[Date] = []
    
    for vocab in global_vocabs_records{
        if vocab.Mastered{
            masteredVocabs.append(vocab)
        }
        else if reviewedVocabIdDateDict.keys.contains(vocab.VocabHead) && isExactSeqMemory(vocab: vocab){
            if let date = reviewedVocabIdDateDict[vocab.VocabHead] {
                datesWithSequentialMemorized.append(date)
            }
        }
    }
    
    var cumMastered:[Double] = []
    for di in 0..<dates.count{
        cumMastered.append(0)
        for vocab in masteredVocabs{
            if byDay{
                if Calendar.current.isDate(vocab.MasteredDate ?? Date(), inSameDayAs: dates[di]){
                    cumMastered[di] += 1
                }
            } else{
                if dates[di].isInSameMonth(as: vocab.LearnDate ?? Date()){
                    cumMastered[di] += 1
                }
            }
        }
        
        for dateWithMem in datesWithSequentialMemorized{
            if byDay{
                if Calendar.current.isDate(dateWithMem, inSameDayAs: dates[di]){
                    cumMastered[di] += 1
                }
            } else{
                if dates[di].isInSameMonth(as: dateWithMem){
                    cumMastered[di] += 1
                }
            }
            
        }
        
        if cumulated && di > 0{
            cumMastered[di] += cumMastered[di - 1]
        }
    }
    return cumMastered
}

func calcRetention(hour: Double) -> Double{
    let k:Double = 1.48
    let c:Double = 2.25
    if (hour > 0){
        let retention:Double = (100 * k) / (c * log10(hour) + k)
        return retention
    }
    else{
        return 0.0
    }
}

func getEbbinHausRetention(hours: [Double]) -> [Double]{
    var retentions:[Double] = []
    for hour in hours{
        retentions.append(calcRetention(hour: hour))
    }
    return retentions
}


func getCumulatedLearnedByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true) -> [Double]{
    
    var cumLearned:[Double] = []
    
    let LearningRecords:[Record] = global_records.filter { $0.recordType == 1 }
    
    for di in 0..<dates.count{
        cumLearned.append(0)
        for lrec in LearningRecords{
            if byDay{
                if Calendar.current.isDate(lrec.endDate, inSameDayAs: dates[di]){
                    cumLearned[di] += Double(lrec.vocabHeads.count)
                }
            } else{
                if dates[di].isInSameMonth(as: lrec.endDate){
                    cumLearned[di] += Double(lrec.vocabHeads.count)
                }
            }
            
        }
        if cumulated && di > 0{
            cumLearned[di] += cumLearned[di - 1]
        }
    }
    return cumLearned
}

func getCumHoursByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true, Learn: Bool = true) -> [Double]{
    
    var cumLearned:[Double] = []
    
    let LearningRecords:[Record] = global_records.filter { $0.recordType == 1 }
    
    let ReviewRecords:[Record] = global_records.filter { $0.recordType == 2 }
    
    for di in 0..<dates.count{
        cumLearned.append(0)
        if Learn{
            for lrec in LearningRecords{
                if byDay{
                    if Calendar.current.isDate(lrec.endDate, inSameDayAs: dates[di]){
                        let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Double(secondT) / Double(60)
                        }
                    }
                } else{
                    if dates[di].isInSameMonth(as: lrec.endDate){
                        let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Double(secondT) / Double(60)
                        }
                    }
                }
                
            }
        }else{
            for rrec in ReviewRecords{
                if byDay{
                    if Calendar.current.isDate(rrec.endDate, inSameDayAs: dates[di]){
                        let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Double(secondT) / Double(60)
                        }
                    }
                } else{
                    if dates[di].isInSameMonth(as: rrec.endDate){
                        let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Double(secondT) / Double(60)
                        }
                    }
                }
                
            }
        }
        
        if cumulated && di > 0{
            cumLearned[di] += cumLearned[di - 1]
        }
    }
    return cumLearned
}

func getMasteredProgress(vocab: VocabularyRecord) -> Float{
    if vocab.Mastered{
        return Float(1.0)
    }
    else{
        let behaviors = vocab.BehaviorHistory
        let behaviorStr: String = String(behaviors.map { String($0) }.joined(separator: "").reversed())
        var numberContinousRemember: Int = 0
        for idx in 0..<behaviorStr.count{
            if String(behaviorStr[idx]) == "1"{
                if idx == 0{
                    return Float(0.0)
                }
                else{
                    break
                }
            }else if String(behaviorStr[idx]) == "3"{
                numberContinousRemember += 1
            }
        }
        return min(Float(numberContinousRemember)/Float(5.0), Float(1.0))
    }
}

func groupVocabRecByDate(dateType: DateType) -> [String : [VocabularyRecord]]{
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    switch dateType {
        case .learn:
            for vocab in global_vocabs_records {
                if vocab.LearnDate != nil && !vocab.Mastered && !isExactSeqMemory(vocab: vocab){
                    if let date:String = getVocabDate(vocab: vocab, dateType: dateType) {
                        if let _ = groupedVocabs[date] {
                            groupedVocabs[date]!.append(vocab)
                        }else{
                            groupedVocabs[date] = []
                            groupedVocabs[date]!.append(vocab)
                        }
                    }
                }
            }
        case .master:
            for vocab in global_vocabs_records {
                if vocab.Mastered || isExactSeqMemory(vocab: vocab){
                    if let date:String = getVocabDate(vocab: vocab, dateType: dateType) {
                        if let _ = groupedVocabs[date] {
                            groupedVocabs[date]!.append(vocab)
                        }else{
                            groupedVocabs[date] = []
                            groupedVocabs[date]!.append(vocab)
                        }
                    }
                }
            }
        case .collect:
            for vocab in global_vocabs_records {
                if vocab.CollectDate != nil {
                    if let date:String = getVocabDate(vocab: vocab, dateType: dateType) {
                        if let _ = groupedVocabs[date] {
                            groupedVocabs[date]!.append(vocab)
                        }else{
                            groupedVocabs[date] = []
                            groupedVocabs[date]!.append(vocab)
                        }
                    }
                }
            }
    }
    return groupedVocabs
}

func getVocabHeadsFromVocabRecords(VocabRecords: [VocabularyRecord]) -> [String]{
    var VocabIds:[String] = []
    for VocabRecord in VocabRecords{
        VocabIds.append(VocabRecord.VocabHead)
    }
    return VocabIds
}

// MARK: - Storage Functions

func saveStringTo(fp: String, jsonStr: String){
    do {
        try Disk.save(jsonStr, to: .documents, as: fp)
        print("write \(fp) successful!")
    } catch {
        print(error.localizedDescription)
    }
}

func loadIntArrayFromFile(fp: String) -> [Int] {
    do {
        let intStr:String = try Disk.retrieve(fp, from: .documents, as: String.self)
        
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

// MARK: - Words Functions

func get_words_need_to_be_review(vocab_rec_need_to_be_review: [VocabularyRecord]) -> [JSON]{
    
    let bookSets:Set<String> = Set<String>(vocab_rec_need_to_be_review.map{ $0.BookId })
    var review_words:[JSON] = []
    
    for bookId in bookSets{
        let vocabsTemp: [VocabularyRecord] = vocab_rec_need_to_be_review.filter{ $0.BookId == bookId}
        let book_json_obj = load_json(fileName: bookId)
        let chapters = book_json_obj["chapters"].arrayValue
        let words_dict = book_json_obj["words"].dictionaryValue
        
        for vocab in vocabsTemp{
            let ind_arr = words_dict[vocab.VocabHead]!.arrayValue
            let chpt_idx = ind_arr[0].intValue
            let word_idx = ind_arr[1].intValue
            let word_data = chapters[chpt_idx]["data"].arrayValue[word_idx]
            review_words.append(word_data)
        }
    }
    
    return review_words
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

func update_words(preference: Preference) -> [JSON]
{
    var words:[JSON] = []
    if let _ = preference.current_book_id {
        let learnt_word_heads: Set = Set<String>(global_vocabs_records.map{ $0.VocabHead })
        
        let chapters = currentbook_json_obj["chapters"].arrayValue
        
        var words_left:[String] = []
        var words_left_dict:[String:Int] = [:]
        var word_left_chpt_inds: [Int] = []
        var word_left_indexs_in_chpt: [Int] = []
        
        var word_cnt:Int = 0
        
        for chpt_idx in 0..<chapters.count{
            let chapter = chapters[chpt_idx]
            let word_heads = chapter["word_heads"].arrayValue.map {$0.stringValue}
            for wid in 0..<word_heads.count{
                let word = word_heads[wid]
                if !(learnt_word_heads.contains(word)){
                    words_left.append(word)
                    words_left_dict[word] = word_cnt
                    word_cnt += 1
                    word_left_chpt_inds.append(chpt_idx)
                    word_left_indexs_in_chpt.append(wid)
                }
            }
        }
        
        let sorted_words_left = words_left.sorted(by: <)
        
        let memOrder = preference.memory_order
        let number_of_words_per_group = preference.number_of_words_per_group
        
        let sampling_number:Int = min(number_of_words_per_group, words_left.count)
        
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
           let word_head_selected: String = sorted_words_left[selectedIndexs[ind]]
           let selectedInd: Int = words_left_dict[word_head_selected]!
           let word_chp_ind: Int = word_left_chpt_inds[selectedInd]
           let word_in_chp_ind: Int = word_left_indexs_in_chpt[selectedInd]
           let word_data = chapters[word_chp_ind]["data"].arrayValue[word_in_chp_ind]
           words.append(word_data)
        }
        let jsonStr = selectedIndexs.map { String($0) }.joined(separator: ",")
        saveStringTo(fp: "words.json", jsonStr: jsonStr)
    }
    return words
}


func get_words(currentUser: LCUser, preference: Preference) -> [JSON] {
    let wordsJsonFp = "words.json"
    var words:[JSON] = []
    if Disk.exists(wordsJsonFp, in: .documents) {
        
        let selectedIndexs:[Int] = loadIntArrayFromFile(fp: wordsJsonFp)
        
        if let bookId = preference.current_book_id {
            if currentbook_json_obj.count == 0{
                currentbook_json_obj = load_json(fileName: bookId)
            }
            
            let learnt_word_heads: Set = Set<String>(global_vocabs_records.map{ $0.VocabHead })
            
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
            
            for ind in 0..<selectedIndexs.count{
               let selectedInd = selectedIndexs[ind]
               let word_chp_ind: Int = word_left_chpt_inds[selectedInd]
               let word_in_chp_ind: Int = word_left_indexs_in_chpt[selectedInd]
               let word_data = chapters[word_chp_ind]["data"].arrayValue[word_in_chp_ind]
                words.append(word_data)
            }
            
        }
    }else{
        words = update_words(preference: preference)
    }
    return words
}

// MARK: - Notification Functions

func obtainNotificationContent() -> UNMutableNotificationContent{
    let content = UNMutableNotificationContent()
    content.body = notification_content
    content.categoryIdentifier = "reviewReminder"
    content.sound = UNNotificationSound.default
    return content
}

func add_notification_date(notification_date: Date) -> UNNotificationRequest?{
    let notification_trigger = obtainCalendarNotificationTriggerByDate(notification_date: notification_date)
    let notification_content = obtainNotificationContent()
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification_content, trigger: notification_trigger)
    return request
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


// MARK: - LeanCloud Functions
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


// MARK: - Controller Util

func presentAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
}

func getWordPronounceURL(word: String, us_pronounce:Bool = true, fromMainScreen: Bool = false) -> URL?{
    let usphone = fromMainScreen ? 0 : (us_pronounce == true ? 0 : 1)
    if word != ""{
        let replaced_word = word.replacingOccurrences(of: " ", with: "+")
        if !hasSpecialCharacters(str: replaced_word){
            let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(replaced_word)"
            let mp3_url:URL = URL(string: url_string)!
            return mp3_url
        }
    }
    return nil
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
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    let dc = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
    let dateString = "\(dc.month!)月\(dc.day!)日 \(dc.hour!):\(dc.minute!)"
    print("PRINT DATE: \(dateString)")
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

// MARK: - JSON Util

func savejson(fileName: String, jsonData: Data){
    do {
        let json_fp = "\(fileName).json"
        try Disk.save(jsonData, to: .documents, as: json_fp)
        print("write \(fileName).json successful!")
    } catch {
        print(error.localizedDescription)
    }
}

func load_json(fileName: String) -> JSON{
    do {
       let json_fp = "\(fileName).json"
       let data = try Disk.retrieve(json_fp, from: .documents, as: Data.self)
       let json = try JSON(data: data)
       return json
    } catch {
        print(error.localizedDescription)
    }
    let json: JSON = []
    return json
}

//

func initLoadingIndicator(view: UIView){
    hud.textLabel.text = loadingText
    hud.textLabel.theme_textColor = "IndicatorColor"
    hud.backgroundColor = .clear
    hud.show(in: view)
}

func stopLoadingIndicator(){
    hud.dismiss()
}

func obtainNextReviewDate(vocabs:[VocabularyRecord]) -> Date?{
    var vocabsNeedReview:[VocabularyRecord] = []
    
    //Get rid of the mastered vocabs
    for vocabRecord in vocabs{
        if !vocabRecord.Mastered{
            vocabsNeedReview.append(vocabRecord)
        }
    }
    
    //Get the max review date
    var maxReviewDate:Date? = nil
    if vocabsNeedReview.count > 0{
        for vocab in vocabsNeedReview{
            if let tempMaxReviewDate = maxReviewDate{
                if let reviewDate = vocab.ReviewDUEDate{
                    if tempMaxReviewDate < reviewDate{
                        maxReviewDate = reviewDate
                    }
                }
            }
            else{
                if let reviewDate = vocab.ReviewDUEDate{
                    maxReviewDate = reviewDate
                }
            }
            
        }
    }
    return maxReviewDate
}
