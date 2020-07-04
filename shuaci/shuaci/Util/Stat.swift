//
//  Stat.swift
//  shuaci
//
//  Created by Honglei on 7/4/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

func getNumOfVocabLearnOrReviewToday() -> Int{
    let today = Date()
    let todayLearnRec = getLearningRecordsOf(date: today)
    let todayReviewRec = getLearningRecordsOf(date: today)
    
}
