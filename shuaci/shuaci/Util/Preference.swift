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
let preferenceJsonFp = "userPreference.json"
let savePrefToClouldFailedKey = "savePrefToClouldFailed"
var savePrefToClouldFailed : Bool = getSavePrefToClouldStatus()

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

// MARK: - Preference

func syncPrefToCloud(){
    if savePrefToClouldFailed{
        loadPreference()
        savePreferenceToClould()
    }
}

func initPreference(){
    USER_PREFERENCE = ["number_of_words_per_group" : 20,
    "current_book_id" : "",
    "auto_pronunciation" : true,
    "us_pronunciation" : true,
    "current_theme_category" : 1,
    "reminder_time": nil
    ]
}

func getPreference(key: String) -> Any? {
    if USER_PREFERENCE.count == 0{
        loadPreference()
    }
    return USER_PREFERENCE[key]
}

func setPreference(key: String, value: Any) {
    USER_PREFERENCE[key] = value
    savePreference()
}

func encodePreferenceToStr() -> String{
    do {
        let jsonData = try? JSONSerialization.data(withJSONObject: USER_PREFERENCE, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString ?? ""
    } catch {
        print(error.localizedDescription)
    }
    return ""
}

func decodePreferenceFromStr(prefStr: String) -> [String: Any]{
    if let data = prefStr.data(using: .utf8) {
        do {
            return try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
        } catch {
            print(error.localizedDescription)
        }
    }
    return [:]
}

func savePreference(){
    do {
        let jsonString = encodePreferenceToStr()
        saveStringTo(fileName: preferenceJsonFp, jsonStr: jsonString)
        print("Save Preference Sucessful!")
        savePreferenceToClould()
    } catch {
        print(error.localizedDescription)
    }
}

func loadPreference(){
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(preferenceJsonFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            USER_PREFERENCE = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
        }
        else{
            if Reachability.isConnectedToNetwork(){
               DispatchQueue.global(qos: .background).async {
                do {
                    let user = LCApplication.default.currentUser!
                    if let prefId = user.get(DefaultPrefIdKey)?.stringValue{
                        do {
                            let userPreferenceQuery = LCQuery(className: "UserPreference")
                            let _ = userPreferenceQuery.get(prefId) { (result) in
                                switch result {
                                case .success(object: let pref):
                                    // todo 就是 objectId 为 582570f38ac247004f39c24b 的 Todo 实例
                                    let prefStr:String = pref.get("Preference")!.stringValue!
                                    USER_PREFERENCE = decodePreferenceFromStr(prefStr: prefStr)
                                case .failure(error: let error):
                                    print(error)
                                }
                            }
                        }
                    }else{
                        initPreference()
                    }
                }
            }
        }
        }
    } catch {
        print(error.localizedDescription)
    }
}

func savePreferenceToClould(){
    if Reachability.isConnectedToNetwork(){
       DispatchQueue.global(qos: .background).async {
       do {
           var prefId = ""
           let preferenceStr = encodePreferenceToStr()
           // Construct Obj
            if isKeyPresentInUserDefaults(key: DefaultPrefIdKey){
                prefId = UserDefaults.standard.string(forKey: DefaultPrefIdKey)!
            }
            else{
                let user = LCApplication.default.currentUser!
                if let username = user.get("username"){
                    do {
                        
                        if let preferenceIdFromCloud = user.get(DefaultPrefIdKey)?.stringValue{
                            UserDefaults.standard.set(preferenceIdFromCloud, forKey: DefaultPrefIdKey)
                            prefId = preferenceIdFromCloud
                        }
                        else{
                            let UserPreferenceObj = LCObject(className: "UserPreference")

                            try UserPreferenceObj.set("username", value: username)
                            try UserPreferenceObj.set("Preference", value: preferenceStr)

                            _ = UserPreferenceObj.save { result in
                                switch result {
                                case .success:
                                    let preferenceIdFromCloud: String = UserPreferenceObj.objectId?.stringValue! ?? ""
                                    if preferenceIdFromCloud != "" {
                                        do {
                                           try user.set(DefaultPrefIdKey, value: preferenceIdFromCloud)
                                            user.save { (result) in
                                                switch result {
                                                case .success:
                                                    print("UserPreferenceObj saved successfully ")
                                                    break
                                                case .failure(error: let error):
                                                    setSavePrefToClouldStatus(status: false)
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        } catch {
                                            print(error)
                                        }
                                        UserDefaults.standard.set(preferenceIdFromCloud, forKey: DefaultPrefIdKey)
                                        prefId = preferenceIdFromCloud
                                    }
                                    break
                                case .failure(error: let error):
                                    setSavePrefToClouldStatus(status: false)
                                    print(error)
                                }
                            }
                        }
                    } catch {
                        print(error)
                        }
                }
                
                
            }
        
           
       } catch {
           print(error.localizedDescription)
           }}
    }
}

// MARK: - SavePrefToClouldStatus

func getSavePrefToClouldStatus() -> Bool{
    if isKeyPresentInUserDefaults(key: savePrefToClouldFailedKey){
        return UserDefaults.standard.bool(forKey: savePrefToClouldFailedKey)
    }
    else{
        UserDefaults.standard.set(false, forKey: savePrefToClouldFailedKey)
        return false
    }
}

func setSavePrefToClouldStatus(status: Bool){
    UserDefaults.standard.set(status, forKey: savePrefToClouldFailedKey)
}
