//
//  CollectedRecord.swift
//  shuaci
//
//  Created by 任红雷 on 5/17/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

struct CollectedRecord: Codable {
    var StartDate: Date
    var EndDate: Date
    var VocabRecIds: [String]
}
