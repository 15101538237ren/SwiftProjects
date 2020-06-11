//
//  RecordUtil.swift
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

let reviewRecordJsonFp = "reviewRecord.json"
let vocabRecordJsonFp = "vocabRecord.json"
let learningRecordJsonFp = "learningRecord.json"

let ReviewRecordIdKey = "ReviewRecordId"
let LearningRecordIdKey = "LearningRecordId"
let VocabRecordIdKey = "VocabRecordId"
let saveRecordToClouldFailedKey = "saveRecordIdToClouldFailedy"
var saveRecordToClouldFailed : Bool = getSaveRecordToClouldStatus(saveRecordToClouldFailedKey)


var vocabRecordsOfCurrentLearning:[VocabularyRecord] = []
var currentLearningRec: LearningRecord = initNewLearningRec()


var GlobalReviewRecords:[ReviewRecord] = loadReviewRecords()
var GlobalVocabRecords:[VocabularyRecord] = loadVocabRecords()
var GlobalLearningRecords:[LearningRecord] = loadLearningRecords()


// MARK: - Overall Util

func saveRecordsLocally(){
    saveVocabRecordsLocally()
    saveReviewRecordsLocally()
    saveLearningRecordsLocally()
}

func uploadRecordsIfNeeded(){
    let uploadFailedKey = "uploadFailed"
    if let user = LCApplication.default.currentUser {
        if let username = user.get("username"){
            
            if isKeyPresentInUserDefaults(key: uploadFailedKey){
                let uploadfailed:Bool = UserDefaults.standard.bool(forKey: uploadFailedKey)
                if uploadfailed == true{
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

func syncRecords(){
    if let user = LCApplication.default.currentUser {
        if let userName = user.get("username"){
            if let reviewRecordpath = getDefaultFilePath(fileName: reviewRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: reviewRecordpath) {
                if Reachability.isConnectedToNetwork(){
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
            }
            if let vocabRecordPath = getDefaultFilePath(fileName: vocabRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: vocabRecordPath) {
                if Reachability.isConnectedToNetwork(){
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
            }
            if let learningRecordPath = getDefaultFilePath(fileName: learningRecordJsonFp)
            {
                if !FileManager.default.fileExists(atPath: learningRecordPath) {
                if Reachability.isConnectedToNetwork(){
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
}

// MARK: - Vocab Util
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

func getVocabIdsFromVocabRecords(VocabRecords: [VocabularyRecord]) -> [String]{
    var VocabIds:[String] = []
    for VocabRecord in VocabRecords{
        VocabIds.append(VocabRecord.VocabRecId)
    }
    return VocabIds
}

func clearVocabRecordsOfCurrentLearning(){
    vocabRecordsOfCurrentLearning = []
}

func loadVocabRecords() -> [VocabularyRecord] {
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(vocabRecordJsonFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)//, options: .mappedIfSafe)
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
    let jsonData = try! JSONEncoder().encode(GlobalVocabRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonString)
    update_words()
}

func saveVocabRecordsToClould(vocabRecords: [VocabularyRecord], username: String){
    let jsonData = try! JSONEncoder().encode(vocabRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    let recordClass = "VocabRecord"
    saveRecordStringToCloud(recordClass: recordClass, saveRecordFailedKey: saveRecordToClouldFailedKey, recordIdKey: VocabRecordIdKey, username: username, jsonString: jsonString)
}


// MARK: - LearningRecord Util

func initNewLearningRec() -> LearningRecord{
    return LearningRecord.init(StartDate: Date(), EndDate: Date(), VocabRecIds: [])
}

func saveLearningRecordsFromLearning() {
    //Save learnt records
    GlobalVocabRecords.append(contentsOf: vocabRecordsOfCurrentLearning)
    saveVocabRecords()
    GlobalLearningRecords.append(currentLearningRec)
    saveLearningRecords()
    UserDefaults.standard.set(true, forKey: "uploadFailed")
    uploadRecordsIfNeeded()
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

func saveLearningRecords(){
    let jsonData = try! JSONEncoder().encode(GlobalLearningRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    saveStringTo(fileName: learningRecordJsonFp, jsonStr: jsonString)
    
    let recordClass = "LearningRecord"
    saveRecordStringToCloud(recordClass: recordClass, saveRecordFailedKey: saveRecordToClouldFailedKey, recordIdKey: LearningRecordIdKey, username: GlobalUserName, jsonString: jsonString)
}


// MARK: - ReviewRecord Util
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
    
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(reviewRecordJsonFp)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let reviewRecords = try decoder.decode([ReviewRecord].self, from: data)
            return reviewRecords
        }
        else{
            if Reachability.isConnectedToNetwork(){
               DispatchQueue.global(qos: .background).async {
                do {
                    let user = LCApplication.default.currentUser!
                    if let prefId = user.get(DefaultPrefIdKey)?.stringValue{
                        do {
                            let userPreferenceQuery = LCQuery(className: "UserPreference")
                            let _ = userPreferenceQuery.get(prefId) { (result) in
                                switch result {
                                case .success(object: let pref):
                                    let prefStr:String = pref.get("Preference")!.stringValue!
                                    USER_PREFERENCE = decodePreferenceFromStr(prefStr: prefStr)
                                case .failure(error: let error):
                                    print(error)
                                }
                            }
                        }
                    }else{
                        initPreference()
                    }
                }
            }
        }
        }
    } catch {
        print(error.localizedDescription)
    }
    
    let reviewRecords: [ReviewRecord] =  []
    return reviewRecords
}

func saveReviewRecords(){
    let jsonData = try! JSONEncoder().encode(GlobalReviewRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    saveStringTo(fileName: reviewRecordJsonFp, jsonStr: jsonString)
    
    let recordClass = "ReviewRecord"
    saveRecordStringToCloud(recordClass: recordClass, saveRecordFailedKey: saveRecordToClouldFailedKey, recordIdKey: ReviewRecordIdKey, username: GlobalUserName, jsonString: jsonString)
}

