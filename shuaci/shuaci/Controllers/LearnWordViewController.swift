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

class LearnWordViewController: UIViewController {
    @IBOutlet var mainPanelViewController: MainPanelViewController!
    @IBOutlet var learnUIView: LearnUIView!
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    var card_behaviors:[CardBehavior] = [] //forget: 0, remember: 1, trash: 2
    var card_collect_behaviors: [CardCollectBehavior] = [] //collect: 1, else 0
    @IBOutlet var gestureRecognizers:[UIPanGestureRecognizer]!
    var secondsPST:Int = 0 // number of seconds past after load
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.15
    
    func setCardBackground(){
        let theme_category_exist = isKeyPresentInUserDefaults(key: theme_category_string)
        var theme_category  = 1
        if theme_category_exist{
            theme_category = UserDefaults.standard.integer(forKey: theme_category_string)
        }else{
            UserDefaults.standard.set(theme_category, forKey: theme_category_string)
        }
            
        for card in cards{
            card.cardImageView?.image = UIImage(named: cardBackgrounds[theme_category]!)
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 238, green: 241, blue: 245, alpha: 1.0)
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
                    card.memMethodLabel?.alpha = 1
                }
                else{
                    card.wordLabel_Top_Space_Constraint.constant = 180
                    card.memMethodLabel?.alpha = 0
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        setCardBackground()
        initCards()
        initVocabRecords()
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
    self.updateProgressLabel(index: self.currentIndex)
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
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
    
    
    
    func updateProgressLabel(index: Int){
        DispatchQueue.main.async {
            self.progressLabel.text = "\(index + 1)/\(words.count)"
        }
    }
    
    
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index]
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            let word = words[index % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            setFieldsOfCard(card: card, cardWord: cardWord, collected: false)
            if index == 1
            {
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            }else{
                let word: String = card.wordLabel?.text ?? ""
                if let mp3_url = getWordPronounceURL(word: word){
                    playMp3(url: mp3_url)
                }
            }
        }
    }
    
    
    
    func setFieldsOfCard(card: CardUIView, cardWord: CardWord, collected: Bool){
        card.wordLabel?.text = cardWord.headWord
        DispatchQueue.main.async {
            if cardWord.headWord.count >= 12{
                card.wordLabel?.font = card.wordLabel?.font.withSize(40.0)
            }else{
                card.wordLabel?.font = card.wordLabel?.font.withSize(45.0)
            }
            
            card.meaningLabel?.text = cardWord.meaning
            card.speech? = cardWord.speech
            if cardWord.memMethod != ""{
                card.wordLabel_Top_Space_Constraint.constant = 130
                card.memMethodLabel?.alpha = 1
                card.memMethodLabel?.text = "记: \(cardWord.memMethod)"
            }
            else{
                card.wordLabel_Top_Space_Constraint.constant = 180
                card.memMethodLabel?.alpha = 0
            }
            if collected{
                card.collectImageView.alpha = 1
            }else{
                card.collectImageView.alpha = 0
            }
        }
    }
    
    func initVocabRecords(){
        vocabRecordsOfCurrentLearning = []
        for index in 0..<words.count
        {
            let word = words[index % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            var vocabRecord: VocabularyRecord = VocabularyRecord.init(VocabRecId: "\(current_book_id)_\(cardWord.wordRank)", BookId: current_book_id, WordRank: cardWord.wordRank, LearnDates: [], ReviewDates: [], MasteredDate: initDateByString(dateString: "3030/01/01 00:00"), RememberDates: [], ForgetDates: [], CollectDate: nil, ReviewDUEDates: [])
            vocabRecordsOfCurrentLearning.append(vocabRecord)
            card_collect_behaviors.append(.no)
        }
    }
    
    
    @objc func moveCard() {
        if currentIndex >= words.count{
            currentLearningRec.EndDate = Date()
            currentLearningRec.VocabRecIds = getVocabIdsFromVocabRecords(VocabRecords: vocabRecordsOfCurrentLearning)
            saveLearningRecordsFromLearning()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.mainPanelViewController.loadLearnFinishController()
            }
        }
        else if currentIndex < words.count - 1{
            print(currentIndex)
            self.updateProgressLabel(index: self.currentIndex)
            let card = cards[(currentIndex + 1) % 2]
            let word = words[(currentIndex + 1) % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            let collected = card_collect_behaviors[currentIndex + 1] == .yes ? true : false
            setFieldsOfCard(card: card, cardWord: cardWord, collected: collected)
            learnUIView.bringSubviewToFront(cards[currentIndex % 2])
            resetCard(card: card)
            enableBtns()
        }
        else{
            return
        }
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        
            let card = sender.view! as! CardUIView
            let point = sender.translation(in: view)
            
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
            let xFromCenter = card.center.x - view.center.x
            
            card.X_Constraint.constant = point.x
            card.Y_Constraint.constant = point.y
            sender.view!.frame = card.frame
            
            if xFromCenter > 0
            {
                card.rememberImageView?.backgroundColor = UIColor.systemPink
                card.rememberLabel?.text = "不熟"
            }
            else
            {
                card.rememberImageView?.backgroundColor = UIColor.systemGreen
                card.rememberLabel?.text = "会了"
            }
            card.rememberImageView?.alpha = 0.3 + (abs(xFromCenter) / view.center.x) * 0.6
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
                    disableBtns()
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
                    vocabRecordsOfCurrentLearning[currentIndex].RememberDates.append(Date())
                    self.addReviewDueDatesForVocabRecords(index: currentIndex, cardBehavior: .remember)
                    card_behaviors.append(.remember)
                    print(card_behaviors)
                    
                    let word: String = nextCard.wordLabel?.text ?? ""
                    if let mp3_url = getWordPronounceURL(word: word){
                        playMp3(url: mp3_url)
                    }
                    
                    self.currentIndex += 1
                    perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
                    return
                }
                else if card.center.x > (0.6 * view.frame.width)
                {
                    disableBtns()
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
                    vocabRecordsOfCurrentLearning[currentIndex].ForgetDates.append(Date())
                    self.addReviewDueDatesForVocabRecords(index: currentIndex, cardBehavior: .forget)
                    card_behaviors.append(.forget)
                    print(card_behaviors)
                    
                    let word: String = nextCard.wordLabel?.text ?? ""
                    if let mp3_url = getWordPronounceURL(word: word){
                        playMp3(url: mp3_url)
                    }

                    sender.view!.frame = card.frame
                    self.currentIndex += 1
                    perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
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
        card.Y_Constraint.constant = 0
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.alpha = 0.0
        card.transform = .identity
    }
    
        func resetCard(card: CardUIView)
        {
            card.X_Constraint.constant = 0
            card.Y_Constraint.constant = 0
            card.rememberImageView?.backgroundColor = UIColor.white
            card.rememberImageView?.alpha = 0
            card.rememberLabel?.text = ""
            card.rememberLabel?.alpha = 0
            card.layer.removeAllAnimations()
            card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            card.alpha = 1
        }
        
        func playMp3(url: URL)
        {
            if Reachability.isConnectedToNetwork(){
                DispatchQueue.global(qos: .background).async {
                do {
                    var downloadTask: URLSessionDownloadTask
                    downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (urlhere, response, error) -> Void in
                    do {
                        self.mp3Player = try AVAudioPlayer(contentsOf: urlhere!)
                        self.mp3Player?.play()
                    } catch {
                        print("couldn't load file :( \(urlhere)")
                    }
                })
                    downloadTask.resume()
                }}
            }else{
                let alertCtl = presentNoNetworkAlert()
                if non_network_preseted == false{
                    self.present(alertCtl, animated: true, completion: nil)
                    non_network_preseted = true
                }
            }
            
        }
        
        @IBAction func playAudio(_ sender: UIButton) {
            if Reachability.isConnectedToNetwork(){
                let word = words[currentIndex % words.count]
                let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
                let wordStr: String = cardWord.headWord
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
    
    func removeLastVocabRecord(index: Int, cardBehavior: CardBehavior){
        vocabRecordsOfCurrentLearning[index].ReviewDUEDates = []
        print(vocabRecordsOfCurrentLearning[index].ReviewDUEDates)
        switch cardBehavior {
        case .forget:
            vocabRecordsOfCurrentLearning[index].ForgetDates.removeLast()
        case .remember:
            vocabRecordsOfCurrentLearning[index].RememberDates.removeLast()
        case .trash:
            vocabRecordsOfCurrentLearning[index].MasteredDate = initDateByString(dateString: "3030/01/01 00:00")
        default:
            return
        }
    }
    
    @IBAction func backOneCard(_ sender: UIButton) {
        if self.currentIndex > 0
        {
            disableBtns()
            self.currentIndex -= 1
            self.updateProgressLabel(index: self.currentIndex)
            let thisCard = cards[(currentIndex + 1) % 2]
            thisCard.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            let lastCard = cards[currentIndex % 2]
            lastCard.layer.removeAllAnimations()
            lastCard.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            let word = words[currentIndex % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            let collect = card_collect_behaviors[currentIndex] == .yes ? true: false
            setFieldsOfCard(card: lastCard, cardWord: cardWord, collected: collect)
            removeLastVocabRecord(index: currentIndex, cardBehavior: card_behaviors[currentIndex])
            
            let wordStr: String = lastCard.wordLabel?.text ?? ""
            if let mp3_url = getWordPronounceURL(word: wordStr){
                playMp3(url: mp3_url)
            }
            let direction:CGFloat = card_behaviors[currentIndex] == CardBehavior.forget ? 1 : -1
            lastCard.center = CGPoint(x:  self.view.center.x + 400 * (direction), y: self.view.center.y + 75)
            lastCard.X_Constraint.constant = lastCard.center.x - self.view.center.x
            lastCard.Y_Constraint.constant = lastCard.center.y - self.view.center.y
            learnUIView.bringSubviewToFront(cards[currentIndex % 2])
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
            
            card_behaviors.removeLast()
            print(card_behaviors)
            enableBtns()
        }
        else{
            let alertCtl = presentAlert(title: "已达首张", message: "已经是第一张啦!", okText: "好的")
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    @IBAction func masterThisCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: "掌握", backgroundColor: .systemBlue, cardBehavior: .trash)
    }
    
    func addReviewDueDatesForVocabRecords(index: Int, cardBehavior: CardBehavior){
        let currentDate:Date = Date()
        switch cardBehavior {
        case .forget:
            let reviewDates = [currentDate.adding(durationVal: 5, durationType: .minute), currentDate.adding(durationVal: 30, durationType: .minute), currentDate.adding(durationVal: 12, durationType: .hour), currentDate.adding(durationVal: 1, durationType: .day), currentDate.adding(durationVal: 2, durationType: .day), currentDate.adding(durationVal: 4, durationType: .day), currentDate.adding(durationVal: 7, durationType: .day), currentDate.adding(durationVal: 15, durationType: .day)]
            vocabRecordsOfCurrentLearning[self.currentIndex].ReviewDUEDates = reviewDates
        case .remember:
            let reviewDates = [currentDate.adding(durationVal: 30, durationType: .minute), currentDate.adding(durationVal: 1, durationType: .day), currentDate.adding(durationVal: 4, durationType: .day), currentDate.adding(durationVal: 7, durationType: .day)]
            vocabRecordsOfCurrentLearning[self.currentIndex].ReviewDUEDates = reviewDates
        default:
            return
        }
        print(vocabRecordsOfCurrentLearning[self.currentIndex].ReviewDUEDates)
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
                    
                    switch cardBehavior{
                    case .remember:
                        vocabRecordsOfCurrentLearning[self.currentIndex].RememberDates.append(Date())
                        self.addReviewDueDatesForVocabRecords(index: self.currentIndex, cardBehavior: .remember)
                        self.card_behaviors.append(.remember)
                    case .forget:
                        vocabRecordsOfCurrentLearning[self.currentIndex].ForgetDates.append(Date())
                        self.addReviewDueDatesForVocabRecords(index: self.currentIndex, cardBehavior: .forget)
                        self.card_behaviors.append(.forget)
                    case .trash:
                        vocabRecordsOfCurrentLearning[self.currentIndex].MasteredDate = Date()
                        self.card_behaviors.append(.trash)
                    }
                    
                    print(self.card_behaviors)

                    let word: String = nextCard.wordLabel?.text ?? ""
                    if let mp3_url = getWordPronounceURL(word: word){
                        self.playMp3(url: mp3_url)
                    }

                    self.currentIndex += 1
                    self.perform(#selector(self.moveCard), with: nil, afterDelay: self.animationDuration)
                }
            }
        }
    }
    
    @IBAction func learntTheCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: "会了", backgroundColor: .systemGreen, cardBehavior: .remember)
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
        cardAnimation(rememberLabelText: "不熟", backgroundColor: .systemPink, cardBehavior: .forget)
    }
    
    @IBAction func addWordToCollection(_ sender: UIButton) {
        disableBtns()
        let card = cards[currentIndex % 2]
        let cardCollectedBehaviorPrevious: CardCollectBehavior = card_collect_behaviors[currentIndex]
        if cardCollectedBehaviorPrevious == .no{
            card_collect_behaviors[currentIndex] = .yes
            vocabRecordsOfCurrentLearning[currentIndex].CollectDate = Date()
            DispatchQueue.main.async {
                card.collectImageView.alpha = 1
                self.enableBtns()
            }
            
        }
        else{
            card_collect_behaviors[currentIndex] = .no
            vocabRecordsOfCurrentLearning[currentIndex].CollectDate = nil
            DispatchQueue.main.async {
                card.collectImageView.alpha = 0
                self.enableBtns()
            }
        }
    }
}
