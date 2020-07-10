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

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate , UITableViewDataSource, UITableViewDelegate {
    let user = LCApplication.default.currentUser!
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let settingItems:[SettingItem] = [
        SettingItem(icon: UIImage(named: "nickname") ?? UIImage(), name: "昵 称", value: "未设置"),
        SettingItem(icon: UIImage(named: "email") ?? UIImage(), name: "邮 箱", value: "未绑定"),
        SettingItem(icon: UIImage(named: "cell_phone") ?? UIImage(), name: "手 机", value: "未绑定")
    ]
    
//    ,SettingItem(icon: UIImage(named: "wechat_setting") ?? UIImage(), name: "微 信", value: "未绑定"),
//    SettingItem(icon: UIImage(named: "qq_setting") ?? UIImage(), name: "QQ", value: "未绑定"),
//    SettingItem(icon: UIImage(named: "weibo_setting") ?? UIImage(), name: "新浪微博", value: "未绑定")
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    var mainPanelViewController: MainPanelViewController!
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        self.modalPresentationStyle = .overCurrentContext
        
        view.isOpaque = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func getSetted(row: Int)-> String{
        var textStr: String = "未绑定"
        switch row {
            case 0:
                if let user_nickname = user.get("nickname")?.stringValue{
                    textStr = user_nickname
                }
                else{
                    textStr = "未设置"
                }
            case 1:
                if let _ = user.get("email")?.stringValue{
                    let verified = user.get("emailVerified")!.boolValue!
                    if verified{
                        textStr = "已绑定"
                    }else{
                        textStr = "未验证"
                    }
                }
            case 2:
                if let _ = user.get("mobilePhoneNumber")?.stringValue{
                    let verified = user.get("mobilePhoneVerified")!.boolValue!
                    if verified{
                        textStr = "已绑定"
                    }else{
                        textStr = "未验证"
                    }
                }
            default:
                    textStr = "未验证"
        }
            return textStr
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingCell", for: indexPath) as! SettingTableViewCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
        let settingItem:SettingItem = settingItems[row]
        cell.iconView?.image = settingItem.icon
        cell.nameLabel?.text = settingItem.name
        let textStr: String = getSetted(row: row)
        cell.valueLabel?.textColor = ["未验证", "未设置", "未绑定"].contains(textStr) ? self.redColor : .darkGray
        cell.valueLabel?.text = textStr
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let row: Int = indexPath.row
//        let setted: Bool = getSetted(row: row)
//        if row == 0 || row == 2 || !setted
//        {
//            switch row {
//            case 0:
//                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let bindPhoneNumberVC = mainStoryBoard.instantiateViewController(withIdentifier: "bindPhoneNumberVC") as! BindPhoneNumberViewController
//            case 1:
//            case 2:
//                
//                booksVC.modalPresentationStyle = .fullScreen
//                booksVC.mainPanelViewController = nil
//                fetchBooks()
//                DispatchQueue.main.async {
//                    self.present(booksVC, animated: true, completion: nil)
//                }
//            case 3:
//                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let NumOfWordPopUpVC = mainStoryBoard.instantiateViewController(withIdentifier: "NumOfWordVC") as! NumWordPerGroupViewController
//                NumOfWordPopUpVC.setting_tableView = tableView
//                DispatchQueue.main.async {
//                    self.present(NumOfWordPopUpVC, animated: true, completion: nil)
//                }
//            case 6:
//                initActivityIndicator(text: "正在上传设置..")
//                savePreference(saveToLocal: false, saveToCloud: true, completionHandler: {_ in
//                    DispatchQueue.main.async {
//                    self.activityLabel.text = "正在上传学习记录..."
//                    }})
//                
//                saveVocabRecords(saveToLocal: false, saveToCloud: true, random_new_word: false, delaySeconds: 1.0, completionHandler: {_ in })
//                saveLearningRecords(saveToLocal: false, saveToCloud: true, delaySeconds: 1.5, completionHandler: {_ in })
//                saveReviewRecords(saveToLocal: false, saveToCloud: true, delaySeconds: 2.0, completionHandler: {success in
//                    var successMessage: String = "上传成功!"
//                    if !success {
//                        successMessage = "上传失败，请稍后再试.."
//                    }
//                    DispatchQueue.main.async {
//                        self.stopIndicator()
//                        let ac = UIAlertController(title: "提示", message: successMessage, preferredStyle: .alert)
//                        ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
//                        self.present(ac, animated: true, completion: nil)
//                    }
//                })
//            case 8:
//                showFeedBackMailComposer()
//            default:
//                break
//            }
//        }
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool){
        self.updateUserPhoto()
    }
    
    func updateUserPhoto() {
        if let userImage = loadPhoto(name_of_photo: "user_avatar.jpg") {
            self.userPhotoBtn.setImage(userImage, for: [])
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
           let alertController = UIAlertController(title: "提示", message: "确定注销?", preferredStyle: .alert)
           let okayAction = UIAlertAction(title: "确定", style: .default, handler: { action in
               LCUser.logOut()
               self.dismiss(animated: false, completion: nil)
                self.mainPanelViewController.showLoginScreen()
           })
           let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           alertController.addAction(okayAction)
           alertController.addAction(cancelAction)
           self.present(alertController, animated: true, completion: nil)
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        
        let photoSourceController = UIAlertController(title: "", message: NSLocalizedString("选择您的头像", comment: "选择您的头像") , preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("相机", comment: "相机") , style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
//                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("照片库", comment: "照片库") , style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
//                imagePicker.allowsEditing = true
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
            dismiss(animated: true, completion: nil)
            let cropVC = CropViewController(image: pickedImage)
            cropVC.delegate = self
            cropVC.aspectRatioPickerButtonHidden = true
            cropVC.aspectRatioPreset = .presetSquare
            cropVC.aspectRatioLockEnabled = true
            cropVC.resetAspectRatioEnabled = false
            self.present(cropVC, animated: false, completion: nil)
        }
    }
    
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // Write the image to local file for temporary use
        let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
        let cropped_img = resizeImage(image: image, newWidth: 300.0)
        try? cropped_img.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        self.updateUserPhoto()
        self.mainPanelViewController.updateUserPhoto()
        dismiss(animated: true, completion: nil)
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                let file = LCFile(payload: .fileURL(fileURL: imageFileURL))
                _ = file.save { result in
                        switch result {
                        case .success:
                            if let objectId:String = file.objectId?.value {
                                print("文件保存完成。objectId: \(objectId)")
                                self.update_user_photo(file: file)
                            }
                        case .failure(error: let error):
                            // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                            print(error)
                        }
                    }
                }
            }
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
            non_network_preseted = true
        }
        
    }
    
    func update_user_photo(file: LCFile){
        if Reachability.isConnectedToNetwork(){
           DispatchQueue.global(qos: .background).async {
           do {
               let user = LCApplication.default.currentUser!
                   do {
                       
                       if let old_photo = user.get("avatar"){
                           let file = old_photo as! LCFile
                           let old_photo_file = LCObject(className: "_File", objectId: file.objectId?.value as! LCStringConvertible)
                           old_photo_file.delete()
                       }
                       
                       try user.set("avatar", value: file)
                       user.save { (result) in
                           switch result {
                           case .success:
                               break
                           case .failure(error: let error):
                               print(error)
                           }
                       }
                   } catch {
                       print(error)
                   }
               }
           }
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
            non_network_preseted = true
        }
        
    }
}
