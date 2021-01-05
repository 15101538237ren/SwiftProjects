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
var vocabRecordsOfCurrentLearning:[VocabularyRecord] = []
var vocabRecordsOfCurrentReview:[VocabularyRecord] = []
var currentLearningRec: LearningRecord = initNewLearningRec()
var currentReviewRec: ReviewRecord = initNewReviewRec()

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


func saveReviewRecordsFromReview(vocabs_updated: [VocabularyRecord]) {
    //Save review records and vocabs after review
    updateGlobalVocabRecords(vocabs_updated: vocabs_updated)
    saveVocabRecords(saveToLocal: true, completionHandler: {_ in })
    
    GlobalReviewRecords.append(currentReviewRec)
    saveReviewRecords(saveToLocal: true, completionHandler: {_ in })
}

