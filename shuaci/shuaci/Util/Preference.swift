//
//  Preference.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import LeanCloud

var USER_PREFERENCE: [String : Any?] = [:]

let DefaultPrefIdKey = "PreferenceId"
let recordClass = "UserPreference"
let preferenceJsonFp = "userPreference.json"
let savePrefToClouldFailedKey = "savePrefToClouldFailed"
var savePrefToClouldFailed : Bool = getSaveRecordToClouldStatus(key: savePrefToClouldFailedKey)

// MARK: - Preference

func initPreference(){
    USER_PREFERENCE = ["number_of_words_per_group" : 20,
    "current_book_id" : nil,
    "auto_pronunciation" : true,
    "us_pronunciation" : true,
    "current_theme_category" : 1,
    "last_theme_category" : 1,
    "reminder_time": nil
    ]
}

func getPreference(key: String) -> Any? {
    if USER_PREFERENCE.count == 0{
        loadPreference()
    }
    return USER_PREFERENCE[key] ?? nil
}

func setPreference(key: String, value: Any, saveToCloud: Bool = true) {
    USER_PREFERENCE[key] = value
    savePreference(saveToLocal: true, saveToCloud: saveToCloud)
}

func encodePreferenceToStr() -> String{
    let jsonData = try? JSONSerialization.data(withJSONObject: USER_PREFERENCE, options: [])
    let jsonString = String(data: jsonData!, encoding: .utf8)
    return jsonString ?? ""
}

func savePreference(saveToLocal: Bool, saveToCloud: Bool = true){
    let jsonString = encodePreferenceToStr()
    if jsonString != ""{
        
        if saveToLocal{
            saveStringTo(fileName: preferenceJsonFp, jsonStr: jsonString)
        }
        
        saveRecordStringToCloud(recordClass: recordClass, saveRecordFailedKey: savePrefToClouldFailedKey, recordIdKey: DefaultPrefIdKey, username: GlobalUserName, jsonString: jsonString)
    }
    else{
        print("loaded empty preference")
    }
}

func loadPreference(){
    do {
        if let data = load_data_from_file(fileFp: preferenceJsonFp, recordClass: recordClass, IdKey: DefaultPrefIdKey){
            USER_PREFERENCE = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
        } else{
            initPreference()
        }
    } catch {
        print(error.localizedDescription)
    }
}
