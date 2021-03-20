//
//  VocabularyRecord.swift
//  shuaci
//
//  Created by 任红雷 on 5/17/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct VocabularyRecord: Codable {
    var VocabHead: String
    var BookId:String
    var Mastered: Bool
    var NumOfReview: Int
    var BehaviorHistory: [Int]
    var BehaviorDates: [Date]
    var LearnDate: Date?
    var CollectDate: Date?
    var MasteredDate: Date?
    var ReviewDUEDate: Date?
    
    init(VocabHead: String, BookId: String, LearnDate: Date?, CollectDate: Date?, NumOfReview:Int = 0, Mastered: Bool, MasteredDate: Date?, ReviewDUEDate: Date?, BehaviorHistory: [CardBehavior], BehaviorDates: [Date]) {
        self.VocabHead = VocabHead
        self.BookId = BookId
        self.LearnDate = LearnDate
        self.CollectDate = CollectDate
        self.NumOfReview = NumOfReview
        self.Mastered = Mastered
        self.MasteredDate = MasteredDate
        self.ReviewDUEDate = ReviewDUEDate
        var rawBehaviorHistory:[Int] = []
        for cardBehavior in BehaviorHistory{
            rawBehaviorHistory.append(cardBehavior.rawValue)
        }
        self.BehaviorHistory = rawBehaviorHistory
        self.BehaviorDates = BehaviorDates
    }
}
