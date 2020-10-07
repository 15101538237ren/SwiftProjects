//
//  GlobalMethods.swift
//  Blackpink
//
//  Created by Honglei on 10/4/20.
//

import Foundation
import CloudKit
import UIKit


func getAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
}

func presentNoNetworkAlert() -> UIAlertController{
    return getAlert(title: "No Network", message: "No network, please check your connection!", okText: "OK")
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
            if rec_id != ""
            {
                recordIds.append(rec_id)
            }
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

func getCategoryByIntValue(category: Int) -> WallpaperCategory{
    switch category {
        case WallpaperCategory.Group.rawValue:
            return WallpaperCategory.Group
        case WallpaperCategory.Lisa.rawValue:
            return WallpaperCategory.Lisa
        case WallpaperCategory.Jisoo.rawValue:
            return WallpaperCategory.Jisoo
        case WallpaperCategory.Rose.rawValue:
            return WallpaperCategory.Rose
        case WallpaperCategory.Jennie.rawValue:
            return WallpaperCategory.Jennie
    default:
        return WallpaperCategory.Group
    }
}

func getTransitionFromRight() -> CATransition{
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromRight
    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
    return transition
}

func convertIntToCategory(categoryInt: Int)-> WallpaperCategory{
    switch categoryInt {
    case 1:
        return .Group
    case 2:
        return .Lisa
    case 3:
        return .Jisoo
    case 4:
        return .Rose
    case 5:
        return .Jennie
    default:
        return .Group
    }
}

func getSoloImageNameByCategory(category: WallpaperCategory) -> String{
    var imageName = ""
    switch category {
        case .Lisa:
            imageName =  "lisa"
        case .Jisoo:
            imageName =  "jisoo"
        case .Rose:
            imageName =  "rose"
        case .Jennie:
            imageName =  "jennie"
        case .Group:
            imageName = "group"
    }
    return imageName
}
