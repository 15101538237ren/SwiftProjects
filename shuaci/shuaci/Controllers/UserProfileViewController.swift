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
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let settingItems:[SettingItem] = [
        SettingItem(icon: UIImage(named: "nickname") ?? UIImage(), name: "昵 称", value: "未设置"),
        SettingItem(icon: UIImage(named: "email") ?? UIImage(), name: "邮 箱", value: "未绑定"),
        SettingItem(icon: UIImage(named: "change_password") ?? UIImage(), name: "修改密码", value: ""),
        SettingItem(icon: UIImage(named: "cell_phone") ?? UIImage(), name: "手 机", value: "未绑定"),
        SettingItem(icon: UIImage(named: "wechat_setting") ?? UIImage(), name: "微 信", value: "未绑定"),
        SettingItem(icon: UIImage(named: "qq_setting") ?? UIImage(), name: "QQ", value: "未绑定"),
        SettingItem(icon: UIImage(named: "weibo_setting") ?? UIImage(), name: "新浪微博", value: "未绑定")
    ]
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    var mainPanelViewController: MainPanelViewController!
    
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
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingCell", for: indexPath) as! SettingTableViewCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
        let settingItem:SettingItem = settingItems[row]
        cell.iconView?.image = settingItem.icon
        cell.nameLabel?.text = settingItem.name
        cell.valueLabel?.text = settingItem.value
        if settingItem.value == "未绑定" || settingItem.value == "未设置"{
            cell.valueLabel?.textColor = self.redColor
        }
        else {
            cell.valueLabel?.textColor = .darkGray
        }
        return cell
    }
    
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
           let alertController = UIAlertController(title: "注销", message: "确定注销?", preferredStyle: .alert)
           let okayAction = UIAlertAction(title: "确定", style: .default, handler: { action in
               LCUser.logOut()
               self.dismiss(animated: false, completion: nil)
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
