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
    var LearnDate: Date?
    var CollectDate: Date?
    var Mastered: Bool
    var MasteredDate: Date?
    var ReviewDUEDate: Date?
    var BehaviorHistory: [Int]
    init(VocabHead: String, BookId: String, WordRank: Int, LearnDate: Date?, CollectDate: Date?, Mastered: Bool, MasteredDate: Date?, ReviewDUEDate: Date?, BehaviorHistory: [CardBehavior]) {
        self.VocabHead = VocabHead
        self.BookId = BookId
        self.LearnDate = LearnDate
        self.CollectDate = CollectDate
        self.Mastered = Mastered
        self.MasteredDate = MasteredDate
        self.ReviewDUEDate = ReviewDUEDate
        var rawBehaviorHistory:[Int] = []
        for cardBehavior in BehaviorHistory{
            rawBehaviorHistory.append(cardBehavior.rawValue)
        }
        self.BehaviorHistory = rawBehaviorHistory
    }
}
