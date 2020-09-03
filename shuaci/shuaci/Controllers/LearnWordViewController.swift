//
//  LearnWordViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import LeanCloud
import SwiftTheme

class LearnWordViewController: UIViewController {
    var mainPanelViewController: MainPanelViewController!
    @IBOutlet var learnUIView: LearnUIView!
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    
    @IBOutlet var cardDictionaryBtn: [UIButton]!

    let card_Y_constant:CGFloat = -30
    var card_behaviors:[Int: [Int]] = [:] //word index: Int , card Behavoirs[forget: 0, remember: 1, trash: 2\]
    var card_collect_behaviors: [CardCollectBehavior] = [] // card Behavoir: (collect: 1, else 0)
    @IBOutlet var gestureRecognizers:[UIPanGestureRecognizer]!
    var secondsPST:Int = 0 // number of seconds past after load
    @IBOutlet var timeLabel: UILabel!
//    @IBOutlet var progressLabel: UILabel!
    
    @IBOutlet var firstMemLeft: UILabel!
    @IBOutlet var enToCNLeft: UILabel!
    @IBOutlet var cnToENLeft: UILabel!
    
    var firstMemLeftNum: Int = 0
    var enToCNLeftNum: Int = 0
    var cnToENLeftNum: Int = 0
    
    var isCardBack: Bool = false //whether the card is front or back end
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.15
    var viewTranslation = CGPoint(x: 0, y: 0)
    private var wordsQueue: Array<[Int]> = []
    private var wordsQArray: Array<[Int]> = []
    var currentWordLabelQueue:Array<[Int]> = []
    let firstReviewDelayInMin = 60
    var mastered:[Bool] = []
    
