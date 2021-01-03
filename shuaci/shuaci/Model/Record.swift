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
    var recordType: RecordType
    var startDate: Date
    var endDate: Date
    var vocabRecords: [VocabularyRecord]
    
    init(uuid: String, recordType: RecordType, startDate: Date, endDate:Date, vocabRecords: [VocabularyRecord]) {
        self.uuid = uuid
        self.recordType = recordType
        self.startDate = startDate
        self.endDate = endDate
        self.vocabRecords = vocabRecords
    }
}
