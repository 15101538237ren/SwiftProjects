//
//  ReviewRecord.swift
//  shuaci
//
//  Created by 任红雷 on 5/17/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct ReviewRecord: Codable {
    var StartDate: Date
    var EndDate: Date
    var VocabRecHeads: [String]
    
    init(StartDate: Date, EndDate:Date, VocabRecHeads: [String]) {
        self.StartDate = StartDate
        self.EndDate = EndDate
        self.VocabRecHeads = VocabRecHeads
    }
}
