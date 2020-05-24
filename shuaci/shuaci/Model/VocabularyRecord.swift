//
//  VocabularyRecord.swift
//  shuaci
//
//  Created by 任红雷 on 5/17/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct VocabularyRecord: Codable {
    var VocabRecId: String
    var BookId:String
    var WordRank: Int
    var LearnDates: [Date]
    var ReviewDates: [Date]
    var MasteredDate: Date
    var RememberDates: [Date]
    var ForgetDates: [Date]
    var CollectDates: [Date]
    var ReviewDUEDates: [Date]
    init(VocabRecId: String, BookId: String, WordRank: Int, LearnDates: [Date], ReviewDates: [Date], MasteredDate: Date, RememberDates: [Date], ForgetDates: [Date], CollectDates: [Date], ReviewDUEDates :[Date] ) {
        
        self.VocabRecId = VocabRecId
        self.BookId = BookId
        self.WordRank = WordRank
        self.LearnDates = LearnDates
        self.ReviewDates = ReviewDates
        self.MasteredDate = MasteredDate
        self.RememberDates  = RememberDates
        self.ForgetDates = ForgetDates
        self.CollectDates = CollectDates
        self.ReviewDUEDates = ReviewDUEDates
    }
}
