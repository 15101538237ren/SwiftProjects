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
var vocabRecordsOfCurrentReview:[VocabularyRecord] = []
var currentLearningRec: LearningRecord = initNewLearningRec()
var currentReviewRec: ReviewRecord = initNewReviewRec()


var GlobalReviewRecords:[ReviewRecord] = loadReviewRecords()
var GlobalVocabRecords:[VocabularyRecord] = loadVocabRecords()
var GlobalLearningRecords:[LearningRecord] = loadLearningRecords()


// MARK: - Overall Util

func getMinMaxDateOfVocabRecords() -> [Date]{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    var minDate = Date()
    var maxDate = formatter.date(from: "1000/01/01 00:00")!
    for vocab in GlobalVocabRecords{
        if let learnDate = vocab.LearnDate {
            if learnDate < minDate{
                minDate = learnDate
            }
            else if learnDate > maxDate{
                maxDate = learnDate
            }
        }
    }
    return [minDate, maxDate]
}

func formatDateAsCategory(dates: [Date]) -> [String] {
    let formatter = DateFormatter()
    var categories:[String] = []
    for date in dates{
        if Calendar.current.isDate(date, inSameDayAs: Date()){
            categories.append("今天")
        }else{
            formatter.dateFormat = "MM-dd"
            let dateStr = formatter.string(from: date)
            categories.append(dateStr)
        }
    }
    return categories
}

func generateDatesForMinMaxDates(minMaxDates:[Date])-> [Date]{
    if minMaxDates.count != 2{
        return []
    }
    else {
        var minDate = minMaxDates[0]
        let maxDate = minMaxDates[1]
        if Calendar.current.isDate(minDate, inSameDayAs: maxDate){
            minDate = minDate.adding(durationVal: -7, durationType: .day)
        }
        let dates = Date.dates(from: minDate, to: maxDate)
        return dates
    }
}

func generateCategorieLabelsForMinMaxDates(minMaxDates:[Date])-> [String]{
    if minMaxDates.count != 2{
        return []
    }
    else {
        var minDate = minMaxDates[0]
        let maxDate = minMaxDates[1]
        if Calendar.current.isDate(minDate, inSameDayAs: maxDate){
            minDate = minDate.adding(durationVal: -7, durationType: .day)
        }
        let dates = Date.dates(from: minDate, to: maxDate)
        return formatDateAsCategory(dates: dates)
    }
}


