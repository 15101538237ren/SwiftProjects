//
//  UtilFunc.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import UIKit
import SwiftyJSON

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
