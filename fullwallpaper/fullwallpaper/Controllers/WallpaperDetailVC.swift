//
//  WallpaperDetailVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import AVFoundation
import Nuke
import Toast_Swift
import LeanCloud
import PopMenu
import SwiftTheme

class WallpaperDetailVC: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lockScreenPreviewImgV: UIImageView!{
        didSet{
            if Device.IS_5_5_INCHES(){
                lockScreenPreviewImgV.image = UIImage(named: "LockScreen_small")
            }
        }
    }
    @IBOutlet var homeScreenPreviewImgV: UIImageView!{
        didSet{
            if Device.IS_5_5_INCHES(){
                homeScreenPreviewImgV.image = UIImage(named: "HomeScreen_small")
            }
        }
    }
    @IBOutlet weak var downloadImgV: UIImageView!{
        didSet{
            downloadImgV.theme_tintColor = "CollectionCellTextColor"
        }
    }
    @IBOutlet weak var previewImgV: UIImageView!{
        didSet{
            previewImgV.theme_tintColor = "CollectionCellTextColor"
        }
    }
    @IBOutlet weak var optionImgV: UIImageView!{
        didSet{
            optionImgV.theme_tintColor = "CollectionCellTextColor"
        }
    }
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.layer.cornerRadius = 15.0
            dimUIView.layer.masksToBounds = true
            dimUIView.alpha = dimUIViewAlpha
            dimUIView.backgroundColor = .black
        }
    }
    
    @IBOutlet weak var imageDimUIView: UIView!{
        didSet{
            imageDimUIView.theme_alpha = "DimView.Alpha"
        }
    }
    
    
    // MARK: - Variables
    
    var imageUrl: URL!
    var wallpaperObjectId: String!
    var previewStatus: DisplayMode = .Plain
    var liked: Bool = false
    var isPro: Bool = false
    var viewTranslation = CGPoint(x: 0, y: 0)
    var reviewFuncCalled: Bool = false
    var reportClassification:[Int : String] = [2:badContentText, 3: lowResolutionText, 4: copyrightIssueText, 5: classificationErrorText]
    
    // MARK: - Constants
    let scaleForAnimation: CGFloat = 2
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfDisabled()
    }
    
    func checkIfDisabled(){
        stopIndicator()
        if isDisabled {
            DispatchQueue.main.async {
                let alertController:UIAlertController = getBannedAlert()
                self.present(alertController, animated: true, completion: nil)
            }
            return
        }else{
            loadImage(url: imageUrl)
            addGestureRcg()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !Reachability.isConnectedToNetwork(){
            self.imageView.image = UIImage(named: "image_to_upload")!
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    // MARK: - Custom Functions
    
    func loadImage(url: URL){
        if Reachability.isConnectedToNetwork(){
            initIndicator(view: self.view)
            print("Loading Image \(url)")
            _ = ImagePipeline.shared.loadImage(
                with: url,
                completion: { response in
                    stopIndicator()
                    switch response {
                      case .failure (let error):
                        print("Fail with \(error)")
                        self.imageView.image = ImageLoadingOptions.shared.failureImage
                        self.imageView.contentMode = .scaleAspectFit
                      case let .success(imageResponse):
                        print("Load Image Succesful!")
                        self.imageView.image = imageResponse.image
                      }
                }
            )
        }
    }
    
    func addGestureRcg(){
        addGestureRcgToView()
        addGestureRcgToDownload()
        addGestureRcgToPreview()
        addGestureRcgToOption()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            
            if viewTranslation.y > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    func hideButtons(){
        DispatchQueue.main.async {
            self.downloadImgV.alpha = 0
            self.previewImgV.alpha = 0
            self.optionImgV.alpha = 0
            self.dimUIView.alpha = 0
        }
    }
    
    
    func showButtons(){
        previewStatus = .Plain
        DispatchQueue.main.async {
            self.downloadImgV.alpha = 1
            self.previewImgV.alpha = 1
            self.optionImgV.alpha = 1
            self.dimUIView.alpha = dimUIViewAlpha
        }
    }
    
    func addGestureRcgToView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        switch previewStatus {
        case .Plain:
            hideButtons()
            showLockScreenPreview()
        case .LockScreen:
            hideLockScreenPreview()
            showHomeScreenPreview()
        case .HomeScreen:
            hideHomeScreenPreview()
            showButtons()
        }
    }
    
    func showVIPBenefitsVC(failedReason: FailedVerifyReason, showReason: ShowVIPPageReason) {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vipBenefitsVC = MainStoryBoard.instantiateViewController(withIdentifier: "vipBenefitsVC") as! VIPBenefitsVC
        vipBenefitsVC.FailedReason = failedReason
        vipBenefitsVC.ReasonForShowThisPage = showReason
        vipBenefitsVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(vipBenefitsVC, animated: true, completion: nil)
        }
    }
    
    func downloadImage() {
        // First, save the image to the photo album
        if let image = imageView.image {
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            stopIndicator()
            self.view.makeToast(downloadFailedPlsRetryText, duration: 1.0, position: .center)
            return // Exit early if there's no image to save
        }
        
        // Proceed with the statistics and other operations quietly
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let wallpaperQuery = LCQuery(className: "Wallpaper")
            
            wallpaperQuery.get(self.wallpaperObjectId) { result in
                switch result {
                case .success(object: let wallpaper):
                    self.handleWallpaperQuietly(wallpaper)
                case .failure(let error):
                    print("Failed to retrieve wallpaper: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func handleWallpaperQuietly(_ wallpaper: LCObject) {
        print("Handling wallpaper quietly. Wallpaper ID: \(wallpaper.objectId?.stringValue ?? "Unknown")")
        
        // Fetch the category associated with the wallpaper
        if let categoryName = wallpaper.get("category")?.stringValue {
            DispatchQueue.global(qos: .userInitiated).async {
                let categoryQuery = LCQuery(className: "Category")
                categoryQuery.whereKey("eng", .equalTo(categoryName))
                categoryQuery.getFirst { result in
                    switch result {
                    case .success(object: let category):
                        do {
                            try category.increase("popularity", by: 1)
                            DispatchQueue.global(qos: .userInitiated).async {
                                category.save { saveResult in
                                    if case .failure(let error) = saveResult {
                                        print("Failed to increase popularity for category: \(categoryName). Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        } catch {
                            print("Error while attempting to increase popularity for category: \(categoryName). Error: \(error.localizedDescription)")
                        }
                    case .failure(let error):
                        print("Failed to find category with name: \(categoryName). Error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("No category name found for wallpaper with objectId: \(wallpaper.objectId?.stringValue ?? "Unknown")")
        }
        
        // Increase the likes of the wallpaper quietly
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try wallpaper.increase("likes", by: 1)
                wallpaper.save { [weak self] result in
                    switch result {
                    case .success:
                        self?.updateUserLikedWallpapers(wallpaper: wallpaper)
                    case .failure(let error):
                        print("Failed to save wallpaper like increment. Error: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Failed to increment likes for wallpaper with ID: \(wallpaper.objectId?.stringValue ?? "Unknown"). Error: \(error.localizedDescription)")
            }
        }
    }

    private func updateUserLikedWallpapers(wallpaper: LCObject) {
        guard let user = LCApplication.default.currentUser else {
            return // Exit if no user is logged in
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try user.append("likedWPs", element: self.wallpaperObjectId!, unique: true)
                user.save { result in
                    if case .success = result {
                        self.logAnalytics(wallpaper: wallpaper)
                        userLikedWPs.append(self.wallpaperObjectId!)
                    }
                }
            } catch {
                print("Failed to append liked wallpaper to user: \(error.localizedDescription)")
            }
        }
    }

    private func logAnalytics(wallpaper: LCObject) {
        // Ensure this runs on the main thread
        DispatchQueue.global(qos: .utility).async {
            var info = [String: Any]()
            
            if let objectId = wallpaper.objectId?.stringValue {
                info["Um_Key_ContentID"] = objectId
            } else {
                print("Warning: wallpaper.objectId is nil")
            }
            
            if let caption = wallpaper.get("caption")?.stringValue {
                info["Um_Key_ContentName"] = caption
            }
            
            if let category = wallpaper.get("category")?.stringValue {
                info["Um_Key_ContentCategory"] = category
            }
            
            if let uploader = wallpaper.get("uploader") as? LCObject, let uploaderId = uploader.objectId?.stringValue {
                info["Um_Key_PublisherID"] = uploaderId
            }
            
            if let user = LCApplication.default.currentUser, let userId = user.objectId?.stringValue {
                info["Um_Key_UserID"] = userId
            }
            
            // Log the event
            UMAnalyticsSwift.event(eventId: "Um_Event_ContentFavorite", attributes: info)
        }
    }


    
    func showLoginOrRegisterVC(action: String) {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let emailVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        emailVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(emailVC, animated: true, completion: {
                if english{
                    emailVC.view.makeToast("Please  login or register for \(action) wallpaper", duration: 1.5, position: .center)
                }else{
                    emailVC.view.makeToast("请先「登录」或「注册」以\(action)壁纸", duration: 1.5, position: .center)
                }
            })
        }
    }
    
    func addGestureRcgToDownload(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(downloadImgViewTapped(tapGestureRecognizer:)))
        downloadImgV.isUserInteractionEnabled = true
        downloadImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func downloadImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        downloadImage()
    }
    
    func presentAlertForSaveSuccess(){
        
        let today_default:String = getTodayDefaultKey()
        UserDefaults.standard.set(true, forKey: today_default)
        
        let defaults = UserDefaults.standard
        let numReviewAsked = defaults.integer(forKey: NumReviewAskedKey)
        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
    
        if !reviewFuncCalled {
            actionCount += 1
            defaults.set(actionCount, forKey: .reviewWorthyActionCount)
            reviewFuncCalled = true
        }
        
        if numReviewAsked <= maxNumReviewAsk && actionCount % minimumReviewWorthyActionCount == 0{
            self.view.makeToast(downloadSuccessText, duration: 1.0, position: .center)
            AppStoreReviewManager.requestReviewIfAppropriate()
            
        }else{
            let alertController = UIAlertController(title: saveSuccessText, message: askGoToAlbumText, preferredStyle: .alert)
            
            let goAlbumAction = UIAlertAction(title:goToAlbumText , style: .default){ _ in
                UIApplication.shared.open(URL(string:"photos-redirect://")!)
             }
            
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel){ _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(goAlbumAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true)
        }
        
    }
    
    func addGestureRcgToPreview(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(preview(tapGestureRecognizer:)))
        previewImgV.isUserInteractionEnabled = true
        previewImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showLockScreenPreview(){
        previewStatus = .LockScreen
        DispatchQueue.main.async {
            self.lockScreenPreviewImgV.alpha = 1.0
        }
    }
    
    func hideLockScreenPreview(){
        DispatchQueue.main.async {
            self.lockScreenPreviewImgV.alpha = 0
        }
    }
    
    @objc func preview(tapGestureRecognizer: UITapGestureRecognizer)
    {
        hideButtons()
        showLockScreenPreview()
    }
    
    func addGestureRcgToOption(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(options(tapGestureRecognizer:)))
        optionImgV.isUserInteractionEnabled = true
        optionImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showHomeScreenPreview(){
        previewStatus = .HomeScreen
        DispatchQueue.main.async {
            self.homeScreenPreviewImgV.alpha = 1
        }
    }
    
    func hideHomeScreenPreview(){
        DispatchQueue.main.async {
            self.homeScreenPreviewImgV.alpha = 0
        }
    }
    
    
    @objc func options(tapGestureRecognizer: UITapGestureRecognizer){
        let iconWidthHeight:CGFloat = 20
        let contentAction = PopMenuDefaultAction(title: badContentText, image: UIImage(named: "alarm"), color: UIColor.darkGray)
        let resolutionAction = PopMenuDefaultAction(title: lowResolutionText, image: UIImage(named: "frown"), color: UIColor.darkGray)
        let copyrightAction = PopMenuDefaultAction(title: copyrightIssueText, image: UIImage(named: "copyright"), color: UIColor.darkGray)
        let classificationAction = PopMenuDefaultAction(title: classificationErrorText, image: UIImage(named: "warning"), color: UIColor.darkGray)
        
        contentAction.iconWidthHeight = iconWidthHeight
        resolutionAction.iconWidthHeight = iconWidthHeight
        copyrightAction.iconWidthHeight = iconWidthHeight
        classificationAction.iconWidthHeight = iconWidthHeight
        
        let menuVC = PopMenuViewController(sourceView: optionImgV, actions: [contentAction, resolutionAction, copyrightAction, classificationAction])
        menuVC.delegate = self
        menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
        
        menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(red: 240, green: 240, blue: 240, alpha: 1))
        self.present(menuVC, animated: true, completion: nil)
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
                self.view.makeToast("\(errorText): \(error.localizedDescription)", duration: 1.0, position: .center)
        }
        else{
            presentAlertForSaveSuccess()
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            setTheme(theme: .day)
        } else {
            setTheme(theme: .night)
        }
    }
}


// MARK: - Pop Menu Protocal Implementation
extension WallpaperDetailVC: PopMenuViewControllerDelegate {

    func reportWallpaperProblem(code: Int, popMenuViewController: PopMenuViewController){
        
        let alertController = UIAlertController(title: reportAskText, message: "", preferredStyle: .alert)
        
        let reportAction = UIAlertAction(title: reportText, style: .destructive){ _ in
            do{
                let wallpaper = LCObject(className: "Wallpaper", objectId: self.wallpaperObjectId!)
                try wallpaper.set("status", value: code)
                wallpaper.save { (result) in
                        switch result {
                        case .success:
                            var info = ["Um_Key_ContentID": self.wallpaperObjectId!, "Um_Key_ContentTag" : self.reportClassification[code]! ] as [String : Any]
                            
                            if let user = LCApplication.default.currentUser{
                                let userId = user.objectId!.stringValue!
                                info["Um_Key_UserID"] = userId
                            }
                            
                            if let category = wallpaper.get("category"){
                                info["Um_Key_ContentCategory"] = category.stringValue
                            }
                            
                            if let uploader = wallpaper.get("uploader") as? LCObject {
                                info["Um_Key_PublisherID"] = uploader.objectId!.stringValue!
                            }
                            
                            UMAnalyticsSwift.event(eventId: "Um_Event_ContentReport", attributes: info)
                            
                            DispatchQueue.main.async {
                                self.view.makeToast(reportSuccessText, duration: 1.0, position: .center)
                            }
                        case .failure(error: let error):
                            self.view.makeToast(error.reason, duration: 1.0, position: .center)
                        }
                    }
            } catch {
                self.view.makeToast(errorRetryText, duration: 1.0, position: .center)
            }
         }
        
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        popMenuViewController.dismiss(animated: false, completion: {
            self.present(alertController, animated: true)
        })
        
        
        
        
    }
    
    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        if let _ = LCApplication.default.currentUser {
            if index == 0{
                reportWallpaperProblem(code: 2, popMenuViewController: popMenuViewController)
            }else if index == 1{
                reportWallpaperProblem(code: 3, popMenuViewController: popMenuViewController)
            }else if index == 2{
                reportWallpaperProblem(code: 4, popMenuViewController: popMenuViewController)
            }
            else{
                reportWallpaperProblem(code: 5, popMenuViewController: popMenuViewController)
            }
        }else{
            showLoginOrRegisterVC(action: ACTION_TYPE.report.rawValue)
        }
    }
}
