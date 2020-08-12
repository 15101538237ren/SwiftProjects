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
    USER_PREFERENCE = [
    "number_of_words_per_group" : 20,
    "current_book_id" : nil,
    "auto_pronunciation" : true,
    "us_pronunciation" : true,
    "current_theme_category" : 1,
    "last_theme_category" : 1,
    "reminder_time": ""
    ]
}

func getPreference(key: String) -> Any? {
    if USER_PREFERENCE.count == 0{
        loadPreference(completionHandler: {_ in })
    }
    return USER_PREFERENCE[key] ?? nil
}

func setPreference(key: String, value: Any, saveToCloud: Bool = false) {
    USER_PREFERENCE[key] = value
    savePreference(saveToLocal: true, saveToCloud: saveToCloud, completionHandler: {_ in })
}

func encodePreferenceToStr() -> String{
    let jsonData = try? JSONSerialization.data(withJSONObject: USER_PREFERENCE, options: [])
    let jsonString = String(data: jsonData!, encoding: .utf8)
    return jsonString ?? ""
}

func savePreference(saveToLocal: Bool, saveToCloud: Bool = true, delaySeconds:Double = 0, completionHandler: @escaping CompletionHandler){
    let jsonString = encodePreferenceToStr()
    if jsonString != ""{
        if saveToLocal || !fileExist(fileFp: preferenceJsonFp){
            saveStringTo(fileName: preferenceJsonFp, jsonStr: jsonString)
        }
        if saveToCloud{
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
               saveRecordStringToCloud(recordClass: recordClass, saveRecordFailedKey: savePrefToClouldFailedKey, recordIdKey: DefaultPrefIdKey, username: GlobalUserName, jsonString: jsonString, completionHandler: completionHandler)
            }
        }
    }
    else{
        print("loaded empty preference")
    }
}

func loadPreference(completionHandler: @escaping CompletionHandler){
    load_data_from_file(fileFp: preferenceJsonFp, recordClass: recordClass, IdKey: DefaultPrefIdKey,  completionHandlerWithData: { data in
        do {
            if let data = data {
                var save_pref: Bool = false
                if USER_PREFERENCE.count == 0 {
                    save_pref = true
                }
                USER_PREFERENCE = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                if save_pref {
                    savePreference(saveToLocal: true, saveToCloud: false, completionHandler: {_ in })
                }
                
                } else{
                    initPreference()
                    savePreference(saveToLocal: true, saveToCloud: false, completionHandler: {_ in })
            }
            completionHandler(true)
        }
        catch {
            print(error.localizedDescription)
            completionHandler(false)
        }
        }
        
    )
}
