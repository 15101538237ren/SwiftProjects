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
            print(error)
        }
        return preference
    }
    else
    {
        do {
            let preference:Preference = try Disk.retrieve(preference_fp, from: .documents, as: Preference.self)
            return preference
            print("Loaded Preference Successful!")
        } catch {
            print(error)
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

/**
 
 Save record objects to disk

 - Parameter userId: The objectId of user on LeanCloud

 - Parameter records: The record objects to save

 - Returns: none
 
 */

func saveRecordsToDisk(userId: String, records: [Record]){
    let records_fp:String = "\(userId)_records.json"
    do {
        try Disk.save(records, to: .documents, as: records_fp)
        print("Saved Records to Disk Successful!")
    } catch {
        print(error)
    }
}

/**
 
 Load records from disk to memory, if not exist, try load from LeanCloud.

 - Parameter userId: The objectId of user on LeanCloud

 - Returns: none
 
 */

func loadRecords(currentUser: LCUser){
    
    let records_fp:String = "\(userId)_records.json"
    
    if !Disk.exists(records_fp, in: .documents)
    {
        loadRecordsFromCloud()
    }
    else
    {
        do {
            let records: [Record] = try Disk.retrieve(records_fp, from: .documents, as: [Record].self)
            global_records = records
            print("Loaded Records from Disk Successful!")
        } catch {
            print(error)
        }
    }
}


func updateRecords(records: [Record]){
    if global_records == nil{
        global_records = records
    }else{
        let uuids:[String] = global_records!.map { $0.uuid }
        for record in records{
            if !uuids.contains(record.uuid){
                global_records!.append(record)
            }
        }
    }
}

func parseLCRecords(items: [LCObject]) -> [Record] {
    var records:[Record] = []
    
    for item in items
    {
        let uuid = item.get("uuid")!.stringValue
        let recordTypeValue: Int = item.get("recordType")!.intValue
        let startDate: Date = item.get("startDate")!.dateValue
        let endDate: Date = item.get("endDate")!.dateValue
        
        var vocabRecords:[VocabularyRecord] = []
        if let vocabRecordObjs = item.get("vocabRecords")?.arrayValue as? [LCObject]
        {
            for vocabRecordObj in vocabRecordObjs{
                let vocabHead:String = vocabRecordObj.get("VocabHead")!.stringValue
                let BookId:String = vocabRecordObj.get("BookId")!.stringValue
                let Mastered:Bool = vocabRecordObj.get("Mastered")!.boolValue
                let BehaviorHistory:[Int] = vocabRecordObj.get("BehaviorHistory")!.arrayValue as? [Int]
                
                let LearnDate:Date? = vocabRecordObj.get("LearnDate")?.dateValue
                let CollectDate:Date? = vocabRecordObj.get("CollectDate")?.dateValue
                let MasteredDate:Date? = vocabRecordObj.get("MasteredDate")?.dateValue
                let ReviewDUEDate:Date? = vocabRecordObj.get("ReviewDUEDate")?.dateValue
                
                let vocabRecord = VocabularyRecord(VocabHead: vocabHead, BookId: BookId, LearnDate: LearnDate, CollectDate: CollectDate, Mastered: Mastered, MasteredDate: MasteredDate, ReviewDUEDate: ReviewDUEDate, BehaviorHistory: BehaviorHistory)
                
                vocabRecords.append(vocabRecord)
            }
        }
        let record: [Record] = Record(uuid: uuid, recordType: getRecordTypeFromValue(value: recordTypeValue), startDate: startDate, endDate: endDate, vocabRecords: vocabRecords)
    }
    return records
}

func fetchBatchRecordsFromCloud(skip: Int = 0){
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
                    let records = parseLCRecords(records: items)
                    updateRecords(records: records)
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
        }
    }else{
        print(NoNetworkStr)
    }
}

func loadRecordsFromCloud()
{
    if Reachability.isConnectedToNetwork(){
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Record")
            query.whereKey("user", .equalTo(currentUser))
            query.whereKey("createdAt", .ascending)
            query.limit = QueryLimit
            
            let record_count = query.count()
            
            if record_count > QueryLimit{
                let query_times:Int = Int(ceil(Double(record_count) / Double(QueryLimit)))
                
                for ti in 0..<query_times{
                    let skip = Int(ti * QueryLimit)
                    fetchBatchRecordsFromCloud(skip: skip)
                }
            }else{
                fetchBatchRecordsFromCloud()
            }
        }
        }
    }else{
        print(NoNetworkStr)
    }
}

