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

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    
    var currentUser = LCApplication.default.currentUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    
    
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    @IBOutlet var logoutBtn: UIButton!{
        didSet{
            logoutBtn.theme_backgroundColor = "Global.logOutBtnBgColor"
            logoutBtn.theme_setTitleColor("Global.logOutTextColor", forState: .normal)
            logoutBtn.layer.cornerRadius = 9.0
            logoutBtn.layer.masksToBounds = true
        }
    }
    
    func initActivityIndicator(text: String) {
        activityLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        activityEffectView.removeFromSuperview()
        let height:CGFloat = 46.0
        activityLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: height))
        activityLabel.text = text
        activityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        activityLabel.textColor = .darkGray
        activityLabel.alpha = 1.0
        activityEffectView.frame = CGRect(x: view.frame.midX - activityLabel.frame.width/2, y: view.frame.midY - activityLabel.frame.height/2 , width: 220, height: height)
        activityEffectView.layer.cornerRadius = 15
        activityEffectView.layer.masksToBounds = true
        activityEffectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        activityEffectView.alpha = 1.0
        activityIndicator = .init(style: .medium)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()

        activityEffectView.contentView.addSubview(activityIndicator)
        activityEffectView.contentView.addSubview(activityLabel)
        view.addSubview(activityEffectView)
    }
    
    func stopIndicator(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.activityEffectView.alpha = 0
        self.activityLabel.alpha = 0
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
    @IBOutlet weak var barTitleLabel: UILabel!
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        self.updateUserPhoto()
        self.modalPresentationStyle = .overCurrentContext
        
        view.isOpaque = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    func presentAlertInView(title: String, message: String, okText: String){
        let alertController = presentAlert(title: title, message: message, okText: okText)
        self.present(alertController, animated: true)
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
            print(error)
        }
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
        
        let photoSourceController = UIAlertController(title: "", message: NSLocalizedString("选择您的头像", comment: "选择您的头像") , preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("相机", comment: "相机") , style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("照片库", comment: "照片库") , style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: "取消"), style: .cancel, handler: nil)
        
        photoSourceController.addAction(cameraAction)
        photoSourceController.addAction(photoLibraryAction)
        photoSourceController.addAction(cancelAction)
        
        present(photoSourceController, animated: true, completion: nil)
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
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: {
                self.updateUserPhoto()
                self.mainPanelViewController.loadUserPhoto()
            })
        }
        
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                let file = LCFile(payload: .data(data: imageData))
                if let _ =  file.get("name")?.stringValue{
                    
                }else{
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
