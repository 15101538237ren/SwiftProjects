//
//  MainPanelViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import AVFoundation

class MainPanelViewController: UIViewController {
    @IBOutlet var mainPanelUIView: MainPanelUIView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var todayImageView: UIImageView!
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    var words = [["wordHead":"flower", "trans": "花"], ["wordHead":"Lilac", "trans": "紫丁香"]]
    func updateUserPhoto() {
        if let userImage = loadUserPhoto() {
            self.userPhotoBtn.setImage(userImage, for: [])
        }
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        
        if let user = LCApplication.default.currentUser {
            // 跳到首页
            if let userImage = loadUserPhoto() {
                self.userPhotoBtn.setImage(userImage, for: [])
            }
            else {
                do {
                    if let photoData = user.get("avatar") as? LCFile {
                        //let imgData = photoData.value as! LCData
                        let url = URL(string: photoData.url?.value as! String)!
                        let data = try? Data(contentsOf: url)
                        print(url)
                        if let imageData = data {
                            let image = UIImage(data: imageData)
                            let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
                            try? image!.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
                            self.userPhotoBtn.setImage(image, for: [])
                        }
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    override func viewWillAppear(_ animated: Bool){
        if let user = LCApplication.default.currentUser {
            let defaults = UserDefaults.standard
            let theme_category_exist = isKeyPresentInUserDefaults(key: theme_category_string)
            var theme_category  = 6
            if theme_category_exist{
                theme_category = defaults.integer(forKey: theme_category_string)
            }
            let wallpaper = default_wallpapers[theme_category - 1]
            wordLabel.text = wallpaper.word
            wordLabel.textColor = textColors[theme_category]
            meaningLabel.text = wallpaper.trans
            meaningLabel.textColor = textColors[theme_category]
            todayImageView?.image = UIImage(named: "theme_\(theme_category)")
            }
        else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    func showLoginScreen() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let mainScreenViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "StartScreen") as! MainScreenViewController
        mainScreenViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(mainScreenViewController, animated: true, completion: nil)
        }
    }
//    
//    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue"{
            let destinationController = segue.destination as! UserProfileViewController
            destinationController.mainPanelViewController = self
        }
    }

}
