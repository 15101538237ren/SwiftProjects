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
var GlobalReviewRecords:[ReviewRecord] = []
var GlobalVocabRecords:[VocabularyRecord] = []
var GlobalLearningRecords:[LearningRecord] = []


// MARK: - Overall Util

func getDatesLearned() -> [Date]{
    var datesLearned:[Date] = []
    for lrec in GlobalLearningRecords{
        datesLearned.append(lrec.EndDate)
    }
    return datesLearned
}

func getDatesReviewed() -> [Date]{
    var datesReviewed:[Date] = []
    for lrec in GlobalReviewRecords{
        datesReviewed.append(lrec.EndDate)
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


func getMinMaxDateOfVocabRecords() -> [Date]{
    var minDate = Date()
    for vocab in GlobalVocabRecords{
        if let learnDate = vocab.LearnDate {
            if learnDate < minDate{
                minDate = learnDate
            }
        }
    }
    return [minDate, Date()]
}

enum DateType {
    case learn
    case master
    case collect
}

func progressBarColor(progress: Float) -> UIColor{
    if progress > 0.8{
        return .systemGreen
    } else if progress > 0.4{
        return .systemBlue
    } else if progress > 0{
        return .systemOrange
    }else{
        return .lightGray
    }
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

func groupVocabRecByDate(dateType: DateType) -> [String : [VocabularyRecord]]{
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    switch dateType {
        case .learn:
            for vocab in GlobalVocabRecords {
                if vocab.LearnDate != nil && !vocab.Mastered{
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
            for vocab in GlobalVocabRecords {
                if vocab.MasteredDate != nil {
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
            for vocab in GlobalVocabRecords {
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
                formatter.dateFormat = "MM"
                let dateStr = formatter.string(from: date)
                categories.append(dateStr)
            }
        }
        
    }
    return categories
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

func getCumulatedMasteredByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true) -> [Int]{
    var reviewedVocabIdDateDict:[String: Date] = [:]
    for revRec in GlobalReviewRecords{
        for revId in revRec.VocabRecHeads{
            reviewedVocabIdDateDict[revId] = revRec.EndDate
        }
    }
    
    var masteredVocabs:[VocabularyRecord] = []
    var datesWithSequentialMemorized:[Date] = []
    for vocab in GlobalVocabRecords{
        if vocab.Mastered{
            masteredVocabs.append(vocab)
        }
        else if reviewedVocabIdDateDict.keys.contains(vocab.VocabHead) && isExactSeqMemory(vocab: vocab){
            if let date = reviewedVocabIdDateDict[vocab.VocabHead] {
                datesWithSequentialMemorized.append(date)
            }
        }
    }
    
    var cumMastered:[Int] = []
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



func getCumulatedLearnedByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true) -> [Int]{
    var cumLearned:[Int] = []
    for di in 0..<dates.count{
        cumLearned.append(0)
        for lrec in GlobalLearningRecords{
            if byDay{
                if Calendar.current.isDate(lrec.EndDate, inSameDayAs: dates[di]){
                    cumLearned[di] += lrec.VocabRecHeads.count
                }
            } else{
                if dates[di].isInSameMonth(as: lrec.EndDate){
                    cumLearned[di] += lrec.VocabRecHeads.count
                }
            }
            
        }
        if cumulated && di > 0{
            cumLearned[di] += cumLearned[di - 1]
        }
    }
    return cumLearned
}

func getCumHoursByDate(dates: [Date], byDay: Bool = true, cumulated: Bool = true, Learn: Bool = true) -> [Float]{
    var cumLearned:[Float] = []
    for di in 0..<dates.count{
        cumLearned.append(0)
        if Learn{
            for lrec in GlobalLearningRecords{
                if byDay{
                    if Calendar.current.isDate(lrec.EndDate, inSameDayAs: dates[di]){
                        let difference = Calendar.current.dateComponents([.second], from: lrec.StartDate, to: lrec.EndDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Float(secondT) / Float(60)
                        }
                    }
                } else{
                    if dates[di].isInSameMonth(as: lrec.EndDate){
                        let difference = Calendar.current.dateComponents([.second], from: lrec.StartDate, to: lrec.EndDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Float(secondT) / Float(60)
                        }
                    }
                }
                
            }
        }else{
            for rrec in GlobalReviewRecords{
                if byDay{
                    if Calendar.current.isDate(rrec.EndDate, inSameDayAs: dates[di]){
                        let difference = Calendar.current.dateComponents([.second], from: rrec.StartDate, to: rrec.EndDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Float(secondT) / Float(60)
                        }
                    }
                } else{
                    if dates[di].isInSameMonth(as: rrec.EndDate){
                        let difference = Calendar.current.dateComponents([.second], from: rrec.StartDate, to: rrec.EndDate)
                        if let secondT:Int = difference.second {
                            cumLearned[di] += Float(secondT) / Float(60)
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
    loadVocabRecords()
    loadReviewRecords()
    loadLearningRecords()
}

func getVocabHeadsFromVocabRecords(VocabRecords: [VocabularyRecord]) -> [String]{
    var VocabIds:[String] = []
    for VocabRecord in VocabRecords{
        VocabIds.append(VocabRecord.VocabHead)
    }
    return VocabIds
}

func clearVocabRecordsOfCurrentLearning(){
    vocabRecordsOfCurrentLearning = []
}

func loadVocabRecords(){
    load_data_from_file(fileFp: vocabRecordJsonFp, recordClass: vocabRecordClass, IdKey: VocabRecordIdKey,  completionHandlerWithData: { data, fromCloud in
        do {
            if let data = data {
                GlobalVocabRecords = try decoder.decode([VocabularyRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
}


func saveVocabRecords(saveToLocal: Bool, saveToCloud: Bool = false, random_new_word: Bool = false, delaySeconds:Double = 0, completionHandler: @escaping CompletionHandler){
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
    return LearningRecord.init(StartDate: Date(), EndDate: Date(), VocabRecHeads: [])
}

func initNewReviewRec() -> ReviewRecord{
    return ReviewRecord.init(StartDate: Date(), EndDate: Date(), VocabRecHeads: [])
}

func saveLearningRecordsFromLearning() {
    //Save learning records and vocabs after learning
    for i in 0..<vocabRecordsOfCurrentLearning.count{
        vocabRecordsOfCurrentLearning[i].LearnDate = Date()
        if vocabRecordsOfCurrentLearning[i].Mastered{
            vocabRecordsOfCurrentLearning[i].MasteredDate = Date()
        }
    }
    GlobalVocabRecords.append(contentsOf: vocabRecordsOfCurrentLearning)
    saveVocabRecords(saveToLocal: true, completionHandler: {_ in })
    
    GlobalLearningRecords.append(currentLearningRec)
    saveLearningRecords(saveToLocal: true, completionHandler: {_ in })
}

func updateGlobalVocabRecords(vocabs_updated: [VocabularyRecord]){
    var vocab_new_heads:[String] = []
    for vocab in vocabs_updated{
        vocab_new_heads.append(vocab.VocabHead)
    }
    var temp_GlobalVocabRec:[VocabularyRecord] = []
    for vi in 0..<GlobalVocabRecords.count{
        let vocab:VocabularyRecord = GlobalVocabRecords[vi]
        if !vocab_new_heads.contains(vocab.VocabHead){
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



func loadLearningRecords(){
    load_data_from_file(fileFp: learningRecordJsonFp, recordClass: learningRecordClass, IdKey: LearningRecordIdKey,  completionHandlerWithData: { data, fromCloud in
        do {
            if let data = data {
                GlobalLearningRecords = try decoder.decode([LearningRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
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
func loadReviewRecords(){
    load_data_from_file(fileFp: reviewRecordJsonFp, recordClass: reviewRecordClass, IdKey: ReviewRecordIdKey,  completionHandlerWithData: { data, fromCloud in
        do {
            if let data = data {
                GlobalReviewRecords = try decoder.decode([ReviewRecord].self, from: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    })
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

