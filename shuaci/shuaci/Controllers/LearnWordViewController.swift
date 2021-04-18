//
//  LearnWordViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation
import SwiftyJSON
import LeanCloud
import SwiftTheme
import Disk
import Nuke
import ANLongTapButton

class LearnWordViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Constants
    let card_Y_constant:CGFloat = -30
    let animationDuration = 0.15
    let firstReviewDelayInMin = 30
    let progressViewAnimationDuration = 2.5
    var currentMode:Int! // 1: Learn, 2: Review
    var liveQuery: LiveQuery?
    var dispatchWork: DispatchWorkItem? = nil
    
    // MARK: - Variables
    var thumbnailURLs:[URL] = []
    private var wordsQueue: Array<[Int]> = []
    private var wordsQArray: Array<[Int]> = []
    private var DICT_URL: URL = Bundle.main.url(forResource: "DICT.json", withExtension: nil)!
    private var currentRec: Record?
    private var vocabRecordsOfCurrent:[VocabularyRecord] = []
    fileprivate var timeOnThisPage: Int = 0
    var userNumUpdateTimer: Timer?
    var userPhotoUpdateTimer: Timer?
    var vocab_rec_need_to_be_review:[VocabularyRecord]!
    
    var currentUser: LCUser!
    var preference:Preference!
    var mainPanelViewController: MainPanelViewController!
    var words:[JSON]!
    
    var secondsPST:Int = 0 // number of seconds past after load
    var card_behaviors:[Int: [Int]] = [:] //word index: Int , card Behavoirs[forget: 0, remember: 1, trash: 2\]
    var card_actions:[Int: [Int]] = [:] //word index: Int , card Behavoirs[forget: 0, remember: 1, trash: 2\]
    var card_behavior_dates:[Int: [Date]] = [:] //word index: Int , card Behavoirs[forget: 0, remember: 1, trash: 2\]
    
    var card_collect_behaviors: [CardCollectBehavior] = [] // card Behavoir: (collect: 1, else 0)
    
    var firstMemLeftNum: Int = 0
    var enToCNLeftNum: Int = 0
    var cnToENLeftNum: Int = 0
    
    var isCardBack: Bool = false //whether the card is front or back end
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    
    let userPanelDefaultBgColor:UIColor = UIColor(red: 225, green: 226, blue: 228, alpha: 1.0)
    let userPanelBgColorWhenQuit:UIColor = UIColor(red: 80, green: 80, blue: 80, alpha: 1.0)
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    var currentWordLabelQueue:Array<[Int]> = []
    var mastered:[Bool] = []
    var Word_indexs_In_Oalecd8:[String:[Int]] = [:]
    var totalCounter:Int = Int(countDownOfLoading + 1)
    
    // MARK: - Outlet Variables
    @IBOutlet var learnUIView: LearnUIView!
    @IBOutlet var backBtn: UIButton!{
        didSet{
            backBtn.setTitle(giveupText, for: .normal)
        }
    }
    @IBOutlet var backBtnForLoading: UIButton!{
        didSet{
            backBtnForLoading.setTitle(quitLearningText, for: .normal)
        }
    }
    
    @IBOutlet var gestureRecognizers:[UIPanGestureRecognizer]!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var userPanelView: UIView!{
        didSet{
            userPanelView.backgroundColor = userPanelDefaultBgColor
            userPanelView.alpha = 0
        }
    }
    
    @IBOutlet var giveupUIView: UIView!
    
    @IBOutlet var firstMemLeft: UILabel!
    @IBOutlet var enToCNLeft: UILabel!
    @IBOutlet var cnToENLeft: UILabel!
    
    @IBOutlet var leftAvatar: UIImageView!
    @IBOutlet var midAvatar: UIImageView!
    @IBOutlet var rightAvatar: UIImageView!
    @IBOutlet var userNumLabel: UILabel!
    @IBOutlet var peopleLabel: UILabel!{
        didSet{
            peopleLabel.text = userText
        }
    }
    @IBOutlet var learningLabel: UILabel!{
        didSet{
            learningLabel.text = learningLabelText
        }
    }
    @IBOutlet var mottoLabel: UILabel!{
        didSet{
            mottoLabel.text = defaultMotto
        }
    }
    
    @IBOutlet var mottoAuthorLabel: UILabel!{
        didSet{
            mottoAuthorLabel.text = ""
        }
    }
    @IBOutlet var countingDownLabel: UILabel!{
        didSet{
            countingDownLabel.alpha = 0
        }
    }
    
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    
    @IBOutlet var backgroundImgView: UIImageView!{
        didSet{
            let hour = Calendar.current.component(.hour, from: Date())
            let suffix:String  = (hour > 7 && hour < 18) ? "day" : "night"
            let lofiCount:Int = (hour > 7 && hour < 18) ? nDayLofiGirls : nNightLofiGirls
            let randomIndex = Int.random(in: 1...lofiCount)
            let imageName:String = "lofi_girls_\(suffix)_\(randomIndex)"
            print("LOFI:\(imageName)")
            backgroundImgView.image = UIImage(named: imageName)
        }
    }
    
    @IBOutlet var loadingView: UIView!
    
    @IBOutlet var readyStart: UILabel!{
        didSet{
            readyStart.text = readyStartText
        }
    }
    @IBOutlet var numText: UILabel!
    @IBOutlet var numLearnText: UILabel!
    @IBOutlet var numPeopleLearningLabel: UILabel!{
        didSet{
            numPeopleLearningLabel.text = numPeopleLearningText
        }
    }
    @IBOutlet var theText: UILabel!{
        didSet{
            theText.text = overduePreText
        }
    }
    
    
    @IBOutlet weak var giveupBtn: UIButton!{
        didSet {
            giveupBtn.layer.cornerRadius = giveupBtn.layer.frame.width/2.0
            giveupBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var continueBtn: UIButton!{
        didSet {
            continueBtn.layer.cornerRadius = continueBtn.layer.frame.width/2.0
            continueBtn.layer.masksToBounds = true
        }
    }
    
    
    @IBOutlet var timesLabel: UILabel!{
        didSet{
            timesLabel.text = timesLabelText
        }
    }
    @IBOutlet var learningText: UILabel!{
        didSet{
            learningText.text = currentMode == 1 ? learningStr : reviewStr
        }
    }
    
    func addBlurBackgroundView(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5
        backgroundImgView.insertSubview(blurEffectView, at: 0)
        
        let uiView = UIView(frame: giveupUIView.bounds)
        uiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        uiView.alpha = 0.95
        uiView.backgroundColor = UIColor(red: 40, green: 40, blue: 40, alpha: 1)
        giveupUIView.insertSubview(uiView, at: 0)
    }
    
    func getMotto(){
        DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Motto")
            let record_count = query.count().intValue
            if record_count > 2{
                let index = Int.random(in: 0...(record_count - 2))
                query.skip = index
                _ = query.getFirst() { result in
                    switch result {
                    case .success(object: let result):
                        DispatchQueue.main.async {
                            if let motto = result.get("EN")?.stringValue{
                                let splits = motto.components(separatedBy: "——").map {String($0)}
                                if splits.count == 2{
                                    self.mottoLabel.text = splits[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                    self.mottoAuthorLabel.text = "——\(splits[1].trimmingCharacters(in: .whitespacesAndNewlines))"
                                }else{
                                    self.mottoLabel.text = motto
                                }
                                
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
    
    func load_DICT(){
        do {
           let data = try Data(contentsOf: DICT_URL, options: [])//.mappedIfSafe
            let key_arr = try JSON(data: data)["keys"].arrayValue
            let oalecd8_arr = try JSON(data: data)["oalecd8"].arrayValue
            for kid in 0..<key_arr.count{
                let key = key_arr[kid].stringValue
                Word_indexs_In_Oalecd8[key] = [kid, oalecd8_arr[kid].intValue]
            }
           print("Load \(DICT_URL) successful!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCardActionColor(cardBehavior: CardBehavior) -> UIColor{
        var themeKeyPath:String = ""
        switch cardBehavior {
        case .remember:
            themeKeyPath = "LearningVC.RememberBgColor"
        case .forget:
            themeKeyPath = "LearningVC.ForgetBgColor"
        case .trash:
            themeKeyPath = "LearningVC.MasteredBgColor"
        }
        
        let cardBgColor = ThemeManager.currentTheme?.value(forKeyPath: themeKeyPath) as! String
        return UIColor(hex: cardBgColor) ?? .systemGreen
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_setTitleColor("Global.backBtnTintColor", forState: .normal)
        backBtnForLoading.theme_tintColor = "Global.backBtnTintColor"
        super.viewDidLoad()
        stopIndicator()
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToOnline), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToOffline), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToOffline), name: UIApplication.willTerminateNotification, object: nil)
        
        addBlurBackgroundView()
        updateNumOfLearn()
        startCountDown()
        initLearningRecord()
        setOnlineStatus(user: currentUser, status: currentMode == 1 ? .learning : .reviewing)
        updateNumOfUsersOnline()
        updateOnlineUsersPhoto()
        updateUserPhoto()
        userNumUpdateTimer = Timer.scheduledTimer(timeInterval: numOfUerUpdateInterval, target: self, selector: #selector(updateNumOfUsersOnline), userInfo: nil, repeats: true)
        userPhotoUpdateTimer = Timer.scheduledTimer(timeInterval: userPhotoUpdateInterval, target: self, selector: #selector(updateUserPhotosOnline), userInfo: nil, repeats: true)
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        load_DICT()
        getMotto()
    }
    
    func countDownText(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            totalCounter -= Int(1)
            if totalCounter == 5{
                DispatchQueue.main.async {
                    self.readyStart.alpha = 0
                    self.countingDownLabel.alpha = 1
                    self.countingDownLabel.text = "\(totalCounter)"
                }
            }else if (totalCounter < 5) && (totalCounter > 0){
                DispatchQueue.main.async {
                    self.countingDownLabel.text = "\(totalCounter)"
                }
            }else if totalCounter < 0{
                timer.invalidate()
            }
        }
    }
    
    @objc func startCountDown(){
        dispatchWork = DispatchWorkItem(block: {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.loadingView.alpha = 0
            }, completion: { _ in
                self.startLearning()
            })
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + countDownOfLoading, execute: dispatchWork!)
        countDownText()
    }
    
    func getTimeSuffix(num: Int) -> String{
        let remain:Int = num % 10
        if remain == 1{
            return "st"
        }else if remain == 2{
            return "nd"
        }else if remain == 3{
            return "rd"
        }else{
            return "th"
        }
    }
    
    func updateNumOfLearn() {
        let numOfLearn: Int = global_records.filter { $0.recordType == currentMode }.count + 1
        let numStr:String = NSLocale.preferredLanguages.first!.contains("en") ? "\(numOfLearn)\(getTimeSuffix(num: numOfLearn))": "\(numOfLearn)"
        DispatchQueue.main.async {
            self.numLearnText.text = numStr
        }
    }
    
    @objc func backToOnline(){
        let onlineStatus:OnlineStatus = currentMode == 1 ? .learning : .reviewing
        setOnlineStatus(user: currentUser, status: onlineStatus)
    }
    
    @objc func goToOffline(){
        setOnlineStatus(user: currentUser, status: .offline)
    }
    
    func updateNumber(){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async { [self] in
            do {
                let query = LCQuery(className: "_User")
                query.whereKey("online", .greaterThanOrEqualTo(1))
                let count = query.count().intValue
                if count >= 3{
                    DispatchQueue.main.async {
                        self.userPanelView.alpha = 1.0
                        self.userNumLabel.text = "\(count)"
                        self.numText.text = "\(count)"
                    }
                }else{
                    DispatchQueue.main.async {
                        self.userPanelView.alpha = 0.0
                        self.userNumLabel.text = "\(count)"
                        self.numText.text = "\(count)"
                    }
                }
            }
        }
        }
    }
    
    @objc func updateNumOfUsersOnline(){
        updateNumber()
    }
    
    @objc func updateUserPhotosOnline(){
        if thumbnailURLs.count > 0{
            if thumbnailURLs.count == 1{
                Nuke.loadImage(with: thumbnailURLs[0], options: userPhotoLoadingOptions, into: midAvatar)
            }else{
                var selectedIndexs:[Int] = []
                for _ in 0..<2{
                    var randomIndex = Int.random(in: 0...(thumbnailURLs.count - 1))
                    while selectedIndexs.contains(randomIndex){
                        randomIndex = Int.random(in: 0...(thumbnailURLs.count - 1))
                    }
                    selectedIndexs.append(randomIndex)
                }
                
                for i in 0..<2{
                    if i == 0{
                        Nuke.loadImage(with: thumbnailURLs[selectedIndexs[i]], options: userPhotoLoadingOptions, into: leftAvatar)
                    }else{
                        Nuke.loadImage(with: thumbnailURLs[selectedIndexs[i]], options: userPhotoLoadingOptions, into: midAvatar)
                    }
                }
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        setOnlineStatus(user: currentUser, status: .offline)
        userNumUpdateTimer?.invalidate()
        userPhotoUpdateTimer?.invalidate()
        let pageName:String = currentMode == 1 ? "背单词" : "复习"
        let info = ["Um_Key_PageName": pageName, "Um_Key_Duration": timeOnThisPage, "Um_Key_UserID" : currentUser.objectId!.stringValue!] as [String : Any]
        
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    func updateOnlineUsersPhoto() {
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async { [self] in
                let query = LCQuery(className: "_User")
                query.whereKey("online", .greaterThanOrEqualTo(1))
                query.whereKey("avatar", .existed)
                query.whereKey("avatar", .included)
                query.limit = 10
                _ = query.find { result in
                    switch result {
                        case .success(objects: let users):
                            for user in users{
                                if user.objectId != currentUser.objectId{
                                    if let file = user.get("avatar") as? LCFile {
                                        if let sizedURL = file.thumbnailURL(.size(width: widthOfOnlineUserAvtarInLearningVC, height: widthOfOnlineUserAvtarInLearningVC)){
                                            thumbnailURLs.append(sizedURL)
                                        }
                                    }
                                }
                            }
                            updateUserPhotosOnline()
                        case .failure(error: let error):
                            print(error.localizedDescription)
                    }
                }
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    func updateUserPhoto() {
        let userId = currentUser.objectId!.stringValue!
        let avatar_fp = "user_avatar_\(userId).jpg"
        do {
            let retrievedImage = try Disk.retrieve(avatar_fp, from: .documents, as: UIImage.self)
            print("retrieved Avatar Successful!")
            DispatchQueue.main.async {
                self.rightAvatar.image = retrievedImage
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
                                    self.rightAvatar.image = image
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
    
    func initLearningRecord(){
        let uuids:[String] = global_records.map { $0.uuid}
        var uuid = UUID().uuidString
        
        while uuids.contains(uuid) {
            uuid = UUID().uuidString
        }
        
        currentRec = Record(uuid: uuid, recordType: currentMode, startDate: Date(), endDate: Date(), vocabHeads: [])
    }
    
    @objc func tictoc(){
        timeOnThisPage += 1
    }
    
    @objc func relayout(){
        for index in [currentIndex, currentIndex+1]{
            let word = words[index % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
            let card: CardUIView = cards[index % 2]
            DispatchQueue.main.async {
                if cardWord.memMethod != ""{
                    card.wordLabel_Top_Space_Constraint.constant = 130
                    card.meaningLabel_Top_Space_Constraint.constant = 50
                    card.memMethodLabel?.alpha = 1
                }
                else{
                    card.wordLabel_Top_Space_Constraint.constant = 170
                    card.meaningLabel_Top_Space_Constraint.constant = 70
                    card.memMethodLabel?.alpha = 0
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareScene()
    }
    
    func updateWordLeftLabels(currentMemStage: Int){
        DispatchQueue.main.async {

            self.firstMemLeft.theme_textColor = "LearningVC.TextLabelColor"
            self.enToCNLeft.theme_textColor = "LearningVC.TextLabelColor"
            self.cnToENLeft.theme_textColor = "LearningVC.TextLabelColor"
            
            switch currentMemStage{
                case WordMemStage.memory.rawValue:
                    if self.currentMode == 1{
                        self.firstMemLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                    }else{
                        self.enToCNLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                    }
                case WordMemStage.enToCn.rawValue:
                    if self.currentMode == 1{
                        self.enToCNLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                    }else{
                        self.firstMemLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                    }
                    
                case WordMemStage.cnToEn.rawValue:
                    self.cnToENLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                default:
                    print("Nothing")
            }
            let memText:String = self.currentMode == 1 ? "1. \(firstLearningText)" : "1. \(firstReviewText)"
            let firstNum = self.currentMode == 1 ? self.firstMemLeftNum : self.enToCNLeftNum
            let firstMemText = "\(memText)  \(firstNum)"
            var attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: firstMemText)
            if firstNum == 0{
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.firstMemLeft.attributedText = attributeString
            
            let secondNum = self.currentMode == 1 ? self.enToCNLeftNum : self.firstMemLeftNum
            let enToCNLeftText = self.currentMode == 1 ? "2. \(enToCnText)  \(secondNum)" : "2. \(reLearningText)  \(secondNum)"
            attributeString =  NSMutableAttributedString(string: enToCNLeftText)
            if firstNum == 0 && secondNum == 0{
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.enToCNLeft.attributedText = attributeString
            
            let cnToENLeftText = "3. \(cnToEnText)  \(self.cnToENLeftNum)"
            attributeString =  NSMutableAttributedString(string: cnToENLeftText)
            if firstNum == 0 &&  secondNum == 0 && self.cnToENLeftNum == 0 {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.cnToENLeft.attributedText = attributeString
        }
    }
    
    func initWordLeftNumbers(){
        firstMemLeftNum = currentMode == 1 ?  words.count : 0
        enToCNLeftNum = currentMode == 1 ?  0 : words.count
        cnToENLeftNum = 0
        let currentStage = currentMode == 1 ? WordMemStage.memory.rawValue : WordMemStage.enToCn.rawValue
        updateWordLeftLabels(currentMemStage : currentStage)
    }
    
    func prepareScene(){
        setCardBackground()
        initCards()
        initVocabRecords()
        initWordLeftNumbers()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)

        DispatchQueue.main.async {
            self.timeLabel.text = timeString(time: self.secondsPST)
        }
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(relayout),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }
    
    func startLearning(){
        let word: String = cards[currentIndex % 2].wordLabel?.text ?? ""
        playMp3GivenWord(word: word)
        let card = cards[0]
        if currentMode == 2{
            DispatchQueue.main.async {
                card.dragable = false
                self.disableBtns()
                UIView.animate(withDuration: self.progressViewAnimationDuration, animations: {
                    card.ringView?.progress = 1.0
                }) { (finished) in
                    card.ringView?.alpha = 0.0
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        card.meaningLabel?.alpha = 1.0
                        card.memMethodLabel?.alpha = 1.0
                    }, completion: {_ in
                        card.dragable = true
                        self.enableBtns()
                    })
                }
            }
        }
        startTimer()
    }
    
    
    @IBAction func close(sender: UIButton){
        dispatchWork?.cancel()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueLearning(sender: UIButton){
        DispatchQueue.main.async { [self] in
            giveupUIView.alpha = 0
            userPanelView.backgroundColor = userPanelDefaultBgColor
        }
    }
    
    @IBAction func giveupLearning(longTapButton: ANLongTapButton){
        
       longTapButton.didTimePeriodElapseBlock = { () -> Void in
            self.dismiss(animated: true, completion: nil)
      }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.mp3Player?.stop()
        
        DispatchQueue.main.async { [self] in
            learnUIView.bringSubviewToFront(giveupUIView)
            learnUIView.bringSubviewToFront(userPanelView)
            UIView.animate(withDuration: 0.5, animations: { [self] in
                giveupUIView.alpha = 1.0
                userPanelView.backgroundColor = userPanelBgColorWhenQuit
            }, completion: { _ in })
            
        }
    }
    
    
    func startTimer()
    {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.secondsPST += 1
            DispatchQueue.main.async {
                self.timeLabel.text = timeString(time: self.secondsPST)
            }
        }
    }
    
    func getRandomColor() -> String{
        return theme_card_colors[preference.current_theme]!.randomElement()!
    }
    
    func setCardBackground(){
        for card in cards{
            card.cardImageView?.image = UIImage(named: cardBackgrounds[preference.current_theme]!)
//            card.cardImageView?.image = UIImage()
//            card.cardImageView?.backgroundColor = UIColor.init(hex: getRandomColor())!
        }
    }
    
    @IBAction func flipCard(_ sender: Any) {
        let card = cards[currentIndex % 2]
        if isCardBack {
            isCardBack = false
            UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }else{
            isCardBack = true
            UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
        }
    }
    
    func playMp3GivenWord(word: String){
        let auto_pronunciation:Bool = preference.auto_pronunciation
        
        let mp3_url = getWordPronounceURL(word: word, us_pronounce: preference.us_pronunciation)
        if auto_pronunciation && (mp3_url != nil) {
            playMp3(url: mp3_url!)
        }
    }
    
    func initWordQueue(){
        let status = currentMode == 1 ? WordMemStage.memory.rawValue : WordMemStage.enToCn.rawValue
        for wid in 0..<words.count{
            wordsQueue.enqueue([wid, status])
        }
    }
    
    func initCards() {
        initWordQueue()
        for index in 0..<cards.count
        {
            let card = cards[index]
            card.dimUIView!.alpha = 0
            card.dimUIView!.theme_backgroundColor = "Global.viewBackgroundColor"
            card.cardBackView?.alpha = 0
            card.cardBackView?.isUserInteractionEnabled = false
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            let wordIndex: Int = wordsQueue[0][0]
            let memStage:Int = wordsQueue[0][1]
            let word = words[wordIndex]
            let wordQuequeItem = wordsQueue.dequeue()
            currentWordLabelQueue.enqueue(wordQuequeItem!)
            let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
            setFieldsOfCard(card: card, cardWord: cardWord, collected: false, memStage: memStage)
            if index == 1
            {
                card.dragable = false
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backToCardFront(_:)) )
            tapGesture.delegate = self
            card.cardBackView?.webView.addGestureRecognizer(tapGesture)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }
    
    @IBAction func cardTapped(_ sender: UITapGestureRecognizer)
    {
        let card = cards[currentIndex % 2]
        let current_word: String = card.wordLabel?.text ?? ""
        if current_word != ""{
            let indexItem:[Int] = Word_indexs_In_Oalecd8[current_word]!
            let wordIndex: Int = indexItem[0]
            let hasValueInOalecd8: Int = indexItem[1]
            if hasValueInOalecd8 == 1{
                UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                load_html(wordHead: current_word, wordIndex: wordIndex)
            }else{
                card.makeToast(noDictMeaningText, duration: 1.0, position: .center)
            }
        }
    }
    
    @IBAction func backToCardFront(_ sender: UITapGestureRecognizer) {
        let card = cards[currentIndex % 2]
        card.cardBackView!.isUserInteractionEnabled = false
        card.cardBackView!.alpha = 0
        card.dragable = true
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    @IBAction func cardBackTapped(_ sender: UITapGestureRecognizer)
    {
        let card = cards[currentIndex % 2]
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    
    
    func setFieldsOfCard(card: CardUIView, cardWord: CardWord, collected: Bool, memStage: Int){
        
        var meaningLabelTxt:String = cardWord.meaning
        var finalStringArr:[String] = []
        let meaningArr:[String] = meaningLabelTxt.components(separatedBy: "\n")
        if meaningArr.count > 1{
            for mi in 0..<meaningArr.count - 1{
                if let firstChr = meaningArr[mi + 1].unicodeScalars.first{
                    if firstChr.isASCII{
                        finalStringArr.append("\(meaningArr[mi])\n")
                    }else{
                        if mi == meaningArr.count - 2{
                            finalStringArr.append("\(meaningArr[mi])")
                        }
                        else{
                            finalStringArr.append("\(meaningArr[mi])；")
                        }
                    }
                }
            }
            meaningLabelTxt = finalStringArr.joined(separator: "")
        }
        card.wordLabel?.text = cardWord.headWord
        
        DispatchQueue.main.async {
            if cardWord.headWord.count >= 10{
                card.wordLabel?.font = card.wordLabel?.font.withSize(35.0)
            }else{
                card.wordLabel?.font = card.wordLabel?.font.withSize(45.0)
            }
            
            card.meaningLabel?.text = meaningLabelTxt
            
            if cardWord.memMethod != ""{
                card.wordLabel_Top_Space_Constraint.constant = 130
                card.meaningLabel_Top_Space_Constraint.constant = 50
                card.memMethodLabel?.alpha = 1
                card.memMethodLabel?.text = "记: \(cardWord.memMethod)"
            }
            else{
                card.wordLabel_Top_Space_Constraint.constant = 170
                card.meaningLabel_Top_Space_Constraint.constant = 70
                card.memMethodLabel?.alpha = 0
                card.memMethodLabel?.text = ""
            }
            
            if collected{
                card.collectImageView.alpha = 1
            }else{
                card.collectImageView.alpha = 0
            }
            
            if memStage == 1{
                card.ringView?.alpha = 0
                card.ringView?.progress = 0
                card.meaningLabel?.alpha = 1
                card.wordLabel?.alpha = 1
            }
            else if memStage == 2{
                card.ringView?.alpha = 1
                card.ringView?.progress = 0
                card.wordLabel?.alpha = 1
                card.meaningLabel?.alpha = 0
            } else if memStage == 3{
                card.ringView?.alpha = 1
                card.ringView?.progress = 0
                card.wordLabel?.alpha = 0
                card.meaningLabel?.alpha = 1
            }

            if memStage == 1 && cardWord.memMethod != ""{
                card.memMethodLabel?.alpha = 1
            }else{
                card.memMethodLabel?.alpha = 0
            }
        }
    }
    
    func initVocabRecords(){
        if let current_book_id:String =  preference.current_book_id
        {
            if currentMode == 1{
                vocabRecordsOfCurrent = []
                for index in 0..<words.count
                {
                    
                    let word = words[index % words.count]
                    let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
                    let vocabRecord: VocabularyRecord = VocabularyRecord.init(VocabHead: "\(cardWord.headWord)", BookId: current_book_id, LearnDate: nil, CollectDate: nil, Mastered: false, MasteredDate: nil, ReviewDUEDate: nil, BehaviorHistory: [], BehaviorDates: [])
                    
                    vocabRecordsOfCurrent.append(vocabRecord)
                    card_collect_behaviors.append(.no)
                    mastered.append(false)
                }
            }else{
                vocabRecordsOfCurrent = vocab_rec_need_to_be_review
                for index in 0..<words.count
                {
                    if let _ = vocab_rec_need_to_be_review[index].CollectDate {
                        card_collect_behaviors.append(.yes)
                    }
                    else{
                        card_collect_behaviors.append(.no)
                    }
                    mastered.append(vocab_rec_need_to_be_review[index].Mastered)
                    card_behaviors[index] = vocabRecordsOfCurrent[index].BehaviorHistory
                    card_behavior_dates[index] = vocabRecordsOfCurrent[index].BehaviorDates
                }
            }
            
        }
    }
    
    func get_reviewed_vocabRec()->[VocabularyRecord]{
        if currentMode == 1{
            return vocabRecordsOfCurrent
        }else{
            var reviewed_vocabRec:[VocabularyRecord] = []
            for index in 0..<vocabRecordsOfCurrent.count
            {
                if mastered[index] && !vocabRecordsOfCurrent[index].Mastered{
                    reviewed_vocabRec.append(vocabRecordsOfCurrent[index])
                    vocabRecordsOfCurrent[index].NumOfReview += 1
                    continue
                }
                if let bhvs = card_behaviors[index]{
                    if bhvs.count != vocabRecordsOfCurrent[index].BehaviorHistory.count{
                        
                        reviewed_vocabRec.append(vocabRecordsOfCurrent[index])
                        
                        vocabRecordsOfCurrent[index].NumOfReview += 1
                        continue
                    }
                }
            }
            return reviewed_vocabRec
        }
    }
    
    func summary_records_into_vocab_records(){
        
        currentRec!.endDate = Date()
        let reviewed_vocabRec = get_reviewed_vocabRec()
        for index in 0..<vocabRecordsOfCurrent.count
        {
            
            if currentMode == 1{
                vocabRecordsOfCurrent[index].LearnDate = Date()
            }
            
            if card_collect_behaviors[index] == .yes{
                vocabRecordsOfCurrent[index].CollectDate = Date()
            }
            
            if mastered[index] {
                vocabRecordsOfCurrent[index].Mastered = mastered[index]
                vocabRecordsOfCurrent[index].MasteredDate = Date()
            }
            
            if currentMode == 1{
                vocabRecordsOfCurrent[index].ReviewDUEDate =  Date().adding(durationVal: firstReviewDelayInMin, durationType: .minute)
            } else{
                if let bhvs = card_behaviors[index]{
                    if bhvs.count != vocabRecordsOfCurrent[index].BehaviorHistory.count{
                        
                        vocabRecordsOfCurrent[index].ReviewDUEDate = Date().adding(durationVal: calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: bhvs), durationType: .second)
                    }
                }
            }
            
            if let bhvs = card_behaviors[index]{
                vocabRecordsOfCurrent[index].BehaviorHistory = bhvs
            }
            
            if let bhvs_dates = card_behavior_dates[index]{
                vocabRecordsOfCurrent[index].BehaviorDates = bhvs_dates
            }
        }
        
        currentRec!.vocabHeads = reviewed_vocabRec.map {$0.VocabHead}
    }
    
    func saveRecordsFromLearning() {
        global_records.append(currentRec!)
        print(global_records.count)
        print(global_records)
        if currentMode == 1{
            global_vocabs_records.append(contentsOf: vocabRecordsOfCurrent)
        }else{
            updateGlobalVocabRecords(vocabs_updated: vocabRecordsOfCurrent)
        }
        
        saveRecordsToDisk(userId: currentUser.objectId!.stringValue!)
        saveRecordsToCloud(currentUser: currentUser)
        saveVocabRecordsToCloud(currentUser: currentUser)
    }
    
    @objc func moveCard(behavior: NSNumber) {
        self.mp3Player?.stop()
        let wordQuequeItem = currentWordLabelQueue.dequeue()!
        let wordIndex: Int = wordQuequeItem[0]
        let memStage:Int = wordQuequeItem[1]
        
        let masteredAction: Bool = mastered[wordIndex]
        
        let bhv:Int = behavior.intValue
        
        wordsQArray.enqueue([wordIndex, memStage, bhv]) // record Stage Behavior
        
        switch memStage {
            case WordMemStage.memory.rawValue:
                firstMemLeftNum -= 1
            case WordMemStage.enToCn.rawValue:
                enToCNLeftNum -= 1
            case WordMemStage.cnToEn.rawValue:
                cnToENLeftNum -= 1
            default:
                print("Nothing")
        }
        
        self.updateWordLeftLabels(currentMemStage: memStage)
        
        if !masteredAction {
            let cardAction: Int = card_actions[wordIndex]!.last!
            if !(memStage == WordMemStage.cnToEn.rawValue && cardAction == CardBehavior.remember.rawValue){
                var nextStage = WordMemStage.memory.rawValue
                if memStage == WordMemStage.memory.rawValue{
                    if currentMode == 1{ // Learning Mode
                        nextStage = WordMemStage.enToCn.rawValue
                    }else{
                        // Review Mode: E->CN, Review*, CN-> EN
                        if cardAction == CardBehavior.remember.rawValue{
                            nextStage = WordMemStage.cnToEn.rawValue
                        }else {
                            nextStage = WordMemStage.memory.rawValue
                        }
                    }
                }
                else if memStage == WordMemStage.enToCn.rawValue{
                    if currentMode == 1{
                        if cardAction == CardBehavior.forget.rawValue{
                            nextStage = WordMemStage.enToCn.rawValue
                        }else if cardAction == CardBehavior.remember.rawValue{
                            nextStage = WordMemStage.cnToEn.rawValue
                        }
                    }else{
                        // Review Mode: E->CN*, Review, CN-> EN
                        nextStage = WordMemStage.memory.rawValue
                    }
                }
                else{
                    if cardAction == CardBehavior.forget.rawValue{
                        nextStage = memStage
                    }else if cardAction == CardBehavior.remember.rawValue{
                        nextStage = memStage + 1
                    }
                }
                switch nextStage {
                    case WordMemStage.memory.rawValue:
                        firstMemLeftNum += 1
                    case WordMemStage.enToCn.rawValue:
                        enToCNLeftNum += 1
                    case WordMemStage.cnToEn.rawValue:
                        cnToENLeftNum += 1
                    default:
                        print("Nothing")
                }
                wordsQueue.enqueue([wordIndex, nextStage])
            }
        }
        
        if wordsQueue.count > 0{
            let wordQuequeItem = wordsQueue.dequeue()
            currentWordLabelQueue.enqueue(wordQuequeItem!)
        }
        
        if wordsQueue.count == 0 && currentWordLabelQueue .count == 0{
            
            summary_records_into_vocab_records()
            saveRecordsFromLearning()
            if currentMode == 1{
                _ = update_words(preference: preference)
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.mainPanelViewController.loadLearnOrReviewFinishController(vocabsLearned: self.vocabRecordsOfCurrent)
            }
        }else{
            let card = cards[(currentIndex - 1) % 2]
            resetCard(card: card)
            card.dragable = !card.dragable
            enableBtns()
            
            let next_card = cards[currentIndex % 2]
            next_card.dimUIView!.theme_alpha = "MainPanel.dimAlpha"
            learnUIView.bringSubviewToFront(next_card)
            next_card.dragable = !next_card.dragable
            
            let wordQuequeItem = currentWordLabelQueue.first!
            let memStageCurrent: Int = wordQuequeItem[1]
            
            if memStageCurrent == WordMemStage.enToCn.rawValue {
                DispatchQueue.main.async {
                    next_card.ringView?.alpha = 1
                    next_card.dragable = false
                    self.disableBtns()
                    UIView.animate(withDuration: self.progressViewAnimationDuration, animations: {
                        next_card.ringView?.progress = 1.0
                    }) { (finished) in
                        // fade out
                        next_card.ringView?.alpha = 0.0
                        
                        UIView.animate(withDuration: 1.0, animations: {
                            next_card.meaningLabel!.alpha = 1.0
                            next_card.memMethodLabel!.alpha = 1.0
                        }, completion: {_ in
                            next_card.dragable = true
                            self.enableBtns()
                        })
                    }
                }
                
            }
            if memStageCurrent == WordMemStage.cnToEn.rawValue {
                DispatchQueue.main.async {
                    self.disableBtns()
                    next_card.dragable = false
                    next_card.ringView?.alpha = 1
                
                    UIView.animate(withDuration: self.progressViewAnimationDuration, animations: {
                    next_card.ringView?.progress = 1.0
                }) { (finished) in
                    // fade out
                    next_card.ringView?.alpha = 0.0
                    UIView.animate(withDuration: 1.0, animations: {
                        next_card.wordLabel!.alpha = 1.0
                        next_card.memMethodLabel!.alpha = 1.0
                    }, completion: {_ in
                        next_card.dragable = true
                        self.enableBtns()
                    })
                    
                    let wordStr: String = next_card.wordLabel?.text ?? ""
                    self.playMp3GivenWord(word: wordStr)
                }
                }
            }
            
            //Prepare Next Card
            if currentWordLabelQueue.count > 1{
                let wordQuequeItem = currentWordLabelQueue[1]
                let wordIndex: Int = wordQuequeItem[0]
                let memStage:Int = wordQuequeItem[1]
                let word = words[wordIndex]
                let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
                let collected = card_collect_behaviors[wordIndex] == .yes ? true : false
                setFieldsOfCard(card: card, cardWord: cardWord, collected: collected, memStage: memStage)
            }else if (currentWordLabelQueue.count == 1 && wordsQueue.count == 0 && !(memStage == WordMemStage.cnToEn.rawValue && (bhv == CardBehavior.remember.rawValue || masteredAction))){
                let wordQuequeItem = currentWordLabelQueue[0]
                let wordIndex: Int = wordQuequeItem[0]
                let memStage:Int = wordQuequeItem[1]
                let word = words[wordIndex]
                let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
                let collected = card_collect_behaviors[wordIndex] == .yes ? true : false
                setFieldsOfCard(card: card, cardWord: cardWord, collected: collected, memStage: memStage)
            }
        }
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
            let card = sender.view! as! CardUIView
            if !card.dragable{
                return
            }
            if isBtnEnabled(){
                disableBtns()
            }
            let point = sender.translation(in: view)
            
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
            let xFromCenter = card.center.x - view.center.x
            
            card.X_Constraint.constant = point.x
            card.Y_Constraint.constant = point.y
            sender.view!.frame = card.frame
            
            if xFromCenter > 0
            {
                card.rememberImageView?.backgroundColor = getCardActionColor(cardBehavior: .forget)
                card.rememberLabel?.text = forgetText
            }
            else
            {
                card.rememberImageView?.backgroundColor = getCardActionColor(cardBehavior: .remember)
                card.rememberLabel?.text = rememberedText
            }
            card.rememberImageView?.alpha = 0.7 + (abs(xFromCenter) / view.center.x) * 0.3
            card.rememberLabel?.alpha = 1.0
            let scale = min(0.35 * view.frame.width / abs(xFromCenter), 1.0)
            card.transform = CGAffineTransform(rotationAngle: 0.61 * xFromCenter / view.center.x).scaledBy(x: scale, y: scale)
            let nextCard = cards[(currentIndex + 1) % 2]
            let relScale = scaleOfSecondCard + (abs(xFromCenter) / view.center.x) * (1.0 - scaleOfSecondCard)
            nextCard.transform = CGAffineTransform(scaleX: relScale, y: relScale)
        
        if sender.state == UIGestureRecognizer.State.ended
            {
                if card.center.x < (0.4 * view.frame.width)
                {
                    if isBtnEnabled(){
                        disableBtns()
                    }
                    UIView.animate(withDuration: animationDuration, animations:
                    {
                        card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                        card.alpha = 0
                        card.X_Constraint.constant = card.center.x - self.view.center.x
                        card.Y_Constraint.constant = card.center.y - self.view.center.y
                    })
                    sender.view!.frame = card.frame
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                        nextCard.transform = .identity
                    })
                    
                    let wordIndex: Int = currentWordLabelQueue[0][0]
                    
                    if card_actions[wordIndex] == nil{
                        card_actions[wordIndex] = []
                    }
                    
                    card_actions[wordIndex]!.append(CardBehavior.remember.rawValue)
                    
                    let currentMemStage: Int = currentWordLabelQueue[0][1]
                    let statusToCompare: Int = currentMode == 1 ? WordMemStage.memory.rawValue : WordMemStage.enToCn.rawValue
                    if currentMemStage == statusToCompare{
                        
                        if card_behaviors[wordIndex] == nil{
                            card_behaviors[wordIndex] = []
                        }
                        
                        if card_behavior_dates[wordIndex] == nil{
                            card_behavior_dates[wordIndex] = []
                        }
                        
                        card_behaviors[wordIndex]!.append(CardBehavior.remember.rawValue)
                        
                        card_behavior_dates[wordIndex]!.append(Date())
                    }
                    
                    self.currentIndex += 1
                    if currentWordLabelQueue.count > 1{
                        let memStage: Int  = currentWordLabelQueue[1][1]
                        if !(memStage == WordMemStage.cnToEn.rawValue){
                            let word: String = nextCard.wordLabel?.text ?? ""
                            playMp3GivenWord(word: word)
                        }
                    }
                    
                    perform(#selector(moveCard), with: NSNumber(value: CardBehavior.remember.rawValue), afterDelay: animationDuration)
                    return
                }
                else if card.center.x > (0.6 * view.frame.width)
                {
                    if isBtnEnabled(){
                        disableBtns()
                    }
                    UIView.animate(withDuration: animationDuration, animations:
                    {
                        card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                        card.X_Constraint.constant = card.center.x - self.view.center.x
                        card.Y_Constraint.constant = card.center.y - self.view.center.y
                        card.alpha = 0
                    })
                    
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                        nextCard.transform = .identity
                    })
                    
                    let wordIndex: Int = currentWordLabelQueue[0][0]
                    
                    if card_actions[wordIndex] == nil{
                        card_actions[wordIndex] = []
                    }
                    
                    card_actions[wordIndex]!.append(CardBehavior.forget.rawValue)
                    
                    let currentMemStage: Int = currentWordLabelQueue[0][1]
                    let statusToCompare: Int = currentMode == 1 ? WordMemStage.memory.rawValue : WordMemStage.enToCn.rawValue
                    
                    if currentMemStage == statusToCompare{
                        if card_behaviors[wordIndex] == nil{
                            card_behaviors[wordIndex] = []
                            
                        }
                        
                        if card_behavior_dates[wordIndex] == nil{
                            card_behavior_dates[wordIndex] = []
                            
                        }
                        
                        card_behaviors[wordIndex]!.append(CardBehavior.forget.rawValue)
                        
                        card_behavior_dates[wordIndex]!.append(Date())
                    }
                    
                    sender.view!.frame = card.frame
                    self.currentIndex += 1
                    if currentWordLabelQueue.count > 1{
                        let memStage: Int  = currentWordLabelQueue[1][1]
                        if !(memStage == WordMemStage.cnToEn.rawValue){
                            let word: String = nextCard.wordLabel?.text ?? ""
                            playMp3GivenWord(word: word)
                        }
                    }
                    perform(#selector(moveCard), with: NSNumber(value: CardBehavior.forget.rawValue), afterDelay: animationDuration)
                    return
                }
                resetCardToCenter(card: card)
            }
        }
    
    func resetCardToCenter(card: CardUIView){
        UIView.animate(withDuration: 0.2, animations:
        {
            card.center = self.view.center
            card.alpha = 1
        })
        card.X_Constraint.constant = 0
        card.Y_Constraint.constant = card_Y_constant
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.alpha = 0.0
        card.transform = .identity
        enableBtns()
    }

    func resetCard(card: CardUIView)
    {
        card.X_Constraint.constant = 0
        card.Y_Constraint.constant = card_Y_constant
        card.rememberImageView?.backgroundColor = UIColor.white
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.text = ""
        card.rememberLabel?.alpha = 0
        card.memMethodLabel?.alpha = 0
        card.memMethodLabel?.text = ""
        card.wordLabel?.alpha = 0
        card.wordLabel?.text = ""
        card.meaningLabel?.alpha = 0
        card.meaningLabel?.text = ""
        card.layer.removeAllAnimations()
        card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        card.alpha = 1
//        card.cardImageView?.backgroundColor = UIColor.init(hex: getRandomColor())!
    }
        
    func playMp3(url: URL)
    {
            if Reachability.isConnectedToNetwork(){
                DispatchQueue.global(qos: .background).async {
                do {
                    var downloadTask: URLSessionDownloadTask
                    downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (urlhere, response, error) -> Void in
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
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
            
        }
        
        @IBAction func playAudio(_ sender: UIButton) {
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                let card = cards[currentIndex % 2]
                let wordStr: String = card.wordLabel?.text ?? ""
                if let mp3_url = getWordPronounceURL(word: wordStr, us_pronounce: preference.us_pronunciation){
                    playMp3(url: mp3_url)
                }
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
            
        }
    
    func load_html(wordHead: String, wordIndex: Int){
        if Reachability.isConnectedToNetwork(){
            let card = cards[currentIndex % 2]
            if let _ = card.cardBackView {
                card.dragable = false
                card.cardBackView!.isUserInteractionEnabled = true
                card.cardBackView!.alpha = 1
                card.cardBackView!.initActivityIndicator(text: gettingVocabsText)
                
                DispatchQueue.global(qos: .background).async {
                do {
                    let query = LCQuery(className: "OALECD8")
                    query.whereKey("word_id" , .equalTo(wordIndex))
                    _ = query.getFirst { result in
                        switch result {
                        case .success(object: let word):
                            if let html_content = word.get("html_content")?.stringValue
                            {
                                let html_final = build_html_with_given_content(html_content: html_content, remove_newline: true)
                                card.cardBackView!.webView.loadHTMLString(html_final, baseURL: nil)
                                card.cardBackView!.stopIndicator()
                            }else{
                                card.cardBackView!.stopIndicator()
                            }
                            break
                        case .failure(error: let error):
                            print(error)
                        }
                    }
                    }}
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    func removeLastVocabRecord(index: Int, cardBehavior: CardBehavior){
        vocabRecordsOfCurrent[index].ReviewDUEDate = nil
        switch cardBehavior {
        case .forget:
            vocabRecordsOfCurrent[index].BehaviorHistory.removeLast()
        case .remember:
            vocabRecordsOfCurrent[index].BehaviorHistory.removeLast()
        case .trash:
            vocabRecordsOfCurrent[index].Mastered = false
        }
    }
    
    @IBAction func backOneCard(_ sender: UIButton) {
        if self.currentIndex > 0
        {
            disableBtns()
            let valArray:[Int] = wordsQArray.last!
            let lastWordIndex = valArray[0]
            let lastMemStage = valArray[1]
            let cardBehavior = valArray[2]
            
            switch lastMemStage {
                case WordMemStage.memory.rawValue:
                    firstMemLeftNum += 1
                case WordMemStage.enToCn.rawValue:
                    enToCNLeftNum += 1
                case WordMemStage.cnToEn.rawValue:
                    cnToENLeftNum += 1
                default:
                    print("Nothing")
            }
            
            if cardBehavior == CardBehavior.trash.rawValue{
                self.mastered[lastWordIndex] = false
            }
            self.currentIndex -= 1
            
            let thisCard = cards[(currentIndex + 1) % 2] //the one on top before back
            let lastCard = cards[currentIndex % 2]
            thisCard.dragable = !thisCard.dragable
            lastCard.dragable = !lastCard.dragable
            
            thisCard.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            
            let wordQuequeThisCard = currentWordLabelQueue[0]
            let wordIndexOfThisCard: Int = wordQuequeThisCard[0]
            let memStageOfThisCard:Int = wordQuequeThisCard[1]
            let wordOfThisCard = words[wordIndexOfThisCard]
            let cardWordOfThisCard = getFeildsOfWord(word: wordOfThisCard, usphone: preference.us_pronunciation)
            let collectedOfThisCard = card_collect_behaviors[wordIndexOfThisCard] == .yes ? true : false
            setFieldsOfCard(card: thisCard, cardWord: cardWordOfThisCard, collected: collectedOfThisCard, memStage: memStageOfThisCard)
            
            
            lastCard.layer.removeAllAnimations()
            lastCard.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            
            let word = words[lastWordIndex]
            let cardWord = getFeildsOfWord(word: word, usphone: preference.us_pronunciation)
            let collect = card_collect_behaviors[lastWordIndex] == .yes ? true: false
            
            setFieldsOfCard(card: lastCard, cardWord: cardWord, collected: collect, memStage: lastMemStage)
            if !(lastMemStage == WordMemStage.cnToEn.rawValue){
                let wordStr: String = lastCard.wordLabel?.text ?? ""
                playMp3GivenWord(word: wordStr)
            }
            let direction:CGFloat = cardBehavior == CardBehavior.forget.rawValue ? 1 : -1
            lastCard.center = CGPoint(x:  self.view.center.x + 400 * (direction), y: self.view.center.y + 75)
            lastCard.X_Constraint.constant = lastCard.center.x - self.view.center.x
            lastCard.Y_Constraint.constant = lastCard.center.y - self.view.center.y
            
            if currentIndex == 0
            {
                lastCard.dimUIView!.theme_alpha = "MainPanel.dimAlpha"
            }
            learnUIView.bringSubviewToFront(lastCard)
            lastCard.alpha = 0
            UIView.animate(withDuration: animationDuration, animations:
            {
                lastCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                lastCard.X_Constraint.constant = lastCard.center.x - self.view.center.x
                lastCard.Y_Constraint.constant = lastCard.center.y - self.view.center.y
                lastCard.alpha = 1
            }, completion: { [self] _ in
                if lastMemStage == WordMemStage.enToCn.rawValue {
                    DispatchQueue.main.async {
                        lastCard.dragable = false
                        self.disableBtns()
                        lastCard.ringView?.alpha = 1
                        UIView.animate(withDuration: progressViewAnimationDuration, animations: {
                            lastCard.ringView?.progress = 1.0
                        }) { (finished) in
                            // fade out
                            lastCard.ringView?.alpha = 0.0
                            
                            UIView.animate(withDuration: 1.0, animations: {
                                lastCard.meaningLabel!.alpha = 1.0
                                lastCard.memMethodLabel!.alpha = 1.0
                            }, completion: {_ in
                                lastCard.dragable = true
                                self.enableBtns()
                            })
                        }
                    }
                }
                if lastMemStage == WordMemStage.cnToEn.rawValue  {
                    DispatchQueue.main.async {
                        lastCard.dragable = false
                        self.disableBtns()
                        lastCard.ringView?.alpha = 1
                    
                        UIView.animate(withDuration: progressViewAnimationDuration, animations: {
                            lastCard.ringView?.progress = 1.0
                        }) { (finished) in
                            // fade out
                            lastCard.ringView?.alpha = 0.0
                            UIView.animate(withDuration: 1.0, animations: {
                                lastCard.wordLabel!.alpha = 1.0
                                lastCard.memMethodLabel!.alpha = 1.0
                            }, completion: {_ in
                                lastCard.dragable = true
                                self.enableBtns()
                            })
                            
                            let wordStr: String = lastCard.wordLabel?.text ?? ""
                            self.playMp3GivenWord(word: wordStr)
                        }}
                }
            })
            
            let gestureRecognizer = self.gestureRecognizers[currentIndex % 2]
            gestureRecognizer.view!.frame = lastCard.frame
            
            if cardBehavior != CardBehavior.trash.rawValue && !(cardBehavior == CardBehavior.remember.rawValue && lastMemStage == WordMemStage.cnToEn.rawValue) && wordsQueue.count > 0{
                let wordQElement:[Int] = wordsQueue.last!
                let memStageOfThis:Int = wordQElement[1]
                switch memStageOfThis {
                    case WordMemStage.memory.rawValue:
                        firstMemLeftNum -= 1
                    case WordMemStage.enToCn.rawValue:
                        enToCNLeftNum -= 1
                    case WordMemStage.cnToEn.rawValue:
                        cnToENLeftNum -= 1
                    default:
                        print("Nothing")
                }
                wordsQueue.removeLast()
            }
            updateWordLeftLabels(currentMemStage: lastMemStage)
            currentWordLabelQueue.insert([lastWordIndex, lastMemStage], at: 0)
            
            if currentWordLabelQueue.count > 2{
                let wordQElement:[Int] = currentWordLabelQueue.last!
                currentWordLabelQueue.removeLast()
                wordsQueue.insert(wordQElement, at: 0)
            }
            
            wordsQArray.removeLast()
            
            if card_actions[lastWordIndex] != nil && card_actions[lastWordIndex]!.count > 0{
                card_actions[lastWordIndex]!.removeLast()
            }
            let statusToCompare = currentMode == 1 ?  WordMemStage.memory.rawValue:  WordMemStage.enToCn.rawValue
            if lastMemStage == statusToCompare {
                if card_behaviors[lastWordIndex] != nil && card_behaviors[lastWordIndex]!.count > 0{
                    card_behaviors[lastWordIndex]!.removeLast()
                }
                
                if card_behavior_dates[lastWordIndex] != nil && card_behavior_dates[lastWordIndex]!.count > 0{
                    card_behavior_dates[lastWordIndex]!.removeLast()
                }
            }
            
            enableBtns()
        }
        else{
            let alertCtl = presentAlert(title: firstCardText, message: "", okText: okText)
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    @IBAction func masterThisCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: masterText, backgroundColor:  getCardActionColor(cardBehavior: .trash), cardBehavior: .trash)
    }
    
    func cardAnimation(rememberLabelText: String, backgroundColor: UIColor, cardBehavior: CardBehavior){
        disableBtns()
        let card = self.cards[self.currentIndex % 2]
        let nextCard = self.cards[(self.currentIndex + 1) % 2]
        card.rememberLabel?.text = rememberLabelText
        card.rememberImageView?.backgroundColor = backgroundColor
        let firstAnimationDuration = 0.2
        let direction: CGFloat = cardBehavior == .forget ? 1 : -1
        UIView.animate(withDuration: firstAnimationDuration, animations: {
            card.center.x = ((0.5 + direction * 0.15) * self.view.frame.width)
            card.rememberImageView?.alpha = 1
            card.rememberLabel?.alpha = 1
            let xFromCenter = card.center.x - self.view.center.x
            let scale = min(0.35 * self.view.frame.width / abs(xFromCenter), 1.0)
            card.transform = CGAffineTransform(rotationAngle: 0.61 * xFromCenter / self.view.center.x).scaledBy(x: scale, y: scale)
        }) { (completed) in
            UIView.animate(withDuration: self.animationDuration, delay: 0, animations:{
               card.center = CGPoint(x: card.center.x + direction * 200, y: card.center.y + 75)
               card.alpha = 0
               card.X_Constraint.constant = card.center.x - self.view.center.x
               card.Y_Constraint.constant = card.center.y - self.view.center.y
            }){ (completed) in
                UIView.animate(withDuration: 0.01, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    nextCard.transform = .identity
                }){ (completed) in
                    
                    self.gestureRecognizers[self.currentIndex % 2].view!.frame = card.frame
                    
                    let wordIndex: Int = self.currentWordLabelQueue[0][0]
                    
                    if self.card_actions[wordIndex] == nil{
                        self.card_actions[wordIndex] = []
                    }
                    
                    let currentMemStage: Int = self.currentWordLabelQueue[0][1]
                    let statusToCompare = self.currentMode == 1 ? WordMemStage.memory.rawValue : WordMemStage.enToCn.rawValue
                    
                    if currentMemStage == statusToCompare{
                        if self.card_behaviors[wordIndex] == nil{
                            self.card_behaviors[wordIndex] = []
                        }
                        
                        if self.card_behavior_dates[wordIndex] == nil{
                            self.card_behavior_dates[wordIndex] = []
                        }
                    }
                    switch cardBehavior{
                    case .remember:
                        self.card_actions[wordIndex]!.append(CardBehavior.remember.rawValue)
                        
                        if currentMemStage == statusToCompare{
                            self.card_behaviors[wordIndex]!.append(CardBehavior.remember.rawValue)
                            self.card_behavior_dates[wordIndex]!.append(Date())
                        }
                        
                    case .forget:
                        self.card_actions[wordIndex]!.append(CardBehavior.forget.rawValue)
                        if currentMemStage == statusToCompare{
                            self.card_behaviors[wordIndex]!.append(CardBehavior.forget.rawValue)
                            self.card_behavior_dates[wordIndex]!.append(Date())
                        }
                        
                    case .trash:
                        self.mastered[wordIndex] = true
                    }
                    self.currentIndex += 1
                    if self.currentWordLabelQueue.count > 1{
                        let memStage: Int  = self.currentWordLabelQueue[1][1]
                        if !(memStage == WordMemStage.cnToEn.rawValue){
                            let word: String = nextCard.wordLabel?.text ?? ""
                            self.playMp3GivenWord(word: word)
                        }
                    }
                    self.perform(#selector(self.moveCard), with: NSNumber(value: cardBehavior.rawValue), afterDelay: self.animationDuration)
                }
            }
        }
    }
    
    @IBAction func learntTheCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: rememberedText, backgroundColor:  getCardActionColor(cardBehavior: .remember), cardBehavior: .remember)
    }
    
    func disableBtns(){
        DispatchQueue.main.async {
            self.backBtn.isEnabled = false
            self.learnUIView.collectBtn.isEnabled = false
            self.learnUIView.undoBtn.isEnabled = false
            self.learnUIView.yesBtn.isEnabled = false
            self.learnUIView.noBtn.isEnabled = false
            self.learnUIView.trashBtn.isEnabled = false
        }
    }
    
    func isBtnEnabled() -> Bool{
        return self.learnUIView.collectBtn.isEnabled
    }
    
    func enableBtns(){
        DispatchQueue.main.async {
            self.backBtn.isEnabled = true
            self.learnUIView.collectBtn.isEnabled = true
            self.learnUIView.undoBtn.isEnabled = true
            self.learnUIView.yesBtn.isEnabled = true
            self.learnUIView.noBtn.isEnabled = true
            self.learnUIView.trashBtn.isEnabled = true
        }
    }
    
    @IBAction func cardDifficultToLearn(_ sender: UIButton) {
        cardAnimation(rememberLabelText: forgetText, backgroundColor:  getCardActionColor(cardBehavior: .forget), cardBehavior: .forget)
    }
    
    @IBAction func addWordToCollection(_ sender: UIButton) {
        disableBtns()
        let card = cards[currentIndex % 2]
        let wordIndex: Int = self.currentWordLabelQueue[0][0]
        let cardCollectedBehaviorPrevious: CardCollectBehavior = card_collect_behaviors[wordIndex]
        if cardCollectedBehaviorPrevious == .no{
            card_collect_behaviors[wordIndex] = .yes
            DispatchQueue.main.async {
                card.collectImageView.alpha = 1
                self.enableBtns()
            }
            
        }
        else{
            card_collect_behaviors[wordIndex] = .no
            DispatchQueue.main.async {
                card.collectImageView.alpha = 0
                self.enableBtns()
            }
        }
    }
}
