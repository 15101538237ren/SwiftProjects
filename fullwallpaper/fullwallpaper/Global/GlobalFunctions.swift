//
//  UtilFunc.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import UIKit
import SwiftyJSON
import JGProgressHUD
import LeanCloud

func loadCategoryFromLocal(completion: @escaping () -> Void){
    if let json_objects = loadJson(fileName: categoryJsonFileName){
        categories = []
        let json_arr = json_objects.arrayValue
        for json_obj in json_arr{
            let coverUrl = json_obj["coverUrl"].stringValue
            let name = json_obj["name"].stringValue
            let eng = json_obj["eng"].stringValue
            let category = Category(name: name, eng: eng, coverUrl: coverUrl)
            categories.append(category)
        }
        completion()
    }
}

func encodeSaveJson(){
    do {
        let jsonData: Data = try JSONEncoder().encode(categories)
        if let jsonString = String(data: jsonData, encoding: .utf8){
            saveStringTo(cacheType: .json, fileName: categoryJsonFileName, jsonStr: jsonString)
        }else{
            print("Error in Saving json, Nil Json String!")
        }
    }catch {
        print(error.localizedDescription)
    }
    
}

func loadCategories(completion: @escaping () -> Void)
{
    
    loadCategoryFromLocal(completion: completion)
    
    if !Reachability.isConnectedToNetwork(){
        completion()
        return
    }
    
    DispatchQueue.global(qos: .utility).async {
    do {
        let query = LCQuery(className: "Category")
        let updated_count = query.count()
        print("Fetched \(updated_count.intValue) categories")
        if categories.count != updated_count.intValue{
            _ = query.find() { result in
                switch result {
                case .success(objects: let results):
                    categories = []
                    for rid in 0..<results.count{
                        let res = results[rid]
                        let name = res.get("name")?.stringValue ?? ""
                        let eng = res.get("eng")?.stringValue ?? ""
                        
                        if let file = res.get("cover") as? LCFile {
                            let category = Category(name: name, eng: eng, coverUrl: file.url!.stringValue!)
                            categories.append(category)
                        }
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
    
                    encodeSaveJson()
                    
                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }else{
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    }
}

func initIndicator(view: UIView){
    hud.textLabel.text = "加载中"
    hud.textLabel.textColor = .darkGray
    hud.backgroundColor = .clear
    hud.show(in: view)
}

func stopIndicator(){
    hud.dismiss()
}

func getNextDisplayMode(mode: DisplayMode) -> DisplayMode{
    switch mode {
    case .Plain:
        return .LockScreen
    case .LockScreen:
        return .HomeScreen
    case .HomeScreen:
        return .Plain
    }
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

    //get both times sinces refrenced date and divide by 60 to get minutes
    let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
    let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

    //then return the difference
    return CGFloat(newDateMinutes - oldDateMinutes)
}

func presentAlert(title: String, message: String, okText: String) -> UIAlertController{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    return alertController
}

func presentNoNetworkAlert() -> UIAlertController{
    return presentAlert(title: NoNetWorkStr, message: "", okText: OkTxt)
}

func getCacheDirName(cacheType: CacheType) -> String{
    switch cacheType {
    case .image:
        return "Image"
    case .json:
        return "Json"
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


func saveStringTo(cacheType: CacheType, fileName: String, jsonStr: String){
    let cacheDir = getCacheDirName(cacheType: cacheType)
    
    if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first {
        let cacheDirUrl = documentDirectory.appendingPathComponent(cacheDir, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: cacheDirUrl, withIntermediateDirectories: true)
            let pathWithFilename = documentDirectory.appendingPathComponent(cacheDir, isDirectory: true).appendingPathComponent(fileName)
            try jsonStr.write(to: pathWithFilename, atomically: true, encoding: String.Encoding.utf8)
            print("write \(fileName) successful!")
        } catch {
            print(error.localizedDescription)
        }
    }
}

func loadJson(fileName: String) -> JSON?{
    
    let cacheDir = getCacheDirName(cacheType: .json)
    
    if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first {
        do {
            let pathWithFilename = documentDirectory.appendingPathComponent(cacheDir, isDirectory: true).appendingPathComponent(fileName)
            let data = try Data(contentsOf: pathWithFilename, options: .mappedIfSafe)
            let json = try JSON(data: data)
            print("load \(fileName).json successful!")
            return json
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
