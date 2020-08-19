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

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate , UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var user = LCApplication.default.currentUser!
    let username = getUserName()
    let settingItems:[SettingItem] = [
        SettingItem(icon: UIImage(named: "nickname") ?? UIImage(), name: "昵 称", value: "未设置"),
        SettingItem(icon: UIImage(named: "email") ?? UIImage(), name: "邮 箱", value: "未绑定"),
        SettingItem(icon: UIImage(named: "cell_phone") ?? UIImage(), name: "手 机", value: "未绑定")
    ]
    
//    ,SettingItem(icon: UIImage(named: "wechat_setting") ?? UIImage(), name: "微 信", value: "未绑定"),
//    SettingItem(icon: UIImage(named: "qq_setting") ?? UIImage(), name: "QQ", value: "未绑定"),
//    SettingItem(icon: UIImage(named: "weibo_setting") ?? UIImage(), name: "新浪微博", value: "未绑定")
    
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
    
    @IBOutlet var tableView: UITableView!
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
    
    var mainPanelViewController: MainPanelViewController!
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
        tableView.theme_backgroundColor = "Global.viewBackgroundColor"
        self.updateUserPhoto()
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
        cell.valueLabel?.theme_textColor = ["未验证", "未设置", "未绑定"].contains(textStr) ? "TableView.switchOnTextColor" : "TableView.switchOffTextColor"
        cell.valueLabel?.text = textStr
        cell.backgroundColor = .clear
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row: Int = indexPath.row
        let textStr: String = getSetted(row: row)
        
        switch row {
        case 0:
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let setNickNameVC = mainStoryBoard.instantiateViewController(withIdentifier: "setNickNameVC") as! setNickNameViewController
            if let user_nickname = user.get("nickname")?.stringValue{
                setNickNameVC.nickname = user_nickname
            }else{
                setNickNameVC.nickname = ""
            }
            
            setNickNameVC.modalPresentationStyle = .fullScreen
            self.present(setNickNameVC, animated: true, completion: nil)
        case 1:
            if textStr == "未绑定"{
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let bindEmailVC = mainStoryBoard.instantiateViewController(withIdentifier: "bindEmailVC") as! bindEmailViewController
                bindEmailVC.modalPresentationStyle = .fullScreen
                self.present(bindEmailVC, animated: true, completion: nil)
            }else if textStr == "未验证"{
                var lastEmailLoginClickTime:Date? = nil
                let emailVerficationSendTimeKey:String = "EmailVerficationSendTime"
                if isKeyPresentInUserDefaults(key: emailVerficationSendTimeKey){
                    lastEmailLoginClickTime = UserDefaults.standard.object(forKey: emailVerficationSendTimeKey) as? Date
                }
                if lastEmailLoginClickTime == nil ||  minutesBetweenDates(lastEmailLoginClickTime!, Date()) > 1 {
                    if let email = getEmail(){
                        UserDefaults.standard.set(Date(), forKey: emailVerficationSendTimeKey)
                        _ = LCUser.requestVerificationMail(email: email) { result in
                            switch result {
                            case .success:
                                let alertController = UIAlertController(title: "已发送验证邮件到\(email)\n请验证后重新登录!", message: "", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "好", style: .default, handler: { action in
                                    LCUser.logOut()
                                    self.dismiss(animated: true, completion: nil)
                                    self.mainPanelViewController.showLoginScreen()
                                    })
                                alertController.addAction(okayAction)
                                self.present(alertController, animated: true, completion: nil)
                            case .failure(error: let error):
                                self.presentAlertInView(title: error.localizedDescription, message: "", okText: "好")
                            }
                        }
                    } else{
                        self.presentAlertInView(title: "获取Email出现问题，请稍后再试!", message: "", okText: "好")
                    }
                } else{
                    self.presentAlertInView(title: "尝试过于频繁，请稍等1分钟!", message: "", okText: "好")
                }
            }
        case 2:
            if ["未验证", "未绑定"].contains(textStr){
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let bindPhonerVC = mainStoryBoard.instantiateViewController(withIdentifier: "bindPhonerVC") as! bindPhoneViewController
                bindPhonerVC.phoneNumber = getPhoneNumber()
                bindPhonerVC.modalPresentationStyle = .fullScreen
                self.present(bindPhonerVC, animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.tableView.reloadData()
    }
    
    func updateUserPhoto() {
        if let userImage = loadPhoto(name_of_photo: "user_avatar_\(username).jpg") {
            DispatchQueue.main.async {
                self.userPhotoBtn.setImage(userImage, for: [])
            }
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        let connected = Reachability.isConnectedToNetwork()
        if connected{
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
            picker.dismiss(animated: true, completion: nil)
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
        let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar_\(username).jpg")
        let cropped_img = resizeImage(image: image, newWidth: 300.0)
        try? cropped_img.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: nil)
            self.initActivityIndicator(text: "头像上传中..")
            self.dismiss(animated: true, completion: nil)
        }
        
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            DispatchQueue.global(qos: .background).async {
            do {
                let user = LCApplication.default.currentUser!
                do {
                    let query = LCQuery(className: "_User")
                    _ = query.get(user.objectId as! LCStringConvertible) { result in
                        switch result {
                            case .success(object: let unauthenticatedUser):
                                if let old_photo = unauthenticatedUser.get("avatar"){
                                 let old_file = old_photo as! LCFile
                                 if let obj_id:String = old_file.objectId?.stringValue{
                                    let old_photo_file = LCObject(className: "_File", objectId: obj_id as LCStringConvertible)
                                         old_photo_file.delete()
                                     print("File with id: \(obj_id) deleted")
                                     }
                                }
                            case .failure(error: let error):
                                print(error)
                        }
                    }
                }
                
                let file = LCFile(payload: .fileURL(fileURL: imageFileURL))
                _ = file.save { result in
                        switch result {
                        case .success:
                            if let objectId:String = file.objectId?.value {
                                print("用户头像上传完成。")
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
        let connected = Reachability.isConnectedToNetwork()
        if connected{
           DispatchQueue.global(qos: .background).async {
           do {
               let user = LCApplication.default.currentUser!
               do {
                try user.set("avatar", value: file)
                user.save { (result) in
                    switch result {
                    case .success:
                        print("Cloud User Photo Saved Successful!")
                        self.updateUserPhoto()
                        self.mainPanelViewController.updateUserPhoto()
                        self.stopIndicator()
                    case .failure(error: let error):
                        self.stopIndicator()
                    }
                }
               } catch {
                   self.stopIndicator()
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
