//
//  FunctionUtil.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud
import SwiftyJSON
import Disk

// MARK: - Global Variables




func obtainNextReviewDate() -> Date?{
    if GlobalVocabRecords.count == 0{
        loadVocabRecords()
    }
    if GlobalVocabRecords.count > 0{
        var vocabsNeedReview:[VocabularyRecord] = []
        for vocabRecord in GlobalVocabRecords{
            if !vocabRecord.Mastered{
                vocabsNeedReview.append(vocabRecord)
            }
        }
        if vocabsNeedReview.count > 0{
            let vocabsNeedReviewSorted:[VocabularyRecord] = vocabsNeedReview.sorted(by: {$0.ReviewDUEDate!.compare($1.ReviewDUEDate!) == .orderedAscending})
            
            let number_of_vocabs_per_group = getPreference(key: "number_of_words_per_group") as! Int
            let number_of_vocabs_to_notify = min(number_of_vocabs_per_group, vocabsNeedReviewSorted.count)
            let notification_date: Date = vocabsNeedReviewSorted[number_of_vocabs_to_notify - 1].ReviewDUEDate!
            return notification_date
        }
    }
    return nil
}

func load_data_from_file(fileFp: String, recordClass: String, IdKey: String, completionHandlerWithData: @escaping CompletionHandlerWithData) {
    var data:Data? = nil
    do {
        let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(fileFp)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                data = try Data(contentsOf: fileURL)
                completionHandlerWithData(data, false)
            }
            else{
                let connected = Reachability.isConnectedToNetwork()
                if connected{
                    if let user = LCApplication.default.currentUser{
                        if let recId = user.get(IdKey)?.stringValue{
                            do {
                                if recId != ""{
                                    print("\(recordClass), id:\(recId)")
                                    let recordQuery = LCQuery(className: recordClass)
                                    let _ = recordQuery.get(recId) { (result) in
                                        switch result {
                                        case .success(object: let rec):
                                            let recStr:String = rec.get("jsonStr")!.stringValue!
                                            saveStringTo(fileName: fileFp, jsonStr: recStr)
                                            data = recStr.data(using: .utf8)
                                            completionHandlerWithData(data, true)
                                        case .failure(error: let error):
                                            completionHandlerWithData(data, false)
                                            print(error.localizedDescription)
                                        }
                                    }
                                }else{
                                    completionHandlerWithData(data, false)
                                }
                                
                            }
                        } else {
                            completionHandlerWithData(data, false)
                        }
                    } else{
                        completionHandlerWithData(data, false)
                    }
                    
                }
                else{
                    completionHandlerWithData(data, false)
                }
        }
    }
    catch {
        completionHandlerWithData(data, false)
        print(error.localizedDescription)
    }
}

