//
//  GlobalEnum.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/2.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation

enum RecordType: Int {
    case Learn = 1
    case Review = 2
}

func getRecordTypeFromValue(value: Int) -> RecordType{
    if value == 1{
        return .Learn
    }else{
        return .Review
    }
}
