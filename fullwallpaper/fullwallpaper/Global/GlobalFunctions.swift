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
import SwiftTheme
import SwiftyStoreKit

// MARK: - VIP Util

func getTodayDefaultKey() -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY_MM_dd"
    let today_str:String = dateFormatter.string(from: date)
    return today_str
}

func getProductIds() -> [String]{
    return [RegisteredPurchase.OneMonthVIP.rawValue, RegisteredPurchase.YearVIP.rawValue, RegisteredPurchase.ThreeMonthVIP.rawValue]
}

func checkIfVIPSubsciptionValid(successCompletion: @escaping Completion, failedCompletion: @escaping FailedVerifySubscriptionHandler){
    
    if let reason = failedReason{
        switch reason {
        case .success:
            successCompletion()
        default:
            failedCompletion(reason)
        }
        return
    }
    
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
    
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
        switch result {
        case .success(let receipt):
            var availableForFreeTrial:Bool = true
            let latest_receipt_infos:[JSON] = JSON(receipt)["latest_receipt_info"].arrayValue
            
            for receipt_info in latest_receipt_infos{
                if JSON(receipt_info)["is_trial_period"].boolValue{
                    availableForFreeTrial = false
                }
            }
            if availableForFreeTrial{
                failedReason = .notPurchasedNewUser
                failedCompletion(.notPurchasedNewUser)
                return
            }
            
            let productKeys:[String] = [RegisteredPurchase.OneMonthVIP.rawValue, RegisteredPurchase.ThreeMonthVIP.rawValue, RegisteredPurchase.YearVIP.rawValue]
            var expired:Bool = false
            for productKey in productKeys{
                let productID:String = "com.fullwallpaper.\(productKey)"
                
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productID,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    failedReason = .success
                    successCompletion()
                    print(expiryDate)
                    expireDate = expiryDate
                    return
                case .expired(let expiryDate, let items):
                    expired = true
                    break
                case .notPurchased:
                    break
                }
            }
            if expired{
                failedReason = .expired
                failedCompletion(.expired)
            }else{
                failedReason = .notPurchasedOldUser
                failedCompletion(.notPurchasedOldUser)
            }
            
        case .error(let error):
            print("Receipt verification failed: \(error)")
            failedReason = .unknownError
            failedCompletion(.unknownError)
        }
    }
    
}


func checkIfEnglishEnv(){
    if let langStr = Locale.current.languageCode
    {
        if !langStr.contains("zh"){
            english = true
        }
    }
}

func loadURL(url: URL){
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

func blurImage(usingImage image:UIImage, blurAmount: CGFloat) -> UIImage? {
    guard let ciImage = CIImage(image: image) else {
        return nil
    }
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
    blurFilter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
    
    guard let outputImage = blurFilter?.outputImage else {
        return nil
    }
    
    let croppedImage = outputImage.cropped(to: ciImage.extent)
    
    return UIImage(ciImage: croppedImage)
}

func getSegmentedCtrlUnselectedTextColor() -> String{
    let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "SegmentedCtrlTextColor") as! String
    return viewBackgroundColor
}

func getBannedAlert() -> UIAlertController{
    let alertController = UIAlertController(title: accountBannedText, message: accountBannedDetailText, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: OkTxt, style: .default, handler: { action in
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        
        })
    alertController.addAction(okayAction)
    return alertController
}


func setTheme(theme: THEME = .system){
    if #available(iOS 13, *) {
        switch theme {
        case .day:
            ThemeManager.setTheme(plistName: THEME.day.rawValue, path: .mainBundle)
        case .night:
            ThemeManager.setTheme(plistName: THEME.night.rawValue, path: .mainBundle)
        case .system:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                ThemeManager.setTheme(plistName: THEME.night.rawValue, path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: THEME.day.rawValue, path: .mainBundle)
            }
        }
    } else {
        ThemeManager.setTheme(plistName: THEME.day.rawValue, path: .mainBundle)
    }
}

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

func createCropViewController(image: UIImage, widthHeightRatio:CGFloat = whRatio) -> CropViewController{
    let cropController = CropViewController(image: image)
    var width: CGFloat = image.size.width * image.scale
    var height: CGFloat = image.size.height * image.scale
    let ratio: CGFloat = width/height
    
    if (ratio > widthHeightRatio){
        width = height * widthHeightRatio
    }else{
        height = width / widthHeightRatio
    }
    
    let leftPosition = (image.size.width * image.scale - width)/2.0
    let topPosition = (image.size.height * image.scale - height)/2.0
    
    cropController.title = zoomOrDragText
    cropController.doneButtonTitle = ensureText
    cropController.cancelButtonTitle = cancelText
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
            let pro = json_obj["pro"].boolValue
            let category = Category(name: name, eng: eng, coverUrl: coverUrl, pro: pro)
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
                        let pro = res.get("pro")?.boolValue ?? false
                        
                        if let file = res.get("cover") as? LCFile {
                            let category = Category(name: name, eng: eng, coverUrl: file.url!.stringValue!, pro: pro)
                            categories.append(category)
                        }
                    }
                    
                    categoryENtoCN = [:]
                    for category in categories{
                        categoryENtoCN[category.eng] = category.name
                    }
                    
                    encodeSaveJson()
                    DispatchQueue.main.async {
                        completion()
                    }
                    
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


func makeProductId(purchase: RegisteredPurchase)-> String{
    return "com.fullwallpaper.\(purchase.rawValue)"
}

func getTimeInterval(product: RegisteredPurchase) -> TimeInterval{
    switch product {
    case .OneMonthVIP:
        return 3600 * 24 * 30
    case .YearVIP:
        return 3600 * 24 * 365
    case .ThreeMonthVIP:
        return 3600 * 24 * 90
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
    hud.textLabel.text = loadingText
    hud.textLabel.theme_textColor = "IndicatorColor"
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

func getProductIDs() -> [String] {
    guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return []}
    
    do{
        let data = try Data(contentsOf: url)
        
        let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
        
        return productIDs
        
    } catch {
        print(error.localizedDescription)
        return []
    }
}