    private var DICT_URL: URL = Bundle.main.url(forResource: "DICT.json", withExtension: nil)!
    var Word_indexs_In_Oalecd8:[String:[Int]] = [:]
    
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
        //view.backgroundColor = UIColor(red: 238, green: 241, blue: 245, alpha: 1.0)
        
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        super.viewDidLoad()
        currentLearningRec.StartDate = Date()
    }
    
    @objc func relayout(){
        for index in [currentIndex, currentIndex+1]{
            let word = words[index % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
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
    
    func updateWordLeftLabels(currentMemStage: Int){
        DispatchQueue.main.async {

            self.firstMemLeft.theme_textColor = "LearningVC.TextLabelColor"
            self.enToCNLeft.theme_textColor = "LearningVC.TextLabelColor"
            self.cnToENLeft.theme_textColor = "LearningVC.TextLabelColor"
            
            switch currentMemStage{
                case WordMemStage.memory.rawValue:
                    self.firstMemLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                case WordMemStage.enToCn.rawValue:
                    self.enToCNLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                case WordMemStage.cnToEn.rawValue:
                    self.cnToENLeft.theme_textColor = "LearningVC.DarkerTextLabelColor"
                default:
                    print("Nothing")
            }
            
            let firstMemText = "1. 初记忆  \(self.firstMemLeftNum)"
            var attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: firstMemText)
            if self.firstMemLeftNum == 0{
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.firstMemLeft.attributedText = attributeString
            
            let enToCNLeftText = "2. 英忆中  \(self.enToCNLeftNum)"
            attributeString =  NSMutableAttributedString(string: enToCNLeftText)
            if self.firstMemLeftNum == 0 &&  self.enToCNLeftNum == 0{
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.enToCNLeft.attributedText = attributeString
            
            let cnToENLeftText = "3. 中忆英  \(self.cnToENLeftNum)"
            attributeString =  NSMutableAttributedString(string: cnToENLeftText)
            if self.firstMemLeftNum == 0 &&  self.enToCNLeftNum == 0 && self.cnToENLeftNum == 0 {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            }
            self.cnToENLeft.attributedText = attributeString
        }
    }
    
    func initWordLeftNumbers(){
        firstMemLeftNum = words.count
        enToCNLeftNum = 0
        cnToENLeftNum = 0
        updateWordLeftLabels(currentMemStage : WordMemStage.memory.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool){
        setCardBackground()
        load_DICT()
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
        startTimer()
//        self.updateProgressLabel(index: self.currentIndex)
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.mp3Player?.stop()
        self.dismiss(animated: true, completion: nil)
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
    
    
    
    func setCardBackground(){
        let current_theme_category = getPreference(key: "current_theme_category") as! Int
        for card in cards{
            card.cardImageView?.image = UIImage(named: cardBackgrounds[current_theme_category]!)
        }
    }
    
    @IBAction func showfullCard(_ sender: UITapGestureRecognizer) {
        let card = cards[currentIndex % 2]
        if card.meaningLabel!.alpha < 1e-5 {
            UIView.animate(withDuration: 1.0, animations: {
                card.meaningLabel!.alpha = 1.0
            }) { (finished) in
                // fade out
                UIView.animate(withDuration: 1.0, animations: {
                    card.memMethodLabel!.alpha = 1.0
                })
            }
        }
        if card.wordLabel!.alpha < 1e-5 {
           let word: String = card.wordLabel?.text ?? ""
           playMp3GivenWord(word: word)
           UIView.animate(withDuration: 1.0, animations: {
                card.wordLabel!.alpha = 1.0
            }) { (finished) in
                // fade out
                UIView.animate(withDuration: 1.0, animations: {
                    card.memMethodLabel!.alpha = 1.0
                })
            }
        }
    }
    
    @IBAction func flipCard(_ sender: Any) {
        let card = cards[currentIndex % 2]
        if isCardBack {
            isCardBack = false
            let current_theme_category = getPreference(key: "current_theme_category") as! Int
            card.cardImageView?.image = UIImage(named: cardBackgrounds[current_theme_category]!)
            UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }else{
            isCardBack = true
            card.cardImageView?.image = UIImage(named: "card_back")
            UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            
        }
    }
    
//    func updateProgressLabel(index: Int){
//        DispatchQueue.main.async {
//            self.progressLabel.text = "\(index + 1)/\(words.count)"
//        }
//    }
    
    func playMp3GivenWord(word: String){
        let auto_pronunciation:Bool = getPreference(key: "auto_pronunciation") as! Bool
        
        let mp3_url = getWordPronounceURL(word: word)
        if auto_pronunciation && (mp3_url != nil) {
            playMp3(url: mp3_url!)
        }
    }
    
    func initWordQueue(){
        for wid in 0..<words.count{
            wordsQueue.enqueue([wid, WordMemStage.memory.rawValue])
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
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            setFieldsOfCard(card: card, cardWord: cardWord, collected: false, memStage: memStage)
            if index == 1
            {
                card.dragable = false
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            }else{
                let word: String = card.wordLabel?.text ?? ""
                playMp3GivenWord(word: word)
            }
        }
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
        let current_word: String = cardWord.headWord
        let indexItem:[Int] = Word_indexs_In_Oalecd8[current_word]!
        let hasValueInOalecd8: Int = indexItem[1]
        DispatchQueue.main.async {
            if hasValueInOalecd8 == 0{
                self.cardDictionaryBtn[self.currentIndex % 2].alpha = 0
            }
            else
            {
                self.cardDictionaryBtn[self.currentIndex % 2].alpha = 1
            }
            
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
            }
            
            if collected{
                card.collectImageView.alpha = 1
            }else{
                card.collectImageView.alpha = 0
            }
            card.meaningLabel?.alpha = 1
            card.wordLabel?.alpha = 1
            
            if memStage == 2{
                card.meaningLabel?.alpha = 0
            } else if memStage == 3{
                card.wordLabel?.alpha = 0
            }

            if memStage > 1{
                card.memMethodLabel?.alpha = 0
            }else{
                if cardWord.memMethod != ""{
                    card.memMethodLabel?.alpha = 1
                }
            }
        }
    }
    
    func initVocabRecords(){
        vocabRecordsOfCurrentLearning = []
        let current_book_id:String = getPreference(key: "current_book_id") as! String
        for index in 0..<words.count
        {
            mastered.append(false)
            let word = words[index % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            let vocabRecord: VocabularyRecord = VocabularyRecord.init(VocabHead: "\(cardWord.headWord)", BookId: current_book_id, LearnDate: nil, CollectDate: nil, Mastered: false, MasteredDate: nil, ReviewDUEDate: nil, BehaviorHistory: [])
            vocabRecordsOfCurrentLearning.append(vocabRecord)
            card_collect_behaviors.append(.no)
        }
    }
    
    
    func summary_learn_records_into_vocab_records(){
        for index in 0..<vocabRecordsOfCurrentLearning.count
        {
            if card_collect_behaviors[index] == .yes{
                vocabRecordsOfCurrentLearning[index].CollectDate = Date()
            }
            
            if mastered[index] {
                vocabRecordsOfCurrentLearning[index].Mastered = mastered[index]
            }
            vocabRecordsOfCurrentLearning[index].ReviewDUEDate =  Date().adding(durationVal: firstReviewDelayInMin, durationType: .minute)
            if let bhvs = card_behaviors[index]{
                vocabRecordsOfCurrentLearning[index].BehaviorHistory = bhvs
            }
        }
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
        
        if !masteredAction{
            let cardAction: Int = card_behaviors[wordIndex]!.last!
            if !(memStage == WordMemStage.cnToEn.rawValue && cardAction == CardBehavior.remember.rawValue){
                var nextStage = WordMemStage.memory.rawValue
                if memStage == WordMemStage.memory.rawValue{
                    nextStage = WordMemStage.enToCn.rawValue
                }else{
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
            currentLearningRec.EndDate = Date()
            currentLearningRec.VocabRecHeads = getVocabHeadsFromVocabRecords(VocabRecords: vocabRecordsOfCurrentLearning)
            summary_learn_records_into_vocab_records()
            saveLearningRecordsFromLearning()
            update_words()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.mainPanelViewController.loadLearnOrReviewFinishController()
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
            updateWordLeftLabels(currentMemStage: memStageCurrent)
//            self.updateProgressLabel(index: wordIndex)
            
            //Prepare Next Card
            if currentWordLabelQueue.count > 1{
                let wordQuequeItem = currentWordLabelQueue[1]
                let wordIndex: Int = wordQuequeItem[0]
                let memStage:Int = wordQuequeItem[1]
                let word = words[wordIndex]
                let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
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
                card.rememberLabel?.text = "不熟"
            }
            else
            {
                card.rememberImageView?.backgroundColor = getCardActionColor(cardBehavior: .remember)
                card.rememberLabel?.text = "会了"
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
                    if card_behaviors[wordIndex] == nil{
                        card_behaviors[wordIndex] = []
                    }
                    card_behaviors[wordIndex]!.append(CardBehavior.remember.rawValue)
                    
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
                    if card_behaviors[wordIndex] == nil{
                        card_behaviors[wordIndex] = []
                        
                    }
                    card_behaviors[wordIndex]!.append(CardBehavior.forget.rawValue)
                    

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
//            view.layoutIfNeeded()
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
        card.memMethodLabel?.text = ""
        card.wordLabel?.text = ""
        card.meaningLabel?.text = ""
        card.layer.removeAllAnimations()
        card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        card.alpha = 1
    }
        
        func playMp3(url: URL)
        {
            let connected = Reachability.isConnectedToNetwork()
            if connected{
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
                if non_network_preseted == false{
                    let alertCtl = presentNoNetworkAlert()
                    self.present(alertCtl, animated: true, completion: nil)
                    non_network_preseted = true
                }
            }
            
        }
        
        @IBAction func playAudio(_ sender: UIButton) {
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                let card = cards[currentIndex % 2]
                let wordStr: String = card.wordLabel?.text ?? ""
                if let mp3_url = getWordPronounceURL(word: wordStr){
                    playMp3(url: mp3_url)
                }
            }else{
                let alertCtl = presentNoNetworkAlert()
                if non_network_preseted == false{
                    self.present(alertCtl, animated: true, completion: nil)
                    non_network_preseted = true
                }
            }
            
        }
    
    
    @IBAction func backToCardFront(_ sender: UIButton) {
        let card = cards[currentIndex % 2]
        card.cardBackView!.isUserInteractionEnabled = false
        card.cardBackView!.alpha = 0
        card.dragable = true
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    func load_html(wordHead: String, wordIndex: Int){
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            let card = cards[currentIndex % 2]
            if let _ = card.cardBackView {
                card.dragable = false
                card.cardBackView!.isUserInteractionEnabled = true
                card.cardBackView!.alpha = 1
                card.cardBackView!.initActivityIndicator(text: "获取单词中..")
                card.cardBackView!.wordLabel?.text = wordHead
                
                DispatchQueue.global(qos: .background).async {
                do {
                    let query = LCQuery(className: "OALECD8")
                    query.whereKey("word_id" , .equalTo(wordIndex))
                    _ = query.getFirst { result in
                        switch result {
                        case .success(object: let word):
                            if let html_content = word.get("html_content")?.stringValue
                            {
                                let html_final = build_html_with_given_content(html_content: html_content)
                                card.cardBackView!.webView.loadHTMLString(html_final, baseURL: nil)
                                card.cardBackView!.stopIndicator()
                            }else{
                                card.cardBackView!.stopIndicator()
                                self.dismiss(animated: true, completion: nil)
                            }
                            break
                        case .failure(error: let error):
                            print(error)
                        }
                    }
                    }}
            }
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
    }
    
    @IBAction func lookUpDictionary(_ sender: UIButton) {
        let card = cards[currentIndex % 2]
        let current_word: String = card.wordLabel?.text ?? ""
        if current_word != ""{
            let indexItem:[Int] = Word_indexs_In_Oalecd8[current_word]!
            let wordIndex: Int = indexItem[0]
            let hasValueInOalecd8: Int = indexItem[1]
            if hasValueInOalecd8 == 1{
                UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                load_html(wordHead: current_word, wordIndex: wordIndex)
            }
        }
    }
    
    func removeLastVocabRecord(index: Int, cardBehavior: CardBehavior){
        vocabRecordsOfCurrentLearning[index].ReviewDUEDate = nil
        switch cardBehavior {
        case .forget:
            vocabRecordsOfCurrentLearning[index].BehaviorHistory.removeLast()
        case .remember:
            vocabRecordsOfCurrentLearning[index].BehaviorHistory.removeLast()
        case .trash:
            vocabRecordsOfCurrentLearning[index].Mastered = false
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
            let cardWordOfThisCard = getFeildsOfWord(word: wordOfThisCard, usphone: getUSPhone())
            let collectedOfThisCard = card_collect_behaviors[wordIndexOfThisCard] == .yes ? true : false
            setFieldsOfCard(card: thisCard, cardWord: cardWordOfThisCard, collected: collectedOfThisCard, memStage: memStageOfThisCard)
            
            
            lastCard.layer.removeAllAnimations()
            lastCard.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            
            let word = words[lastWordIndex]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
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
            if card_behaviors[lastWordIndex] != nil && card_behaviors[lastWordIndex]!.count > 0{
                card_behaviors[lastWordIndex]!.removeLast()
            }
            
//            self.updateProgressLabel(index: lastWordIndex)
            enableBtns()
        }
        else{
            let alertCtl = presentAlert(title: "已经是第一张啦!", message: "", okText: "好的")
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    @IBAction func masterThisCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: "掌握", backgroundColor:  getCardActionColor(cardBehavior: .trash), cardBehavior: .trash)
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
                    if self.card_behaviors[wordIndex] == nil{
                        self.card_behaviors[wordIndex] = []
                    }
                    switch cardBehavior{
                    case .remember:
                        self.card_behaviors[wordIndex]!.append(CardBehavior.remember.rawValue)
                    case .forget:
                        self.card_behaviors[wordIndex]!.append(CardBehavior.forget.rawValue)
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
        cardAnimation(rememberLabelText: "会了", backgroundColor:  getCardActionColor(cardBehavior: .remember), cardBehavior: .remember)
    }
    
    func disableBtns(){
        DispatchQueue.main.async {
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
            self.learnUIView.collectBtn.isEnabled = true
            self.learnUIView.undoBtn.isEnabled = true
            self.learnUIView.yesBtn.isEnabled = true
            self.learnUIView.noBtn.isEnabled = true
            self.learnUIView.trashBtn.isEnabled = true
        }
    }
    
    @IBAction func cardDifficultToLearn(_ sender: UIButton) {
        cardAnimation(rememberLabelText: "不熟", backgroundColor:  getCardActionColor(cardBehavior: .forget), cardBehavior: .forget)
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
