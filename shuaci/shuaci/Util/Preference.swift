//
//  Preference.swift
//  shuaci
//
//  Created by Honglei on 6/10/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

var USER_PREFERENCE: [String : Any?] = [:]
let preferenceJsonFp = "userPreference.json"

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
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
    return USER_PREFERENCE[key]
}

func setPreference(key: String, value: Any) {
    USER_PREFERENCE[key] = value
}

func savePreferenceLocally(){
    do {
        let jsonData = try? JSONSerialization.data(withJSONObject: USER_PREFERENCE, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        saveStringTo(fileName: preferenceJsonFp, jsonStr: jsonString!)
        print("Save Preference Sucessful!")
    } catch {
        print(error.localizedDescription)
    }
}

func loadPreferenceLocally(){
    do {
        let fileURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(preferenceJsonFp)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            USER_PREFERENCE = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
            
        }
    } catch {
        print(error.localizedDescription)
    }
}
