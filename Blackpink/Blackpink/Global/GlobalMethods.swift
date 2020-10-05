//
//  GlobalMethods.swift
//  Blackpink
//
//  Created by Honglei on 10/4/20.
//

import Foundation
import CloudKit
import UIKit


func presentAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
}

func presentNoNetworkAlert() -> UIAlertController{
    return presentAlert(title: "No Network", message: "No network, please check your connection!", okText: "OK")
}

func isKeyInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func getLikedRecordIds() -> [String] {
    if isKeyInUserDefaults(key: likeIdsKey){
        let idString = UserDefaults.standard.string(forKey: likeIdsKey)!
        let rec_ids = idString.components(separatedBy: separator)
        var recordIds:[String] = []
        for rec_id in rec_ids{
            recordIds.append(rec_id)
        }
        return recordIds
    }else{
        return []
    }
}

func saveLikedRecordIds(recordIds : [String]){
    let joinedIdsStr = recordIds.joined(separator: separator)
    UserDefaults.standard.set(joinedIdsStr, forKey: likeIdsKey)
//    print("Saved liked record successful!")
}

func addLikedRecordId(recordName : String){
    var recordIds:[String] = getLikedRecordIds()
    recordIds.append(recordName)
    saveLikedRecordIds(recordIds: recordIds)
}

func removeLikedRecordId(recordName: String) {
    let recordIds:[String] = getLikedRecordIds()
    var newRecordIds:[String] = []
    for recId in recordIds{
        if recId != recordName {
            newRecordIds.append(recId)
        }
    }
    saveLikedRecordIds(recordIds: newRecordIds)
}