func isExactSeqMemory(vocab: VocabularyRecord) -> Bool{
    let behaviors:[Int] = vocab.BehaviorHistory
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

func getCumulatedMasteredByDate(dates: [Date]) -> [Int]{
    
    var reviewedVocabIdDateDict:[String: Date] = [:]
    for revRec in GlobalReviewRecords{
        for revId in revRec.VocabRecIds{
            reviewedVocabIdDateDict[revId] = revRec.EndDate
        }
    }
    
    var masteredVocabs:[VocabularyRecord] = []
    var datesWithSequentialMemorized:[Date] = []
    for vocab in GlobalVocabRecords{
        if vocab.Mastered{
            masteredVocabs.append(vocab)
        }
        else if reviewedVocabIdDateDict.keys.contains(vocab.VocabRecId) && isExactSeqMemory(vocab: vocab){
            if let date = reviewedVocabIdDateDict[vocab.VocabRecId] {
                datesWithSequentialMemorized.append(date)
            }
        }
    }
    
    var cumMastered:[Int] = []
    for di in 0..<dates.count{
        cumMastered.append(0)
        for vocab in masteredVocabs{
            if Calendar.current.isDate(vocab.LearnDate ?? Date(), inSameDayAs: dates[di]){
                cumMastered[di] += 1
            }
        }
        
        for dateWithMem in datesWithSequentialMemorized{
            if Calendar.current.isDate(dateWithMem, inSameDayAs: dates[di]){
                cumMastered[di] += 1
            }
        }
        
        if di > 0{
            cumMastered[di] += cumMastered[di - 1]
        }
    }
    return cumMastered
}

func getCumulatedLearnedByDate(dates: [Date]) -> [Int]{
    var cumLearned:[Int] = []
    for di in 0..<dates.count{
        cumLearned.append(0)
        for lrec in GlobalLearningRecords{
            if Calendar.current.isDate(lrec.EndDate, inSameDayAs: dates[di]){
                cumLearned[di] += lrec.VocabRecIds.count
            }
        }
        if di > 0{
            cumLearned[di] += cumLearned[di - 1]
        }
    }
    return cumLearned
}


func getLearningRecordsOf(date: Date) -> [LearningRecord]{
    var learningRecords:[LearningRecord] = []
    for lrec in GlobalLearningRecords{
        if Calendar.current.isDate(lrec.EndDate, inSameDayAs: date){
            learningRecords.append(lrec)
        }
    }
    return learningRecords
}

func getReviewRecordsOf(date: Date) -> [ReviewRecord]{
    var reviewRecords:[ReviewRecord] = []
    for rrec in GlobalReviewRecords{
        if Calendar.current.isDate(rrec.EndDate, inSameDayAs: date){
            reviewRecords.append(rrec)
        }
    }
    return reviewRecords
}

func prepareRecordsAndPreference(completionHandler: @escaping CompletionHandler){
    loadPreference(completionHandler: completionHandler)
    GlobalVocabRecords = loadVocabRecords()
    GlobalReviewRecords = loadReviewRecords()
    GlobalLearningRecords = loadLearningRecords()
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

func getVocabRecordsByRecordIds(VocabRecordIds: [String]) -> [VocabularyRecord]{
    var VocabRecs:[VocabularyRecord] = []
    for vocabRecord in GlobalVocabRecords{
        if VocabRecordIds.contains(vocabRecord.VocabRecId){
            VocabRecs.append(vocabRecord)
        }
    }
    return VocabRecs
}

func clearVocabRecordsOfCurrentLearning(){
    vocabRecordsOfCurrentLearning = []
}

func loadVocabRecords() -> [VocabularyRecord] {
    var vocabRecords: [VocabularyRecord] =  []
    
    load_data_from_file(fileFp: vocabRecordJsonFp, recordClass: vocabRecordClass, IdKey: VocabRecordIdKey,  completionHandlerWithData: { data in
        do {
            if let data = data {
                vocabRecords = try decoder.decode([VocabularyRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
    
    
    return vocabRecords
}


func saveVocabRecords(saveToLocal: Bool, saveToCloud: Bool = false, random_new_word: Bool = false, delaySeconds:Double = 0, completionHandler: @escaping CompletionHandler){
    var ranks:[String:Int] = [:]
    for vi in 0..<GlobalVocabRecords.count{
        let vocab:VocabularyRecord = GlobalVocabRecords[vi]
        if let _ = ranks[vocab.VocabRecId]{
            ranks[vocab.VocabRecId]! += 1
        }else{
            
            ranks[vocab.VocabRecId] = 1
        }
    }
    let jsonData = try! JSONEncoder().encode(GlobalVocabRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: vocabRecordJsonFp){
        saveStringTo(fileName: vocabRecordJsonFp, jsonStr: jsonString)
    }
    if random_new_word{
        update_words()
    }
    if saveToCloud{
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            saveRecordStringToCloud(recordClass: vocabRecordClass, saveRecordFailedKey: saveVocabRecordToClouldFailedKey, recordIdKey: VocabRecordIdKey, username: GlobalUserName, jsonString: jsonString, completionHandler: completionHandler)
        }
    }
}

// MARK: - LearningRecord Util

func initNewLearningRec() -> LearningRecord{
    return LearningRecord.init(StartDate: Date(), EndDate: Date(), VocabRecIds: [])
}

func initNewReviewRec() -> ReviewRecord{
    return ReviewRecord.init(StartDate: Date(), EndDate: Date(), VocabRecIds: [])
}

func saveLearningRecordsFromLearning() {
    //Save learning records and vocabs after learning
    for i in 0..<vocabRecordsOfCurrentLearning.count{
        vocabRecordsOfCurrentLearning[i].LearnDate = Date()
    }
    GlobalVocabRecords.append(contentsOf: vocabRecordsOfCurrentLearning)
    saveVocabRecords(saveToLocal: true, completionHandler: {_ in })
    
    GlobalLearningRecords.append(currentLearningRec)
    saveLearningRecords(saveToLocal: true, completionHandler: {_ in })
}

func updateGlobalVocabRecords(vocabs_updated: [VocabularyRecord]){
    var vocab_new_ids:[String] = []
    for vocab in vocabs_updated{
        vocab_new_ids.append(vocab.VocabRecId)
    }
    var temp_GlobalVocabRec:[VocabularyRecord] = []
    for vi in 0..<GlobalVocabRecords.count{
        let vocab:VocabularyRecord = GlobalVocabRecords[vi]
        if !vocab_new_ids.contains(vocab.VocabRecId){
            temp_GlobalVocabRec.append(vocab)
        }
    }
    
    for vocab in vocabs_updated{
        temp_GlobalVocabRec.append(vocab)
    }
    GlobalVocabRecords = temp_GlobalVocabRec
}

func saveReviewRecordsFromReview(vocabs_updated: [VocabularyRecord]) {
    //Save review records and vocabs after review
    updateGlobalVocabRecords(vocabs_updated: vocabs_updated)
    saveVocabRecords(saveToLocal: true, completionHandler: {_ in })
    
    GlobalReviewRecords.append(currentReviewRec)
    saveReviewRecords(saveToLocal: true, completionHandler: {_ in })
}



func loadLearningRecords() -> [LearningRecord]{
    var learningRecord: [LearningRecord] =  []
    load_data_from_file(fileFp: learningRecordJsonFp, recordClass: learningRecordClass, IdKey: LearningRecordIdKey,  completionHandlerWithData: { data in
        do {
            if let data = data {
                learningRecord = try decoder.decode([LearningRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
    return learningRecord
}

func saveLearningRecords(saveToLocal: Bool, saveToCloud: Bool = false, delaySeconds:Double = 0, completionHandler: @escaping CompletionHandler){
    let jsonData = try! JSONEncoder().encode(GlobalLearningRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: learningRecordJsonFp){
        saveStringTo(fileName: learningRecordJsonFp, jsonStr: jsonString)
    }
    if saveToCloud{
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            saveRecordStringToCloud(recordClass: learningRecordClass, saveRecordFailedKey: saveLearningRecordToClouldFailedKey, recordIdKey: LearningRecordIdKey, username: GlobalUserName, jsonString: jsonString, completionHandler: completionHandler)
        }
    }
}


// MARK: - ReviewRecord Util
func loadReviewRecords() -> [ReviewRecord]{
    var reviewRecords: [ReviewRecord] =  []
    
    load_data_from_file(fileFp: reviewRecordJsonFp, recordClass: reviewRecordClass, IdKey: DefaultPrefIdKey,  completionHandlerWithData: { data in
        do {
            if let data = data {
                reviewRecords = try decoder.decode([ReviewRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
    return reviewRecords
}

func saveReviewRecords(saveToLocal: Bool, saveToCloud: Bool = false, delaySeconds:Double = 0, completionHandler: @escaping CompletionHandler){
    let jsonData = try! JSONEncoder().encode(GlobalReviewRecords)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    if saveToLocal || !fileExist(fileFp: reviewRecordJsonFp){
        saveStringTo(fileName: reviewRecordJsonFp, jsonStr: jsonString)
    }
    if saveToCloud{
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            saveRecordStringToCloud(recordClass: reviewRecordClass, saveRecordFailedKey: saveReviewRecordToClouldFailedKey, recordIdKey: ReviewRecordIdKey, username: GlobalUserName, jsonString: jsonString, completionHandler: completionHandler)
        }
    }
}

