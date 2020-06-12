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

let reviewRecordClass = "ReviewRecord"
let learningRecordClass = "LearningRecord"
let vocabRecordClass = "VocabRecord"


let saveReviewRecordToClouldFailedKey = "saveReviewRecordToClouldFailed"
let saveLearningRecordToClouldFailedKey = "saveLearningRecordToClouldFailed"
let saveVocabRecordToClouldFailedKey = "saveVocabRecordToClouldFailed"

var saveReviewRecordFailed : Bool = getSaveRecordToClouldStatus(key: saveReviewRecordToClouldFailedKey)
var saveLearningRecordFailed : Bool = getSaveRecordToClouldStatus(key: saveLearningRecordToClouldFailedKey)
var saveVocabRecordFailed : Bool = getSaveRecordToClouldStatus(key: saveVocabRecordToClouldFailedKey)

var vocabRecordsOfCurrentLearning:[VocabularyRecord] = []
var currentLearningRec: LearningRecord = initNewLearningRec()


var GlobalReviewRecords:[ReviewRecord] = loadReviewRecords()
var GlobalVocabRecords:[VocabularyRecord] = loadVocabRecords()
var GlobalLearningRecords:[LearningRecord] = loadLearningRecords()


// MARK: - Overall Util

func prepareRecordsAndPreference(){
    loadPreference()
    GlobalVocabRecords = loadVocabRecords()
    GlobalReviewRecords = loadReviewRecords()
    GlobalLearningRecords = loadLearningRecords()
    
    if !getSaveRecordToClouldStatus(key: savePrefToClouldFailedKey){
        savePreference(saveToLocal: false)
    }
    
    if !getSaveRecordToClouldStatus(key: saveVocabRecordToClouldFailedKey){
        saveVocabRecords(saveToLocal: false, delaySeconds: 1.0)
    }
    
    if !getSaveRecordToClouldStatus(key: saveLearningRecordToClouldFailedKey){
        saveLearningRecords(saveToLocal: false, delaySeconds: 2.0)
    }
    
    if !getSaveRecordToClouldStatus(key: saveReviewRecordToClouldFailedKey){
        saveReviewRecords(saveToLocal: false, delaySeconds: 3.0)
    }
}

// MARK: - Vocab Util
func learntVocabRanks() -> [Int]{
    var vocabRanks:[Int] = []
    let book_id:String = getPreference(key: "current_book_id") as! String
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
    var vocabRecords: [VocabularyRecord] =  []
    do {
        if let data = load_data_from_file(fileFp: vocabRecordJsonFp, recordClass: vocabRecordClass, IdKey: VocabRecordIdKey){
            vocabRecords = try decoder.decode([VocabularyRecord].self, from: data)
        }
    } catch {
        print(error.localizedDescription)
    }
    return vocabRecords
}

func saveVocabRecords(saveToLocal: Bool, delaySeconds:Double = 0){
    let jsonData = try! JSONEncoder().encode(GlobalVocabRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: vocabRecordJsonFp){
        saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonString)
    }
    update_words()
    DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
        saveRecordStringToCloud(recordClass: vocabRecordClass, saveRecordFailedKey: saveVocabRecordToClouldFailedKey, recordIdKey: VocabRecordIdKey, username: GlobalUserName, jsonString: jsonString)
    }
}

// MARK: - LearningRecord Util

func initNewLearningRec() -> LearningRecord{
    return LearningRecord.init(StartDate: Date(), EndDate: Date(), VocabRecIds: [])
}

func saveLearningRecordsFromLearning() {
    //Save learning records and vocabs after learning
    GlobalVocabRecords.append(contentsOf: vocabRecordsOfCurrentLearning)
    saveVocabRecords(saveToLocal: true)
    
    GlobalLearningRecords.append(currentLearningRec)
    saveLearningRecords(saveToLocal: true)
}

func loadLearningRecords() -> [LearningRecord]{
    var learningRecord: [LearningRecord] =  []
    do {
        if let data = load_data_from_file(fileFp: learningRecordJsonFp, recordClass: learningRecordClass, IdKey: LearningRecordIdKey){
            learningRecord = try decoder.decode([LearningRecord].self, from: data)
        }
    } catch {
        print(error.localizedDescription)
    }
    return learningRecord
}

func saveLearningRecords(saveToLocal: Bool, delaySeconds:Double = 0){
    let jsonData = try! JSONEncoder().encode(GlobalLearningRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: learningRecordJsonFp){
        saveStringTo(fileName: learningRecordJsonFp, jsonStr: jsonString)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
        saveRecordStringToCloud(recordClass: learningRecordClass, saveRecordFailedKey: saveLearningRecordToClouldFailedKey, recordIdKey: LearningRecordIdKey, username: GlobalUserName, jsonString: jsonString)
    }
}


// MARK: - ReviewRecord Util
func loadReviewRecords() -> [ReviewRecord]{
    var reviewRecords: [ReviewRecord] =  []
    do {
        if let data = load_data_from_file(fileFp: reviewRecordJsonFp, recordClass: recordClass, IdKey: DefaultPrefIdKey){
            reviewRecords = try decoder.decode([ReviewRecord].self, from: data)
        }
    } catch {
        print(error.localizedDescription)
    }
    return reviewRecords
}

func saveReviewRecords(saveToLocal: Bool, delaySeconds:Double = 0){
    let jsonData = try! JSONEncoder().encode(GlobalReviewRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: reviewRecordJsonFp){
        saveStringTo(fileName: reviewRecordJsonFp, jsonStr: jsonString)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
        saveRecordStringToCloud(recordClass: reviewRecordClass, saveRecordFailedKey: saveReviewRecordToClouldFailedKey, recordIdKey: ReviewRecordIdKey, username: GlobalUserName, jsonString: jsonString)
    }
}

