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
import SwiftyJSON

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
    
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    
    
    @IBOutlet var themeBtn: UIButton!
    @IBOutlet var collectBtn: UIButton!
    @IBOutlet var statBtn: UIButton!
    @IBOutlet var settingBtn: UIButton!
    
    func updateUserPhoto() {
        if let userImage = loadPhoto(name_of_photo: "user_avatar.jpg") {
            self.userPhotoBtn.setImage(userImage, for: [])
        }
        else{
            self.getUserPhoto()
        }
    }
    
    @IBAction func saveWallpaperToLibray(_ sender: UIButton) {
        print(current_wallpaper_image)
        UIImageWriteToSavedPhotosAlbum(current_wallpaper_image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @IBAction func searchBtnTouched(_ sender: UIButton) {
        searchBar.alpha = 1
        searchBtn.alpha = 0
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "保存出错", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        else{
            let ac = UIAlertController(title: "保存成功!", message: "图片保存成功!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func setTextOrButtonsColor(color: UIColor) {
        syncLabel.textColor = color
        wordLabel.textColor = color
        meaningLabel.textColor = color
        themeBtn.tintColor = color
        collectBtn.tintColor = color
        statBtn.tintColor = color
        settingBtn.tintColor = color
        searchBtn.tintColor = color
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if shouldStopRotating == false {
            self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
        }
        else{
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
        searchBar.backgroundColor = UIColor.clear
        if let user = LCApplication.default.currentUser {
            syncLabel.alpha = 0
            // 跳到首页
            fetchBooks()
            if let userImage = loadPhoto(name_of_photo: "user_avatar.jpg") {
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
                        if let image = UIImage(data: imageData){
                            savePhoto(image: image, name_of_photo: "user_avatar.jpg")
                            DispatchQueue.main.async {
                                // qos' default value is ´DispatchQoS.QoSClass.default`
                                self.userPhotoBtn.setImage(image, for: [])
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }

            
        }

    }
    
    func getTodayWallpaper(category: Int){
        do{ //DispatchQueue.global(qos: .background).async
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
                                if let image = UIImage(data: imageData){
                                    savePhoto(image: image, name_of_photo: "theme_download.jpg")
                                    current_wallpaper_image = image ?? UIImage()
                                    DispatchQueue.main.async {
                                        self.todayImageView?.image = image
                                    }
                                }
                                
                                let word = wallpaper?.word as! LCString
                                let trans = wallpaper?.trans as! LCString
                                
                                current_wallpaper = Wallpaper(word: word.value as! String, trans: trans.value as! String, category: category)
                                
                                UserDefaults.standard.set(current_wallpaper.word, forKey: word_string)
                                UserDefaults.standard.set(current_wallpaper.trans, forKey: trans_string)
                                UserDefaults.standard.set(category, forKey: last_theme_category_string)
                                
                                DispatchQueue.main.async {
                                    self.wordLabel.text = current_wallpaper.word
                                    self.meaningLabel.text = current_wallpaper.trans
                                    self.setTextOrButtonsColor(color: textColors[category] ?? UIColor.darkGray)
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
    
    func setWallpaper(){
        let defaults = UserDefaults.standard
        let theme_category_exist = isKeyPresentInUserDefaults(key: theme_category_string)
        var theme_category  = 1
        if theme_category_exist{
            theme_category = defaults.integer(forKey: theme_category_string)
            let last_theme_category = defaults.integer(forKey: last_theme_category_string)
            if theme_category != last_theme_category{
                let image = UIImage(named: "theme_\(theme_category)")
                todayImageView?.image = image
                current_wallpaper_image = image ?? UIImage()
                let wallpaper = default_wallpapers[theme_category - 1]
                wordLabel.text = wallpaper.word
                meaningLabel.text = wallpaper.trans
                
                setTextOrButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
                
                self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
                self.isRotating = true
                self.syncLabel.alpha = 1.0
                self.getTodayWallpaper(category: theme_category)
            }
            else{
                let imageFileURL = getDocumentsDirectory().appendingPathComponent("theme_download.jpg")
                do {
                    let imageData = try Data(contentsOf: imageFileURL)
                    let image = UIImage(data: imageData)
                    todayImageView?.image = image
                    current_wallpaper_image = image ?? UIImage()
                } catch {
                    print("Error loading image : \(error)")
                }
                let word = defaults.string(forKey: word_string)
                let trans = defaults.string(forKey: trans_string)
                wordLabel.text = word
                meaningLabel.text = trans
                current_wallpaper = Wallpaper(word: word!, trans: trans!, category: theme_category)
                
                setTextOrButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
            }
        }
        else{
            defaults.set(theme_category, forKey: last_theme_category_string)
            current_wallpaper = default_wallpapers[theme_category - 1]
            
            defaults.set(current_wallpaper.word, forKey: word_string)
            defaults.set(current_wallpaper.trans, forKey: trans_string)
            
            let image = UIImage(named: "theme_\(theme_category)")
            todayImageView?.image = image
            current_wallpaper_image = image ?? UIImage()
            
            wordLabel.text = current_wallpaper.word
            meaningLabel.text = current_wallpaper.trans
            
            setTextOrButtonsColor(color: textColors[theme_category] ?? UIColor.darkGray)
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        if let user = LCApplication.default.currentUser {
            self.setWallpaper()
            self.updateUserPhoto()
            uploadRecordsIfNeeded()
            syncRecords()
            }
        else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    
    func loadLearnController(){
        current_book_id = UserDefaults.standard.object(forKey: "current_book") as! String
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Learning", bundle:nil)
        let learnVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnWordController") as! LearnWordViewController
        learnVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(learnVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ReciteNewWords(_ sender: UIButton) {
        let current_book_key = "current_book"
        let current_book_exist = isKeyPresentInUserDefaults(key: current_book_key)
        if !current_book_exist{
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
            booksVC.modalPresentationStyle = .fullScreen
            booksVC.mainPanelViewController = self
            DispatchQueue.main.async {
                self.present(booksVC, animated: true, completion: nil)
            }
        }
        else{
            loadLearnController()
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
