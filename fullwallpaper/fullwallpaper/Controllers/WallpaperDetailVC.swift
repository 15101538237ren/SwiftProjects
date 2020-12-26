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
    @IBOutlet var lockScreenPreviewImgV: UIImageView!
    @IBOutlet var homeScreenPreviewImgV: UIImageView!
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
    var reportClassification:[Int : String] = [2:"不良内容", 3: "清晰度不佳", 4: "壁纸侵权", 5: "分类有误"]
    
    // MARK: - Constants
    let scaleForAnimation: CGFloat = 2
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfDisabled()
    }
    
    func checkIfDisabled(){
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
            _ = ImagePipeline.shared.loadImage(
                with: url,
                completion: { response in
                    stopIndicator()
                    switch response {
                      case .failure:
                        self.imageView.image = ImageLoadingOptions.shared.failureImage
                        self.imageView.contentMode = .scaleAspectFit
                      case let .success(imageResponse):
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
    
    func downloadImage() {
        if let user = LCApplication.default.currentUser {
            if let image = imageView.image{
                do{
                    let wallpaper = LCObject(className: "Wallpaper", objectId: wallpaperObjectId!)
                    try wallpaper.increase("likes", by: 1)
                    wallpaper.save { (result) in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    do {
                                        try user.append("likedWPs", element: self.wallpaperObjectId!, unique: true)
                                        
                                        user.save{ [self] (result) in
                                            switch result {
                                            case .success:
                                                
                                                var info = ["Um_Key_ContentID": wallpaper.objectId!.stringValue!] as [String : Any]
                                                
                                                if let caption = wallpaper.get("caption"){
                                                    info["Um_Key_ContentName"] = caption.stringValue
                                                }
                                                
                                                if let category = wallpaper.get("category"){
                                                    info["Um_Key_ContentCategory"] = category.stringValue
                                                }
                                                
                                                if let uploader = wallpaper.get("uploader") as? LCObject {
                                                    info["Um_Key_PublisherID"] = uploader.objectId!.stringValue!
                                                }
                                                
                                                if let user = LCApplication.default.currentUser{
                                                    let userId = user.objectId!.stringValue!
                                                    info["Um_Key_UserID"] = userId
                                                }
                                                UMAnalyticsSwift.event(eventId: "Um_Event_ContentFavorite", attributes: info)
                                                
                                                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                                                if !reviewFuncCalled {
                                                    AppStoreReviewManager.requestReviewIfAppropriate()
                                                    reviewFuncCalled = true
                                                }
                                                userLikedWPs.append(self.wallpaperObjectId!)
                                                stopIndicator()
                                            case .failure:
                                                stopIndicator()
                                                self.view.makeToast("下载失败，请重试!", duration: 1.0, position: .center)
                                            }
                                        }
                                    } catch {
                                        stopIndicator()
                                        self.view.makeToast("下载失败，请重试!", duration: 1.0, position: .center)
                                    }
                                }
                            case .failure:
                                stopIndicator()
                                self.view.makeToast("下载失败，请重试!", duration: 1.0, position: .center)
                            }
                        }
                } catch {
                    stopIndicator()
                    self.view.makeToast("下载失败，请重试!", duration: 1.0, position: .center)
                }
            }else{
                stopIndicator()
                self.view.makeToast("下载失败，请重试!", duration: 1.0, position: .center)
            }
        } else {
            // 显示注册或登录页面
            stopIndicator()
            showLoginOrRegisterVC(action: ACTION_TYPE.save.rawValue)
        }
    }
    
    func showLoginOrRegisterVC(action: String) {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let emailVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        emailVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(emailVC, animated: true, completion: {
                emailVC.view.makeToast("请先「登录」或「注册」以\(action)您喜欢的壁纸", duration: 1.5, position: .center)
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
        initIndicator(view: view)
        downloadImage()
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
        let contentAction = PopMenuDefaultAction(title: "不良内容", image: UIImage(named: "alarm"), color: UIColor.darkGray)
        let resolutionAction = PopMenuDefaultAction(title: "清晰度不佳", image: UIImage(named: "frown"), color: UIColor.darkGray)
        let copyrightAction = PopMenuDefaultAction(title: "壁纸侵权", image: UIImage(named: "copyright"), color: UIColor.darkGray)
        let classificationAction = PopMenuDefaultAction(title: "分类有误", image: UIImage(named: "warning"), color: UIColor.darkGray)
        
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
                self.view.makeToast("出现错误: \(error.localizedDescription)", duration: 1.0, position: .center)
        }
        else{
            self.view.makeToast("下载成功!", duration: 1.0, position: .center)
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Pop Menu Protocal Implementation
extension WallpaperDetailVC: PopMenuViewControllerDelegate {

    func reportWallpaperProblem(code: Int, popMenuViewController: PopMenuViewController){
        
        let alertController = UIAlertController(title: "确定举报壁纸？", message: "", preferredStyle: .alert)
        
        let reportAction = UIAlertAction(title: "举报", style: .destructive){ _ in
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
                                self.view.makeToast("举报成功!", duration: 1.0, position: .center)
                            }
                        case .failure(error: let error):
                            self.view.makeToast(error.reason, duration: 1.0, position: .center)
                        }
                    }
            } catch {
                self.view.makeToast("出现错误，请重试！", duration: 1.0, position: .center)
            }
         }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ _ in
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
    }
}
