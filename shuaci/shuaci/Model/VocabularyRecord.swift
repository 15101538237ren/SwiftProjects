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
    var MasteredDates: Date
    var RememberDates: [Date]
    var ForgetDates: [Date]
    var CollectDates: [Date]
}
