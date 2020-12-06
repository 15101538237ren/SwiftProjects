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
import CropViewController

func statusColor(status: Int) -> UIColor{
    switch status {
    case 0:
        return .white
    case 1:
        return .systemGreen
    case 2:
        return .systemRed
    case 3:
        return .systemOrange
    case 4:
        return .systemBlue
    case 5:
        return .systemYellow
    default:
        return .systemYellow
    }
}

func getUserLikedWPs(){
    if let currentUser = LCApplication.default.currentUser{
        let user = LCObject(className: "_User", objectId: currentUser.objectId!)
        _ = user.fetch { result in
            switch result {
            case .success:
                if let likedWPs = user.get("likedWPs")?.arrayValue{
                    userLikedWPs = []
                    for likedWP in likedWPs{
                        userLikedWPs.append(likedWP as! String)
                    }
                }
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    } else {
        if let storedLikedWPs = UserDefaults.standard.object(forKey: "likedWPs") as? [String]{
            userLikedWPs = storedLikedWPs
        }
    }
}

func dateFromString(dateStr: String) -> NSDate {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let newDate = dateFormatter.date(from: dateStr)! as NSDate
    return newDate
}

func fromLCDateToDateStr(date: LCDate) -> String{
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let dateStr = dateFormat.string(from: date.dateValue!)
    return dateStr
}

func createCropViewController(image: UIImage) -> CropViewController{
    let cropController = CropViewController(image: image)
    var width: CGFloat = image.size.width * image.scale
    var height: CGFloat = image.size.height * image.scale
    let ratio: CGFloat = width/height
    
    if (ratio > whRatio){
        width = height * whRatio
    }else{
        height = width / whRatio
    }
    
    let leftPosition = (image.size.width * image.scale - width)/2.0
    let topPosition = (image.size.height * image.scale - height)/2.0
    
    cropController.title = "「缩放」或「拖拽」来调整"
    cropController.doneButtonTitle = "确定"
    cropController.cancelButtonTitle = "取消"
    cropController.imageCropFrame = CGRect(x: leftPosition, y: topPosition, width: width, height: height)
    cropController.rotateButtonsHidden = true
    cropController.rotateClockwiseButtonHidden = true
    cropController.resetButtonHidden = true
    cropController.aspectRatioLockEnabled = true
    cropController.resetAspectRatioEnabled = false
    cropController.aspectRatioPickerButtonHidden = true
    return cropController
}

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
        
        categoryENtoCN = [:]
        for category in categories{
            categoryENtoCN[category.eng] = category.name
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
                    
                    categoryENtoCN = [:]
                    for category in categories{
                        categoryENtoCN[category.eng] = category.name
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

func initProgressBar(in view:UIView){
    hudWithProgress.vibrancyEnabled = true
    hudWithProgress.progress = 0
    if arc4random_uniform(2) == 0 {
        hudWithProgress.indicatorView = JGProgressHUDPieIndicatorView()
    }
    else {
        hudWithProgress.indicatorView = JGProgressHUDRingIndicatorView()
    }
    hudWithProgress.show(in: view)
}

func showProgressBar(progress: Double,text: String, in view: UIView) {
    if !progressBarVisible{
        initProgressBar(in: view)
        progressBarVisible.toggle()
    }
    if fabs(progress - 100.0) < Double.ulpOfOne {
        UIView.animate(withDuration: 0.1, animations: {
            hudWithProgress.detailTextLabel.text = nil
            hudWithProgress.indicatorView = JGProgressHUDSuccessIndicatorView()
        })
        
        hudWithProgress.dismiss(animated: true)
    }else{
        hudWithProgress.detailTextLabel.text = String(format: "%.0d%%", progress)
        hudWithProgress.textLabel.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            showProgressBar(progress: progress, text: text, in: view)
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
            print("load \(fileName) successful!")
            return json
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
