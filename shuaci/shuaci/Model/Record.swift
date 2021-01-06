//
//  Record.swift
//  shuaci
//
//  Created by 任红雷 on 5/17/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct Record: Codable {
    var uuid: String
    var synced: Bool
    var recordType: Int
    var startDate: Date
    var endDate: Date
    var vocabHeads: [String]
    
    init(uuid: String, recordType: Int, startDate: Date, endDate:Date, vocabHeads: [String], synced: Bool=false) {
        self.uuid = uuid
        self.recordType = recordType
        self.startDate = startDate
        self.endDate = endDate
        self.vocabHeads = vocabHeads
        self.synced = synced
    }
}
