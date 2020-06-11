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
    do {
        let jsonData = try! JSONEncoder().encode(GlobalVocabRecords)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonString)
        update_words()
    } catch {
        print(error.localizedDescription)
    }
}

func saveVocabRecordsToClould(vocabRecords: [VocabularyRecord], username: String){
    if Reachability.isConnectedToNetwork(){
       DispatchQueue.global(qos: .background).async {
       do {
           let jsonData = try! JSONEncoder().encode(vocabRecords)
           let jsonString = String(data: jsonData, encoding: .utf8)!
           // 构建对象
            if isKeyPresentInUserDefaults(key: "VocabRecordId"){
                let VocabRecordId: String = UserDefaults.standard.string(forKey: "VocabRecordId")!
            }
            else{
                let vocabRecordObj = LCObject(className: "VocabRecord")

                // 为属性赋值
                try vocabRecordObj.set("username", value: username)
                try vocabRecordObj.set("jsonStr", value: jsonString)

                // 将对象保存到云端
                _ = vocabRecordObj.save { result in
                    switch result {
                    case .success:
                        let VocabRecordId: String = vocabRecordObj.objectId?.stringValue! ?? ""
                        if VocabRecordId != ""{
                            UserDefaults.standard.set(VocabRecordId, forKey: "VocabRecordId")
                        }
                        // 成功保存之后，执行其他逻辑
                        print("VocabRecord saved successfully ")
                        break
                    case .failure(error: let error):
                        // 异常处理
                        print(error)
                    }
                }
            }
           
       } catch {
           print(error.localizedDescription)
           }}
    }
    
}


// MARK: - LearningRecord Util

func initNewLearningRec() -> LearningRecord{
    return LearningRecord.init(StartDate: Date(), EndDate: Date(), VocabRecIds: [])
}

func saveLearningRecordsFromLearning() {
    //Save learnt records
    GlobalVocabRecords.append(contentsOf: vocabRecordsOfCurrentLearning)
    saveVocabRecordsLocally()
    GlobalLearningRecords.append(currentLearningRec)
    saveLearningRecordsLocally()
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
    
    if Reachability.isConnectedToNetwork(){
       DispatchQueue.global(qos: .background).async {
       do {
           let jsonData = try! JSONEncoder().encode(learningRecord)
           let jsonString = String(data: jsonData, encoding: .utf8)!
           // 构建对象
            if isKeyPresentInUserDefaults(key: "LearningRecordId"){
                let LearningRecordId: String = UserDefaults.standard.string(forKey: "LearningRecordId")!
            }
            else{
                let learningRecordObj = LCObject(className: "LearningRecord")

                // 为属性赋值
                try learningRecordObj.set("username", value: username)
                try learningRecordObj.set("jsonStr", value: jsonString)

                // 将对象保存到云端
                _ = learningRecordObj.save { result in
                    switch result {
                    case .success :
                        print(result)
                        // 成功保存之后，执行其他逻辑
                        print("LearningRecord saved successfully ")
                        let LearningRecordId: String = learningRecordObj.objectId?.stringValue! ?? ""
                        if LearningRecordId != ""{
                            UserDefaults.standard.set(LearningRecordId, forKey: "LearningRecordId")
                        }
                        
                        UserDefaults.standard.set(false, forKey: "uploadFailed")
                        break
                    case .failure(error: let error):
                        // 异常处理
                        print(error)
                    }
                }
            }
           
       } catch {
           print(error.localizedDescription)
           }}
    }
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
    if Reachability.isConnectedToNetwork(){
       DispatchQueue.global(qos: .background).async {
       do {
           let jsonData = try! JSONEncoder().encode(reviewRecord)
           let jsonString = String(data: jsonData, encoding: .utf8)!
           // 构建对象
            if isKeyPresentInUserDefaults(key: "ReviewRecordId"){
                let ReviewRecordId: String = UserDefaults.standard.string(forKey: "ReviewRecordId")!
            }
            else{
                let reviewRecordObj = LCObject(className: "ReviewRecord")

                // 为属性赋值
                try reviewRecordObj.set("username", value: username)
                try reviewRecordObj.set("jsonStr", value: jsonString)

                // 将对象保存到云端
                _ = reviewRecordObj.save { result in
                    switch result {
                    case .success:
                        // 成功保存之后，执行其他逻辑
                        let ReviewRecordId: String = reviewRecordObj.objectId?.stringValue! ?? ""
                        if ReviewRecordId != ""{
                            UserDefaults.standard.set(ReviewRecordId, forKey: "ReviewRecordId")
                        }
                        print("ReviewRecordObj saved successfully ")
                        break
                    case .failure(error: let error):
                        // 异常处理
                        print(error)
                    }
                }
            }
        
           
       } catch {
           print(error.localizedDescription)
           }}
    }
    
}


