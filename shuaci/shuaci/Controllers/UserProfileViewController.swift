//
//  UserProfileViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/2/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import CropViewController
import SwiftTheme
import Disk
import Nuke
import SwifterSwift

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    var currentUser = LCApplication.default.currentUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    var imagePicker = UIImagePickerController()
    
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    
    @IBOutlet var numWordTodayLabel: UILabel!
    @IBOutlet var numMinutesTodayLabel: UILabel!
    @IBOutlet var numWordCumulatedLabel: UILabel!
    @IBOutlet var numMinutesCumulatedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet var overView: UIView!{
        didSet {
            overView.theme_backgroundColor = "StatView.panelBgColor"
            overView?.layer.cornerRadius = 15.0
            overView?.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var logoutBtn: UIButton!{
        didSet{
            logoutBtn.theme_tintColor = "Global.backBtnTintColor"
        }
    }
    
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var cameraIconBtn: UIButton!{
        didSet {
            cameraIconBtn.theme_tintColor = "UserProfile.cameraIconTintColor"
        }
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        view.isOpaque = false
        
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        
        addGestureRecognizers()
        updateUserPhoto()
        updateDisplayName()
        getStatOfToday()
        super.viewDidLoad()
    }
    
    func addGestureRecognizers(){
        let labelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(popNameTextInputAlert(tapGestureRecognizer:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    func updateDisplayName(){
        let key:String = "\(currentUser.objectId!.stringValue!)_display_name"
        if !isKeyPresentInUserDefaults(key: key){
            _ = currentUser.fetch(keys: ["name"]) { result in
                switch result {
                case .success:
                    if let name:String = self.currentUser.get("name")?.stringValue{
                        DispatchQueue.main.async {
                            self.nameLabel.text = name
                        }
                    }
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }else{
            if let name:String = UserDefaults.standard.string(forKey: key){
                DispatchQueue.main.async {
                    self.nameLabel.text = name
                }
            }
        }
    }
    
    func setElements(enable: Bool){
        self.view.isUserInteractionEnabled = enable
        self.backBtn.isUserInteractionEnabled = enable
        self.logoutBtn.isUserInteractionEnabled = enable
        self.nameLabel.isUserInteractionEnabled = enable
        self.userPhotoBtn.isUserInteractionEnabled = enable
        self.cameraIconBtn.isUserInteractionEnabled = enable
    }
    
    func setDisplayName(name: String){
        if !Reachability.isConnectedToNetwork(){
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            return
        }
        initIndicator(view: self.view)
        setElements(enable: false)
        do {
            try currentUser.set("name", value: name)
            _ = currentUser.save { [self] result in
                stopIndicator()
                switch result {
                case .success:
                    print("updated display name successful!")
                    UserDefaults.standard.setValue(name, forKey: "\(currentUser.objectId!.stringValue!)_display_name")
                    mainPanelViewController.currentUser = currentUser
                    DispatchQueue.main.async { [self] in
                        nameLabel.text = name
                    }
                case .failure(error: let error):
                    self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                }
                self.setElements(enable: true)
            }
        }catch {
            stopIndicator()
            self.setElements(enable: true)
            self.view.makeToast("设置失败，请稍后重试!", duration: 1.0, position: .center)
        }
    }
    
    @objc func popNameTextInputAlert(tapGestureRecognizer: UITapGestureRecognizer){
        let alertController = UIAlertController(title: "设置显示名称", message: "", preferredStyle: .alert)
        
        alertController.addTextField(text: "", placeholder: "输入显示名称", editingChangedTarget: nil, editingChangedSelector: nil)
        
        let setAction = UIAlertAction(title: "确定", style: .default){ _ in
            let name: String = alertController.textFields!.first!.text ?? ""
            if !name.isEmpty{
                self.setDisplayName(name: name)
                alertController.dismiss(animated: true, completion: nil)
            }else{
                self.view.makeToast("请输入显示名称", duration: 1.2, position: .center)
            }
            
         }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(setAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    func updateUserPhoto() {
        let userId = currentUser.objectId!.stringValue!
        let avatar_fp = "user_avatar_\(userId).jpg"
        do {
            let retrievedImage = try Disk.retrieve(avatar_fp, from: .documents, as: UIImage.self)
            print("retrieved Avatar Successful!")
            DispatchQueue.main.async {
                self.userPhotoBtn.setImage(retrievedImage, for: [])
                self.userPhotoBtn.setNeedsDisplay()
            }
        } catch {
            getUserPhoto()
            print(error)
        }
    }
    
    func getUserPhoto(){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async { [self] in
                if let file = currentUser.get("avatar") as? LCFile {
                    
                    let imgUrl = URL(string: file.url!.stringValue!)!
                    
                    _ = ImagePipeline.shared.loadImage(
                        with: imgUrl,
                        completion: { [self] response in
                            switch response {
                              case .failure:
                                break
                              case let .success(imageResponse):
                                let image = imageResponse.image
                                
                                DispatchQueue.main.async {
                                    self.userPhotoBtn.setImage(image, for: [])
                                    self.userPhotoBtn.setNeedsDisplay()
                                }
                                let userID = currentUser.objectId!.stringValue!
                                
                                let avatar_fp = "user_avatar_\(userID).jpg"
                                
                                do {
                                    try Disk.save(image, to: .documents, as: avatar_fp)
                                    print("Save Downloaded Avatar Successful!")
                                } catch {
                                    print(error)
                                }
                              }
                        }
                    )
                }
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }

    }
    
    func getStatOfToday(){
        let today = Date()
        
        let today_records = getRecordsOfDate(date: today)
        let todayLearnRec = today_records.filter { $0.recordType == 1}
        let todayReviewRec = today_records.filter { $0.recordType == 2}
        var number_of_vocab_today:Int = 0
        var number_of_learning_secs_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        
        var number_of_vocab_cummulated:Int = 0
        var number_of_learning_secs_cummulated: Int = 0
        
        let global_learning_records = global_records.filter { $0.recordType == 1}
        let global_review_records = global_records.filter { $0.recordType == 2}
        
        for lrec in global_learning_records{
            number_of_vocab_cummulated += lrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_cummulated += secondT
            }
        }
        for rrec in global_review_records{
            let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_cummulated += secondT
            }
        }
        
        DispatchQueue.main.async {
            self.numWordTodayLabel.text = "\(number_of_vocab_today)"
            self.numWordCumulatedLabel.text = "\(number_of_vocab_cummulated)"
            let learning_mins_today = Double(number_of_learning_secs_today)/60.0
            if learning_mins_today > 1.0 || number_of_learning_secs_today == 0{
                self.numMinutesTodayLabel.text = String(format: "%d", Int(round(learning_mins_today)))
            }
            else{
                self.numMinutesTodayLabel.text = String(format: "%.1f", learning_mins_today)
            }
            let learning_mins_cummulated =  Double(number_of_learning_secs_cummulated)/60.0
            
            if learning_mins_cummulated > 1.0 || number_of_learning_secs_cummulated == 0{
                self.numMinutesCumulatedLabel.text = String(format: "%d", Int(round(learning_mins_cummulated)))
            }
            else{
                self.numMinutesCumulatedLabel.text = String(format: "%.1f", learning_mins_cummulated)
            }
        }
    }
    
    func presentAlertInView(title: String, message: String, okText: String){
        let alertController = presentAlert(title: title, message: message, okText: okText)
        self.present(alertController, animated: true)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
           let alertController = UIAlertController(title: "提示", message: "确定注销?", preferredStyle: .alert)
           
            let okayAction = UIAlertAction(title: "确定", style: .default, handler: { action in
               LCUser.logOut()
               self.dismiss(animated: false, completion: {
                self.mainPanelViewController.dismiss(animated: true, completion: nil)
               })
           })
            
           let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           alertController.addAction(okayAction)
           alertController.addAction(cancelAction)
           self.present(alertController, animated: true, completion: nil)
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newWidth))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async { [self] in
                picker.dismiss(animated: true, completion: nil)
                
                let targetLength:CGFloat = view.bounds.width * UIScreen.main.scale
                
                let leftPosition = (pickedImage.size.width * pickedImage.scale - targetLength)/2.0
                let topPosition = (pickedImage.size.height * pickedImage.scale - targetLength)/2.0
                let cropController = CropViewController(image: pickedImage)
                cropController.title = "「缩放」或「拖拽」来调整"
                cropController.doneButtonTitle = "确定"
                cropController.cancelButtonTitle = "取消"
                cropController.imageCropFrame = CGRect(x: leftPosition, y: topPosition, width: targetLength, height: targetLength)
                cropController.aspectRatioPreset = .presetSquare
                cropController.rotateButtonsHidden = true
                cropController.rotateClockwiseButtonHidden = true
                cropController.resetButtonHidden = true
                cropController.aspectRatioLockEnabled = true
                cropController.resetAspectRatioEnabled = false
                cropController.aspectRatioPickerButtonHidden = true
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // Write the image to local file for temporary use
        
        let userId = currentUser.objectId!.stringValue!
        
        let imageData:Data = resizeImage(image: image, newWidth: 300.0).jpegData(compressionQuality: 1.0)!
        
        let avatar_fp = "user_avatar_\(userId).jpg"
        
        do {
            try Disk.save(imageData, to: .documents, as: avatar_fp)
            print("Save Avatar Successful!")
        } catch {
            print(error)
        }
        
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                let file = LCFile(payload: .data(data: imageData))
                if let _ =  file.get("name")?.stringValue{
                    
                }else
                {
                    do{
                        try file.set("name", value: "unnamed")
                    }catch{
                        print("无法设置文件名称")
                    }
                }
                _ = file.save { result in
                        switch result {
                        case .success:
                            self.update_user_photo_lc(file: file)
                            break
                        case .failure(error: let error):
                            // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                            print(error)
                        }
                    }
                }
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
        
        DispatchQueue.main.async {
            self.updateUserPhoto()
            self.mainPanelViewController.loadUserPhoto()
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func update_user_photo_lc(file: LCFile){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async { [self] in
           do {
               do {
                try currentUser.set("avatar", value: file)
                currentUser.save { (result) in
                    switch result {
                    case .success:
                        mainPanelViewController.currentUser = currentUser
                        print("Cloud User Photo Saved Successful!")
                    case .failure(error: let error):
                        print(error)
                    }
                }
               } catch {
               }
               }
           }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
}
