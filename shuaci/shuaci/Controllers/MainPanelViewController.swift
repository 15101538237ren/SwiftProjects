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

class MainPanelViewController: UIViewController, CAAnimationDelegate {
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
    var isRotating = false
    var shouldStopRotating = false
    
    @IBOutlet var syncLabel: UILabel!
    
    @IBOutlet var themeBtn: UIButton!
    @IBOutlet var collectBtn: UIButton!
    @IBOutlet var statBtn: UIButton!
    @IBOutlet var settingBtn: UIButton!
    
    func updateUserPhoto() {
        if let userImage = loadUserPhoto() {
            self.userPhotoBtn.setImage(userImage, for: [])
        }
    }
    
    func setButtonsColor(color: UIColor) {
        themeBtn.tintColor = color
        collectBtn.tintColor = color
        statBtn.tintColor = color
        settingBtn.tintColor = color
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        
        if let user = LCApplication.default.currentUser {
            syncLabel.alpha = 0
            // 跳到首页
            if let userImage = loadUserPhoto() {
                self.userPhotoBtn.setImage(userImage, for: [])
            }
            else {
                self.getUserPhoto()
            }
        } else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    
    func getUserPhoto(){
        DispatchQueue.global(qos: .background).async {
            do {
                let user = LCApplication.default.currentUser
                if let photoData = user?.get("avatar") as? LCFile {
                    //let imgData = photoData.value as! LCData
                    let url = URL(string: photoData.url?.value as! String)!
                    let data = try? Data(contentsOf: url)
                    print(url)
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
                        try? image!.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
                        
                        DispatchQueue.main.async {
                            // qos' default value is ´DispatchQoS.QoSClass.default`
                            self.userPhotoBtn.setImage(image, for: [])
                        }
                    }
                }
            } catch {
                print(error)
            }

            
        }

    }
    
    func getTodayWallpaper(category: Int){
        DispatchQueue.global(qos: .background).async {
            do {
                
                let query = LCQuery(className: "Wallpaper")
                query.whereKey("theme_category", .equalTo(category))
                _ = query.find { result in
                    switch result {
                    case .success(objects: let wallpapers):
                        // wallpapers 是包含满足条件的 (className: "Wallpaper") 对象的数组
                        
                        let wallpaper = wallpapers.randomElement()
                        
                        if let wallpaper_image = wallpaper?.get("image") as? LCFile {
                            //let imgData = photoData.value as! LCData
                            let url = URL(string: wallpaper_image.url?.value as! String)!
                            let data = try? Data(contentsOf: url)
                            print(url)
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                let imageFileURL = getDocumentsDirectory().appendingPathComponent("theme_download.jpg")
                                try? image!.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
                                let word = wallpaper?.word as! LCString
                                let trans = wallpaper?.trans as! LCString
                                
                                current_wallpaper = Wallpaper(word: word.value as! String, trans: trans.value as! String, category: category)
                                
                                UserDefaults.standard.set(current_wallpaper.word, forKey: word_string)
                                UserDefaults.standard.set(current_wallpaper.trans, forKey: trans_string)
                                UserDefaults.standard.set(category, forKey: last_theme_category_string)
                                
                                DispatchQueue.main.async {
                                    self.wordLabel.text = current_wallpaper.word
                                    self.syncLabel.textColor = textColors[category]
                                    self.wordLabel.textColor = textColors[category]
                                    self.meaningLabel.text = current_wallpaper.trans
                                    self.meaningLabel.textColor = textColors[category]
                                    self.setButtonsColor(color: textColors[category] ?? UIColor.darkGray)
                                    self.todayImageView?.image = image
                                    self.shouldStopRotating = true
                                    self.syncLabel.alpha = 0.0
                                }
                            }
                        }
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
    
    
    override func viewWillAppear(_ animated: Bool){
        if let user = LCApplication.default.currentUser {
            let defaults = UserDefaults.standard
            let theme_category_exist = isKeyPresentInUserDefaults(key: theme_category_string)
            var theme_category  = 1
            if theme_category_exist{
                theme_category = defaults.integer(forKey: theme_category_string)
                let last_theme_category = defaults.integer(forKey: last_theme_category_string)
                if theme_category != last_theme_category{
                    todayImageView?.image = UIImage(named: "theme_\(theme_category)")
                    let wallpaper = default_wallpapers[theme_category - 1]
                    wordLabel.text = wallpaper.word
                    meaningLabel.text = wallpaper.trans
                    
                    syncLabel.textColor = textColors[theme_category]
                    wordLabel.textColor = textColors[theme_category]
                    meaningLabel.textColor = textColors[theme_category]
                    setButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
                    
                    self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
                    self.isRotating = true
                    self.syncLabel.alpha = 1.0
                    self.getTodayWallpaper(category: theme_category)
                }
                else{
                    let imageFileURL = getDocumentsDirectory().appendingPathComponent("theme_download.jpg")
                    do {
                        let imageData = try Data(contentsOf: imageFileURL)
                        todayImageView?.image = UIImage(data: imageData)
                    } catch {
                        print("Error loading image : \(error)")
                    }

                    
                    wordLabel.text = defaults.string(forKey: word_string)
                    meaningLabel.text = defaults.string(forKey: trans_string)
                    
                    syncLabel.textColor = textColors[theme_category]
                    wordLabel.textColor = textColors[theme_category]
                    meaningLabel.textColor = textColors[theme_category]
                    setButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
                }
            }
            else{
                defaults.set(theme_category, forKey: last_theme_category_string)
                current_wallpaper = default_wallpapers[theme_category - 1]
                defaults.set(current_wallpaper.word, forKey: word_string)
                defaults.set(current_wallpaper.trans, forKey: trans_string)
                
                wordLabel.text = current_wallpaper.word
                meaningLabel.text = current_wallpaper.trans
                
                syncLabel.textColor = textColors[theme_category]
                wordLabel.textColor = textColors[theme_category]
                meaningLabel.textColor = textColors[theme_category]
                setButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
            }
            
            
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
