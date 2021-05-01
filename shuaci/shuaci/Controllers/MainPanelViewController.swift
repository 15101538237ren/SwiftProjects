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
import SwiftTheme
import Disk
import Nuke
import SwiftMessages
import PopMenu

class MainPanelViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - Constants
    let btnTag: Int = 7
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    
    // MARK: - Outlet Variables
    @IBOutlet var mainPanelUIView: MainPanelUIView!
    @IBOutlet var todayImageView: UIImageView!
    
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var syncLabel: UILabel!{
        didSet{
            syncLabel.alpha = 0.0
        }
    }
    
    @IBOutlet var themeBtn: UIButton!
    @IBOutlet var collectBtn: UIButton!
    @IBOutlet var statBtn: UIButton!
    @IBOutlet var settingBtn: UIButton!
    @IBOutlet var searchBtn: UIButton!
    
    @IBOutlet var learnBtn: UIButton!{
        didSet {
            learnBtn.layer.cornerRadius = 9.0
            learnBtn.layer.masksToBounds = true
            learnBtn.backgroundColor = .clear
        }
    }
    @IBOutlet var reviewBtn: UIButton!{
        didSet {
            reviewBtn.layer.cornerRadius = 9.0
            reviewBtn.layer.masksToBounds = true
            reviewBtn.backgroundColor = .clear
        }
    }
    
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    // MARK: - Variables
    var currentUser: LCUser!
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    var mp3Player: AVAudioPlayer?
    
    var isRotating = false
    var shouldStopRotating = false
    var preference:Preference? = nil
    var current_words:[JSON] = []
    
    enum ReviewMode{
        case ReviewRecent
        case ReviewHistory
    }
    
    // MARK: - View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    func popPrivacyMessage(){
        if !isKeyPresentInUserDefaults(key: privacyViewedKey){
            let messageView: TermsView = try! SwiftMessages.viewFromNib()
            messageView.configureDropShadow()
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            messageView.agreeAction = {
                UserDefaults.standard.set(true, forKey: privacyViewedKey)
                SwiftMessages.hide()
            }
            messageView.cancelAction = { UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)}
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            config.duration = .forever
            config.presentationStyle = .center
            config.dimMode = .blur(style: .light, alpha: 0.6, interactive: false)
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    // MARK: - Intiallization Functions
    
    func initVC(){
        popPrivacyMessage()
        if let user = currentUser{
            preference = loadPreference(userId: currentUser.objectId!.stringValue!)
            loadTheme()
            
            loadBooksNRecords()
            
            loadUserPhoto()
            setOnlineStatus(user: user, status: .online)
            NotificationCenter.default.addObserver(self, selector: #selector(backToOnline), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(goToOffline), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(goToOffline), name: UIApplication.willTerminateNotification, object: nil)
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let user = currentUser{
            setOnlineStatus(user: user, status: .offline)
        }
    }
    
    // MARK: - Outlet Actions
    
    @IBAction func searchBtnTouched(_ sender: UIButton) {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let searchVC = mainStoryBoard.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
        searchVC.preference = get_preference()
        searchVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(searchVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UI Functions
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
    
    func stopSelfIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.activityEffectView.alpha = 0
            self.activityLabel.alpha = 0
        }
    }
    
    func addBlurBtnView(){
        let blurEffect = getBlurEffect()
        let blurEffectViewforLearnBtn = UIVisualEffectView(effect: blurEffect)
        blurEffectViewforLearnBtn.isUserInteractionEnabled = false
        blurEffectViewforLearnBtn.frame = learnBtn.bounds
        blurEffectViewforLearnBtn.tag = btnTag
        blurEffectViewforLearnBtn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        learnBtn.insertSubview(blurEffectViewforLearnBtn, at: 0)
        
        let blurEffectViewforReviewBtn = UIVisualEffectView(effect: blurEffect)
        blurEffectViewforReviewBtn.frame = reviewBtn.bounds
        blurEffectViewforReviewBtn.isUserInteractionEnabled = false
        blurEffectViewforReviewBtn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectViewforReviewBtn.tag = btnTag
        reviewBtn.insertSubview(blurEffectViewforReviewBtn, at: 0)
    }
    
    @objc func updateBlurBtnView(){
        let blurEffect = getBlurEffect()
        if let learnBtnViewWithTag = learnBtn.viewWithTag(btnTag) {
            learnBtnViewWithTag.removeFromSuperview()
            let blurEffectViewforLearnBtn = UIVisualEffectView(effect: blurEffect)
            blurEffectViewforLearnBtn.isUserInteractionEnabled = false
            blurEffectViewforLearnBtn.frame = learnBtn.bounds
            blurEffectViewforLearnBtn.tag = btnTag
            blurEffectViewforLearnBtn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            learnBtn.insertSubview(blurEffectViewforLearnBtn, at: 0)
        }
        
        if let reviewBtnViewWithTag = reviewBtn.viewWithTag(btnTag) {
            reviewBtnViewWithTag.removeFromSuperview()
            let blurEffectViewforReviewBtn = UIVisualEffectView(effect: blurEffect)
            blurEffectViewforReviewBtn.frame = reviewBtn.bounds
            blurEffectViewforReviewBtn.isUserInteractionEnabled = false
            blurEffectViewforReviewBtn.tag = btnTag
            blurEffectViewforReviewBtn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            reviewBtn.insertSubview(blurEffectViewforReviewBtn, at: 0)
        }
    }
    
    func loadUserPhoto() {
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
            self.getUserPhoto()
            print(error)
        }
    }
    
    
    func loadTheme(){
        if let preference = preference{
            let theme_category = preference.current_theme
            ThemeManager.setTheme(plistName: theme_category_to_name[theme_category]!.rawValue, path: .mainBundle)
            
            loadWallpaper()
            NotificationCenter.default.addObserver(self, selector: #selector(loadWallpaper), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            DispatchQueue.main.async {
                self.syncLabel.theme_textColor = "Global.textColor"
                self.wordLabel.theme_textColor = "Global.textColor"
                self.meaningLabel.theme_textColor = "Global.textColor"
                self.themeBtn.theme_tintColor = "Global.btnTintColor"
                self.collectBtn.theme_tintColor = "Global.btnTintColor"
                self.statBtn.theme_tintColor = "Global.btnTintColor"
                self.settingBtn.theme_tintColor = "Global.btnTintColor"
                self.searchBtn.theme_tintColor = "Global.btnTintColor"
                
                self.learnBtn.theme_setTitleColor("Global.btnTitleColor", forState: .normal)
                self.learnBtn.theme_tintColor = "Global.btnTintColor"
                
                self.reviewBtn.theme_setTitleColor("Global.btnTitleColor", forState: .normal)
                self.reviewBtn.theme_tintColor = "Global.btnTintColor"
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBlurBtnView),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
        addBlurBtnView()
    }
    
    @objc func backToOnline(){
        if let user = currentUser{
            setOnlineStatus(user: user, status: .online)
        }
    }
    
    @objc func goToOffline(){
        if let user = currentUser{
            setOnlineStatus(user: user, status: .offline)
        }
    }
    
    @objc func loadWallpaper(){
        if let preference = preference{
            let theme_category = preference.current_theme
            let wallpaper_fp = "current_wallpaper.jpg"
            if Disk.exists(wallpaper_fp, in: .documents)
            {
                do{
                    let current_wallpaper = try Disk.retrieve(wallpaper_fp, from: .documents, as: UIImage.self)
                    let trans = UserDefaults.standard.string(forKey: "trans")!
                    let word = UserDefaults.standard.string(forKey: "word")!
                    wallpaperNeedDisplay(image: current_wallpaper, word: word, meaning: trans)
                }catch{
                    setDefaultWallpaper(theme_category: theme_category)
                }
            }else{
                setDefaultWallpaper(theme_category: theme_category)
            }
            getNextWallpaper(category: theme_category)
        }
    }
    
    func startRotating(text: String){
        DispatchQueue.main.async {
            self.userPhotoBtn.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
            self.syncLabel.alpha = 1.0
            self.syncLabel.text = text
        }
    }
    
    func stopRotating(){
        DispatchQueue.main.async {
            self.shouldStopRotating = true
            self.syncLabel.alpha = 0.0
        }
    }
    
    func getNextWallpaper(category: Int){
        if Reachability.isConnectedToNetwork(){
            startRotating(text: downloadingWallpaperText)
            DispatchQueue.global(qos: .background).async{
            do{
                do {
                    let count_query = LCQuery(className: "Wallpaper")
                    
                    count_query.whereKey("theme_category", .equalTo(category))
                    
                    count_query.count{ count in
                    
                        let count = count.intValue
                        
                        if count > 0 {
                            let rand_index = Int.random(in: 0 ... count - 1)
                            
                            let query = LCQuery(className: "Wallpaper")
                            query.whereKey("theme_category", .equalTo(category))
                            query.limit = 1
                            query.skip = rand_index
                            
                            _ = query.getFirst { result in
                                switch result {
                                case .success(object: let wallpaper):
                                    if let file = wallpaper.get("image") as? LCFile {
                                        
                                        let imgUrl = URL(string: file.url!.stringValue!)!
                                        
                                        _ = ImagePipeline.shared.loadImage(
                                            with: imgUrl,
                                            completion: { [self] response in
                                                stopRotating()
                                                switch response {
                                                  case .failure:
                                                    break
                                                  case let .success(imageResponse):
                                                    let image = imageResponse.image
                                                    
                                                    let wallpaper_fp = "current_wallpaper.jpg"
                                                    
                                                    do {
                                                        try Disk.save(image, to: .documents, as: wallpaper_fp)
                                                        
                                                        print("Save Wallpaper Successful!")
                                                        
                                                        let word = wallpaper.get("word")?.stringValue
                                                        let trans = wallpaper.get("trans")?.stringValue
                                                        
                                                        UserDefaults.standard.set(word, forKey: "word")
                                                        UserDefaults.standard.set(trans, forKey: "trans")
                                                    } catch {
                                                        print(error)
                                                    }
                                                  }
                                            }
                                        )
                                    }
                                case .failure(error: let error):
                                    print(error.localizedDescription)
                                    self.stopRotating()
                                }
                            }
                        }
                    }
                    
                }
                }}
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            self.stopRotating()
        }
    }
    
    func wallpaperNeedDisplay(image: UIImage, word: String, meaning: String){
        DispatchQueue.main.async {
            self.todayImageView?.image = image
            self.wordLabel.text = word
            self.meaningLabel.text = meaning
            
            self.todayImageView?.setNeedsDisplay()
            self.wordLabel.setNeedsDisplay()
            self.meaningLabel.setNeedsDisplay()
        }
    }
    
    func setDefaultWallpaper(theme_category: Int){
        let image = UIImage(named: "theme_\(theme_category)") ?? UIImage()
        let wallpaper = default_wallpapers[theme_category - 1]
        wallpaperNeedDisplay(image: image, word: wallpaper.word, meaning: wallpaper.trans)
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
    
    func loadBooksNRecords(){
        loadRecords(currentUser: currentUser, completionHandler: { [self]
            success in
            
            if success{
                self.downloadCurrentBookJson(completionHandler: { success in
                    self.downloadHistoryBooks(completionHandler: {_ in })
                })
            }
            else{
                self.view.makeToast(downloadRecordFailedText, duration: 1.0, position: .center)
            }
        })
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
    
    func update_preference(){
        preference = loadPreference(userId: currentUser.objectId!.stringValue!)
    }
    
    func loadThemeController(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let themeVC = mainStoryBoard.instantiateViewController(withIdentifier: "themeVC") as! ThemeCollectionViewController
        themeVC.modalPresentationStyle = .overCurrentContext
        themeVC.currentUser = currentUser
        themeVC.preference = get_preference()
        themeVC.mainPanelViewController = self
        DispatchQueue.main.async {
            self.present(themeVC, animated: true, completion: nil)
        }
    }
    
    func loadWordHistoryVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let wordHistoryVC = mainStoryBoard.instantiateViewController(withIdentifier: "WordHistoryVC") as! WordHistoryViewController
        wordHistoryVC.modalPresentationStyle = .overCurrentContext
        wordHistoryVC.currentUser = currentUser
        wordHistoryVC.preference = get_preference()
        wordHistoryVC.mainPanelViewController = self
        DispatchQueue.main.async {
            self.present(wordHistoryVC, animated: true, completion: nil)
        }
    }
    
    func loadLearnController(){
        initIndicator(view: self.view)
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let learnVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnWordController") as! LearnWordViewController
        learnVC.modalPresentationStyle = .overCurrentContext
        learnVC.currentUser = currentUser
        let pref = get_preference()
        learnVC.preference = pref
        learnVC.words = get_words(currentUser: currentUser, preference: pref)
        learnVC.currentMode = 1
        learnVC.vocab_rec_need_to_be_review = []
        learnVC.mainPanelViewController = self
        DispatchQueue.main.async {
            self.present(learnVC, animated: true, completion: nil)
        }
    }
    
    func loadReviewController(vocab_rec_need_to_be_review: [VocabularyRecord]){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let learnVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnWordController") as! LearnWordViewController
        learnVC.modalPresentationStyle = .overCurrentContext
        learnVC.currentUser = currentUser
        learnVC.preference = get_preference()
        learnVC.mainPanelViewController = self
        learnVC.vocab_rec_need_to_be_review = vocab_rec_need_to_be_review
        
        let review_words = get_words_need_to_be_review(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
        learnVC.words = review_words
        learnVC.currentMode = 2
        DispatchQueue.main.async {
            self.present(learnVC, animated: true, completion: nil)
        }
    }
    
    func loadSetNumToReviewVC(vocab_rec_need_to_be_review: [VocabularyRecord]){
        if vocab_rec_need_to_be_review.count < 10{
            loadReviewController(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
        }
        else{
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let setNumOfReviewVC = mainStoryBoard.instantiateViewController(withIdentifier: "setNumOfReviewVC") as! SetNumOfReviewVC
            setNumOfReviewVC.modalPresentationStyle = .overCurrentContext
            setNumOfReviewVC.mainPanelViewController = self
            setNumOfReviewVC.vocab_rec_need_to_be_review = vocab_rec_need_to_be_review
            DispatchQueue.main.async {
                self.present(setNumOfReviewVC, animated: true, completion: nil)
            }
        }
    }
    
    func loadLearnOrReviewFinishController(vocabsLearned: [VocabularyRecord]){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let learnOrReviewFinishVC = mainStoryBoard.instantiateViewController(withIdentifier: "learnOrReviewFinishController") as! LearnOrReviewFinishViewController
        learnOrReviewFinishVC.mainPanelViewController = self
        learnOrReviewFinishVC.currentUser = currentUser
        learnOrReviewFinishVC.preference = preference
        let hasSetReminder:Bool = !(preference?.reminder_time == nil && !isKeyPresentInUserDefaults(key: everydayNotificationViewedKey))
        learnOrReviewFinishVC.modalPresentationStyle =  hasSetReminder ? .overCurrentContext: .fullScreen
        learnOrReviewFinishVC.vocabsLearned = vocabsLearned
        DispatchQueue.main.async {
            self.present(learnOrReviewFinishVC, animated: true, completion: nil)
        }
    }
    
    func loadBooksVC(NoBookSelected:Bool = false){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
        booksVC.modalPresentationStyle = .fullScreen
        booksVC.mainPanelViewController = self
        booksVC.currentUser = currentUser
        booksVC.preference = get_preference()
        DispatchQueue.main.async {
            self.present(booksVC, animated: true, completion: {
                if NoBookSelected{
                    booksVC.view.makeToast(noBookSelectedText, duration: 1.0, position: .center)
                }
            })
        }
    }
    
    @IBAction func themeBtnClicked(_ sender: UIButton) {
        loadThemeController()
    }
    
    @IBAction func wordHistoryBtnClicked(_ sender: UIButton) {
        loadWordHistoryVC()
    }
    
    func loadMembershipVC(hasTrialed: Bool){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let membershipVC = mainStoryBoard.instantiateViewController(withIdentifier: "membershipVC") as! MembershipVC
        membershipVC.modalPresentationStyle = .overCurrentContext
        membershipVC.currentUser = currentUser
        membershipVC.hasFreeTrialed = hasTrialed
        DispatchQueue.main.async {
            self.present(membershipVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ReciteNewWords(_ sender: UIButton) {
        initIndicator(view: self.view)
        checkIfVIPSubsciptionValid(successCompletion: { [self] in
            stopIndicator()
            if let preference = preference{
                if let _ : String = preference.current_book_id{
                    loadLearnController()
                }else{
                    loadBooksVC(NoBookSelected: true)
                }
            }
            else{
                loadBooksVC(NoBookSelected: true)
            }}, failedCompletion: { [self] in
                
                fetchFreeTrailed(currentUser: currentUser, completionHandler: { [self] success in
                    loadMembershipVC(hasTrialed: success)
                })
                
            })
    }
    
    
    func ReviewWords(reviewMode: ReviewMode) {
        initIndicator(view: self.view)
        checkIfVIPSubsciptionValid(successCompletion: { [self] in
            stopIndicator()
            if let preference = preference{
                if let _ : String = preference.current_book_id{
                    if reviewMode == .ReviewHistory{
                        let vocab_rec_need_to_be_review:[VocabularyRecord] = get_vocab_rec_need_to_be_review()
                        if vocab_rec_need_to_be_review.count > 1{
                            loadSetNumToReviewVC(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
                        }else
                        {
                            self.view.makeToast(noVocabToReviewText, duration: 1.0, position: .center)
                        }
                    }
                    else{
                        let vocab_rec_need_to_be_review:[VocabularyRecord] = get_recent_vocab_rec_need_to_be_review()
                        
                        if vocab_rec_need_to_be_review.count > 1{
                            loadReviewController(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
                        }else
                        {
                            self.view.makeToast(noVocabToReviewText, duration: 1.0, position: .center)
                        }
                    }
                    
                }else{
                    loadBooksVC(NoBookSelected: true)
                }
            }
            else{
                loadBooksVC(NoBookSelected: true)
            }
        }, failedCompletion: { [self] in
            fetchFreeTrailed(currentUser: currentUser, completionHandler: { [self] success in
                loadMembershipVC(hasTrialed: success)
            })
        })
    }
    
    func downloadHistoryBooksJson(bookId:String, text: String){
        if !Disk.exists("\(bookId).json", in: .documents) {
            DispatchQueue.global(qos: .background).async {
            do {
                let query = LCQuery(className: "Book")
                query.whereKey("identifier", .equalTo(bookId))
                _ = query.getFirst() { result in
                    
                    switch result {
                    case .success(object: let result):
                        if let bookJson = result.get("data") as? LCFile {
                            let url = URL(string: bookJson.url?.stringValue ?? "")!
                            let data = try? Data(contentsOf: url)
                            
                            if let jsonData = data {
                                savejson(fileName: bookId, jsonData: jsonData)
                            }
                        }
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
                }
                }
            }
        }
    }
    
    func downloadHistoryBooks(completionHandler: @escaping CompletionHandler){
        let downloadText:String = downloadingBooksInHistoryText
        startRotating(text: downloadingBooksInHistoryText)
        var current_book_id = ""
        if let preference = preference{
            if let bookId = preference.current_book_id{
                current_book_id = bookId
            }
        }
        
        let bookSets:Set<String> = Set<String>(global_vocabs_records.map{ $0.BookId })
        var books_to_download:[String] = []
        for book_id in bookSets{
            if !Disk.exists("\(book_id).json", in: .documents) && book_id != current_book_id {
                books_to_download.append(book_id)
            }
        }
        
        for idx in 0..<books_to_download.count{
            let time_to_delay: Double = 0.5 * Double(idx)
            DispatchQueue.main.asyncAfter(deadline: .now() + time_to_delay) { [self] in
                downloadHistoryBooksJson(bookId: books_to_download[idx], text: downloadText)
            }
        }
        
        stopRotating()
    }
    
    func downloadCurrentBookJson(completionHandler: @escaping CompletionHandler){
        startRotating(text: syncingDataText)
        
        if let preference = preference{
            if let bookId: String = preference.current_book_id{
                if Disk.exists("\(bookId).json", in: .documents) {
                    if currentbook_json_obj.count == 0{
                        currentbook_json_obj = load_json(fileName: bookId)
                    }
                    self.stopRotating()
                    completionHandler(true)
                }
                else{
                    initActivityIndicator(text: downloadingBookText)
                    
                    DispatchQueue.global(qos: .background).async {
                    do {
                        let query = LCQuery(className: "Book")
                        query.whereKey("identifier", .equalTo(bookId))
                        _ = query.getFirst() { result in
                            
                            self.stopSelfIndicator()
                            self.stopRotating()
                            switch result {
                            case .success(object: let result):
                                if let bookJson = result.get("data") as? LCFile {
                                    let url = URL(string: bookJson.url?.stringValue ?? "")!
                                    let data = try? Data(contentsOf: url)
                                    
                                    if let jsonData = data {
                                        savejson(fileName: bookId, jsonData: jsonData)
                                        
                                        currentbook_json_obj = load_json(fileName: bookId)
                                        if let pref = self.preference{
                                            _ = update_words(preference: pref)
                                        }
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
            }else{
                stopRotating()
                completionHandler(false)
            }
            
        }else{
            stopRotating()
            completionHandler(false)
        }
    }
    
    func getThemeColor(key:String) -> UIColor{
        let color = UIColor(hex: ThemeManager.currentTheme?.value(forKeyPath: key) as! String) ?? .white
        return color
    }
    
    @IBAction func presentPopMenu(_ sender: UIButton) {
            let textColor = getThemeColor(key: "WordHistory.segTextColor")
            let iconWidthHeight:CGFloat = 20
            let reviewRecentAction = PopMenuDefaultAction(title: reviewJustLearnedText, image: UIImage(named: "book"), color: textColor)
            let reviewHistoryAction = PopMenuDefaultAction(title: reviewLearnedInHistoryText, image: UIImage(named: "history"), color: textColor)
        
            reviewRecentAction.iconWidthHeight = iconWidthHeight
            reviewHistoryAction.iconWidthHeight = iconWidthHeight
            
            let popActions: [PopMenuAction] = [reviewRecentAction, reviewHistoryAction]
            
            let menuVC = PopMenuViewController(sourceView:sender, actions: popActions)
            menuVC.delegate = self
            menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
            let menuBgColor = getThemeColor(key: "WordHistory.segCtrlTintColor")
            menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: menuBgColor)
            self.present(menuVC, animated: true, completion: nil)
        }
    
    @IBAction func pernounce_word(_ sender: UITapGestureRecognizer) {
        if let preference = preference{
            let usphone = preference.us_pronunciation ? 0 : 1
            if Reachability.isConnectedToNetwork(){
                
                let word:String = wordLabel.text ?? ""
                if word != ""{
                    let replaced_word = word.replacingOccurrences(of: " ", with: "+")
                    let url_string: String = "http://dict.youdao.com/dictvoice?type=\(usphone)&audio=\(replaced_word)"
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
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
        }
    }
    
    func get_preference() -> Preference{
        preference = loadPreference(userId: currentUser.objectId!.stringValue!)
        return preference!
    }
    
//    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue"{
            let destinationController = segue.destination as! UserProfileViewController
            destinationController.currentUser = currentUser
            destinationController.preference = get_preference()
            destinationController.mainPanelViewController = self
            destinationController.modalPresentationStyle = .fullScreen
        }
        else if segue.identifier == "settingSegue"{
            
            let destinationController = segue.destination as! SettingViewController
            destinationController.currentUser = currentUser
            destinationController.preference = get_preference()
            destinationController.mainPanelViewController = self
            destinationController.modalPresentationStyle = .overCurrentContext
        }
        
        else if segue.identifier == "showStatSeague"{
            
            let destinationController = segue.destination as! StatViewController
            
            destinationController.currentUser = currentUser
            destinationController.preference = get_preference()
            destinationController.mainPanelViewController = self
            destinationController.modalPresentationStyle = .overCurrentContext
        }
    }

}

extension MainPanelViewController: PopMenuViewControllerDelegate {

    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        var reviewMode:ReviewMode = .ReviewRecent
        if index == 1{
            reviewMode = .ReviewHistory
        }
        ReviewWords(reviewMode: reviewMode)
    }
}
