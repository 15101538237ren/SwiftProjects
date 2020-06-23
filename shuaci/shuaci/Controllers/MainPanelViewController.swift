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
    var mp3Player: AVAudioPlayer?
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
    
    @IBAction func searchBtnTouched(_ sender: UIButton) {
        
    }
    
    func downloadBookJson(completionHandler: @escaping CompletionHandler){
        if fileExist(fileFp: "current_book.json"){
            completionHandler(true)
        }
        else{
            DispatchQueue.global(qos: .background).async {
            do {
                DispatchQueue.main.async {
                    self.syncLabel.text = "正在下载词书..."
                }
                let bookId:String = getPreference(key: "current_book_id") as! String
                let query = LCQuery(className: "Book")
                query.whereKey("identifier", .equalTo(bookId))
                _ = query.getFirst() { result in
                    switch result {
                    case .success(object: let result):
                        if let bookJson = result.get("data") as? LCFile {
                            let url = URL(string: bookJson.url?.stringValue ?? "")!
                            let data = try? Data(contentsOf: url)
                            
                            if let jsonData = data {
                                savejson(fileName: "current_book", jsonData: jsonData)
                                currentbook_json_obj = load_json(fileName: "current_book")
                                update_words()
                                get_words()
                                completionHandler(true)
                            }
                        }
                    case .failure(error: let error):
                        print(error.localizedDescription)
                        completionHandler(false)
                    }
                }
                
                }
            }
        }
    }
    
    func loadSettingAndRecords(){
        DispatchQueue.main.async {
            self.syncLabel.alpha = 1.0
            self.syncLabel.text = "正在同步数据..."
            self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
        }
        
        prepareRecordsAndPreference(completionHandler: {success in
            if success{
                self.downloadBookJson(completionHandler: { success in
                    if success{
                        self.loadSettingAndRecordsFinished()
                    }
                    else{
                        let ac = UIAlertController(title: "提示", message: "下载正在学的单词书失败，请检查您的网络!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                    }
                })
            }
            else{
                let ac = UIAlertController(title: "提示", message: "从云端下载设置与学习记录失败，请检查您的网络!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
    func loadSettingAndRecordsFinished(){
        DispatchQueue.main.async {
            self.shouldStopRotating = true
            self.syncLabel.alpha = 0.0
        }
        setWallpaper()
        get_words()
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        else{
            let ac = UIAlertController(title: "提示", message: "图片保存成功!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func setTextOrButtonsColor(color: UIColor) {
        DispatchQueue.main.async {
            self.syncLabel.textColor = color
            self.wordLabel.textColor = color
            self.meaningLabel.textColor = color
            self.themeBtn.tintColor = color
            self.collectBtn.tintColor = color
            self.statBtn.tintColor = color
            self.settingBtn.tintColor = color
            self.searchBtn.tintColor = color
        }
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
        if let _ = LCApplication.default.currentUser {
            syncLabel.alpha = 0
            // 跳到首页
            GlobalUserName = getUserName()
            loadSettingAndRecords()
            if let userImage = loadPhoto(name_of_photo: "user_avatar.jpg") {
                self.userPhotoBtn.setImage(userImage, for: [])
            }
            else {
                self.getUserPhoto()
            }
            updateWallpaperWhenBackScreen()
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateWallpaperWhenBackScreen), name: UIApplication.willEnterForegroundNotification, object: nil)
        } else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    
    
    
    func getUserPhoto(){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
                do {
                    let user = LCApplication.default.currentUser
                    if let photoData = user?.get("avatar") as? LCFile {
                        //let imgData = photoData.value as! LCData
                        let url = URL(string: photoData.url?.stringValue ?? "")!
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
                    print(error.localizedDescription)
                }
            }
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }

    }
    
    func getTodayWallpaper(category: Int){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async{
            do{ //
                do {
                    
                    let count_query = LCQuery(className: "Wallpaper")
                    count_query.whereKey("theme_category", .equalTo(category))
                    count_query.count{ count in
                        let count = count.intValue
                        let rand_index = Int.random(in: 0 ... count - 1)
                        let query = LCQuery(className: "Wallpaper")
                        query.whereKey("theme_category", .equalTo(category))
                        query.limit = 1
                        query.skip = rand_index
                        _ = query.getFirst { result in
                            switch result {
                            case .success(object: let wallpaper):
                                // wallpapers 是包含满足条件的 (className: "Wallpaper") 对象的数组
                                
                                if let wallpaper_image = wallpaper.get("image") as? LCFile {
                                    //let imgData = photoData.value as! LCData
                                    let url = URL(string: wallpaper_image.url?.stringValue ?? "")!
                                    let data = try? Data(contentsOf: url)
                                    if let imageData = data {
                                        if let image = UIImage(data: imageData){
                                            savePhoto(image: image, name_of_photo: "theme_download.jpg")
                                            DispatchQueue.global(qos: .background).async {
                                            do {
                                                DispatchQueue.main.async {
                                                    self.todayImageView?.image = image
                                                    }
                                                }}
                                        }
                                        
                                        let word = wallpaper.word?.stringValue
                                        let trans = wallpaper.trans?.stringValue
                                        
                                        UserDefaults.standard.set(word, forKey: "word")
                                        UserDefaults.standard.set(trans, forKey: "trans")
                                        setPreference(key: "last_theme_category", value: category, saveToCloud: false)
                                        
                                        DispatchQueue.main.async {
                                            self.wordLabel.text = word
                                            self.meaningLabel.text = trans
                                            self.shouldStopRotating = true
                                            self.syncLabel.alpha = 0.0
                                        }
                                        UserDefaults.standard.set(Date(), forKey: "lastUpdateTime")
                                        self.setTextOrButtonsColor(color: textColors[category] ?? UIColor.darkGray)
                                    }
                                }
                                break
                            case .failure(error: let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                }
                }}
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
            DispatchQueue.main.async {
                self.shouldStopRotating = true
                self.syncLabel.alpha = 0.0
            }
        }
    }
    
    @objc func updateWallpaperWhenBackScreen(){
        let lastUpdateTimeKey:String = "lastUpdateTime"
        var lastUpdateTime = Date()
        if isKeyPresentInUserDefaults(key: lastUpdateTimeKey){
            lastUpdateTime = UserDefaults.standard.object(forKey: lastUpdateTimeKey) as! Date
        }
        else
        {
            UserDefaults.standard.set(lastUpdateTime, forKey: lastUpdateTimeKey)
        }
        
        if minutesBetweenDates(lastUpdateTime, Date()) > 30 {
            let current_theme_category = getPreference(key: "current_theme_category") as! Int
            DispatchQueue.main.async {
                self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
                self.isRotating = true
                self.syncLabel.alpha = 1.0
                self.syncLabel.text = "正在更新壁纸..."
            }
            self.getTodayWallpaper(category: current_theme_category)
        }
        
    }
    
    func setWallpaper(){
        var current_theme_category:Int = 4
        var last_theme_category:Int = 4
        if let current_category = getPreference(key: "current_theme_category") as? Int {
            current_theme_category = current_category
            last_theme_category = getPreference(key: "last_theme_category") as! Int
        }
        
        if current_theme_category != last_theme_category{
            let image = UIImage(named: "theme_\(current_theme_category)")
            let wallpaper = default_wallpapers[current_theme_category - 1]
            DispatchQueue.global(qos: .background).async {
            do {
                DispatchQueue.main.async {
                    self.todayImageView?.image = image
                    self.wordLabel.text = wallpaper.word
                    self.meaningLabel.text = wallpaper.trans
                    self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
                    self.isRotating = true
                    self.syncLabel.alpha = 1.0
                    self.syncLabel.text = "正在更新壁纸..."
                }
            }}
            UserDefaults.standard.set(wallpaper.word, forKey: "word")
            UserDefaults.standard.set(wallpaper.trans, forKey: "trans")
            
            self.getTodayWallpaper(category: current_theme_category)
        }
        else{
            let word = UserDefaults.standard.string(forKey: "word")
            let imageFileURL = getDocumentsDirectory().appendingPathComponent("theme_download.jpg")
            do {
                let imageData = try Data(contentsOf: imageFileURL)
                let image = UIImage(data: imageData)
                let trans = UserDefaults.standard.string(forKey: "trans")
                DispatchQueue.global(qos: .background).async {
                do {
                    DispatchQueue.main.async {
                        self.todayImageView?.image = image
                        self.wordLabel.text = word
                        self.meaningLabel.text = trans
                    }
                }}
            } catch {
                print("Error loading image : \(error)")
                let image = UIImage(named: "theme_\(current_theme_category)")
                let wallpaper = default_wallpapers[current_theme_category - 1]
                DispatchQueue.global(qos: .background).async {
                do {
                    DispatchQueue.main.async {
                        self.todayImageView?.image = image
                        self.wordLabel.text = wallpaper.word
                        self.meaningLabel.text = wallpaper.trans
                    }
                }}
        }
        }
        setTextOrButtonsColor(color: textColors[current_theme_category] ?? UIColor.darkGray)
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        if let user = LCApplication.default.currentUser {
            setWallpaper()
            self.updateUserPhoto()
            get_words()
        }
        else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    
    func loadLearnController(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Learning", bundle:nil)
        let learnVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnWordController") as! LearnWordViewController
        learnVC.modalPresentationStyle = .overCurrentContext
        learnVC.mainPanelViewController = self
        DispatchQueue.main.async {
            self.present(learnVC, animated: true, completion: nil)
        }
    }
    
    func loadLearnFinishController(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Learning", bundle:nil)
        let learnFinishVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnFinishController") as! LearnFinishViewController
        learnFinishVC.mainPanelViewController = self
        learnFinishVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(learnFinishVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ReciteNewWords(_ sender: UIButton) {
        
        if let _ = getPreference(key: "current_book_id") as? String{
            loadLearnController()
        }
        else{
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
            booksVC.modalPresentationStyle = .fullScreen
            booksVC.mainPanelViewController = self
            DispatchQueue.main.async {
                self.present(booksVC, animated: true, completion: nil)
            }
        }
    }
    
    func loadReviewController(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Learning", bundle:nil)
        let reviewVC = mainStoryBoard.instantiateViewController(withIdentifier: "reviewWordController") as! ReviewWordViewController
        reviewVC.modalPresentationStyle = .overCurrentContext
        reviewVC.mainPanelViewController = self
        DispatchQueue.main.async {
            self.present(reviewVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ReviewWords(_ sender: UIButton) {
        if let _ = getPreference(key: "current_book_id") as? String{
            let vocab_rec_need_to_be_review:[VocabularyRecord] = get_vocab_rec_need_to_be_review()
            if vocab_rec_need_to_be_review.count > 0{
                loadReviewController()
            }
            else
            {
                let ac = UIAlertController(title: "提示", message: "您当前没有待复习的单词，放松一下吧😊", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
            }
        }
        else{
            let ac = UIAlertController(title: "提示", message: "您还没有选择单词书，请点击【学新词】选择!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func pernounce_word(_ sender: UITapGestureRecognizer) {
        if Reachability.isConnectedToNetwork(){
            let usphone = getUSPhone() == true ? 0 : 1
            let word:String = wordLabel.text ?? ""
            if word != ""{
                let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(word)"
                let mp3_url:URL = URL(string: url_string)!
                DispatchQueue.global(qos: .background).async {
                do {
                    var downloadTask: URLSessionDownloadTask
                    downloadTask = URLSession.shared.downloadTask(with: mp3_url, completionHandler: { (urlhere, response, error) -> Void in
                    if let urlhere = urlhere{
                        do {
                            self.mp3Player = try AVAudioPlayer(contentsOf: urlhere)
                            self.mp3Player?.play()
                        } catch {
                            print("couldn't load file :( \(urlhere)")
                        }
                    }
                })
                    downloadTask.resume()
                }}
            }
            
        }
        else {
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
    }
    
    func showLoginScreen() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let mainScreenViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "StartScreen") as! MainScreenViewController
        mainScreenViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(mainScreenViewController, animated: false, completion: nil)
        }
    }
//    
//    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue"{
            let destinationController = segue.destination as! UserProfileViewController
            destinationController.mainPanelViewController = self
            destinationController.modalPresentationStyle = .overCurrentContext
        }
        else if segue.identifier == "settingSegue"{
            let destinationController = segue.destination as! SettingViewController
            destinationController.modalPresentationStyle = .overCurrentContext
            destinationController.mainPanelViewController = self
        }
    }

}
