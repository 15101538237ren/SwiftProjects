//
//  ReviewWordViewController.swift
//  shuaci
//
//  Created by Honglei on 6/13/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class ReviewWordViewController: UIViewController {
    var mainPanelViewController: MainPanelViewController!
    
    var vocab_rec_need_to_be_review:[VocabularyRecord] = []
    var review_words: [JSON] = []
    var card_behaviors:[CardBehavior] = [] //forget: 0, remember: 1, trash: 2
    var card_collect_behaviors: [CardCollectBehavior] = [] //collect: 1, else 0
    
    @IBOutlet var learnUIView: LearnUIView!
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    @IBOutlet var gestureRecognizers:[UIPanGestureRecognizer]!
    var secondsPST:Int = 0 // number of seconds past after load
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    var isCardBack: Bool = false //whether the card is front or back end
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.15
    
    func setCardBackground(){
        let current_theme_category = getPreference(key: "current_theme_category") as! Int
        for card in cards{
            card.cardImageView?.image = UIImage(named: cardBackgrounds[current_theme_category]!)
        }
    }
    
    override func viewDidLoad() {
        vocab_rec_need_to_be_review = get_vocab_rec_need_to_be_review()
        review_words = get_words_need_to_be_review(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
        view.backgroundColor = UIColor(red: 238, green: 241, blue: 245, alpha: 1.0)
        
        super.viewDidLoad()
        currentReviewRec.StartDate = Date()
    }
    
    @objc func relayout(){
        for index in [currentIndex, currentIndex+1]{
            let word = review_words[index % review_words.count]
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
    
    @IBAction func ExitReview(_ sender: UIButton) {
        if self.currentIndex > 0{
            let alertController = UIAlertController(title: "是否保存当前复习记录?", message: "", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
                currentReviewRec.EndDate = Date()
                var currentReivewedRecords:[VocabularyRecord] = []
                for index in 0 ..< self.currentIndex{
                    currentReivewedRecords.append(vocabRecordsOfCurrentReview[index])
                }
                currentReviewRec.VocabRecIds = getVocabIdsFromVocabRecords(VocabRecords: currentReivewedRecords)
                saveReviewRecordsFromReview(vocabs_updated: currentReivewedRecords)
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil)
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
    
    func updateProgressLabel(index: Int){
        DispatchQueue.main.async {
            self.progressLabel.text = "\(index + 1)/\(self.review_words.count)"
        }
    }
    
    func playMp3GivenWord(word: String){
        let auto_pronunciation:Bool = getPreference(key: "auto_pronunciation") as! Bool
        let mp3_url = getWordPronounceURL(word: word)
        if auto_pronunciation && (mp3_url != nil) {
            playMp3(url: mp3_url!)
        }
    }
    
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index]
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            let word = review_words[index % review_words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            setFieldsOfCard(card: card, cardWord: cardWord, collected: false)
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
    
    
    
    func setFieldsOfCard(card: CardUIView, cardWord: CardWord, collected: Bool){
        let numberOfNewlines:Int = cardWord.meaning.components(separatedBy: "\n").count - 1
        var meaningLabelTxt:String = cardWord.meaning
        if numberOfNewlines > 3{
            var finalStringArr:[String] = []
            let meaningArr:[String] = meaningLabelTxt.components(separatedBy: "\n")
            for mi in 0..<meaningArr.count - 1{
                if let firstChr = meaningArr[mi + 1].unicodeScalars.first{
                    if firstChr.isASCII{
                        finalStringArr.append("\(meaningArr[mi])\n")
                    }else{
                        finalStringArr.append("\(meaningArr[mi])；")
                    }
                }
            }
            meaningLabelTxt = finalStringArr.joined(separator: "")
        }
        card.wordLabel?.text = cardWord.headWord
        DispatchQueue.main.async {
            if cardWord.headWord.count >= 10{
                card.wordLabel?.font = card.wordLabel?.font.withSize(40.0)
            }else{
                card.wordLabel?.font = card.wordLabel?.font.withSize(45.0)
            }
            
            card.meaningLabel?.text = meaningLabelTxt
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
        vocabRecordsOfCurrentReview = vocab_rec_need_to_be_review
        for index in 0..<review_words.count
        {
            if let _ = vocab_rec_need_to_be_review[index].CollectDate {
                card_collect_behaviors.append(.yes)
            }
            else{
                card_collect_behaviors.append(.no)
            }
        }
    }
    
    
    @objc func moveCard() {
        if currentIndex >= review_words.count{
            currentReviewRec.EndDate = Date()
            currentReviewRec.VocabRecIds = getVocabIdsFromVocabRecords(VocabRecords: vocabRecordsOfCurrentReview)
            saveReviewRecordsFromReview(vocabs_updated: vocabRecordsOfCurrentReview)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.mainPanelViewController.loadReviewFinishController()
            }
        }
        else if currentIndex < review_words.count - 1{
            self.updateProgressLabel(index: self.currentIndex)
            let card = cards[(currentIndex + 1) % 2]
            let word = review_words[(currentIndex + 1) % review_words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            let collected = card_collect_behaviors[currentIndex + 1] == .yes ? true : false
            setFieldsOfCard(card: card, cardWord: cardWord, collected: collected)
            let next_card = cards[currentIndex % 2]
            next_card.dragable = !next_card.dragable
            card.dragable = !card.dragable
            
            learnUIView.bringSubviewToFront(next_card)
            resetCard(card: card)
            enableBtns()
        }
        else{
            let card = cards[(currentIndex + 1) % 2]
            let next_card = cards[currentIndex % 2]
            
            next_card.dragable = !next_card.dragable
            card.dragable = !card.dragable
            self.updateProgressLabel(index: self.currentIndex)
            enableBtns()
        }
    }
    
    func isBtnEnabled() -> Bool{
        return self.learnUIView.collectBtn.isEnabled
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
                card.rememberImageView?.backgroundColor = UIColor.systemPink
                card.rememberLabel?.text = "不熟"
            }
            else
            {
                card.rememberImageView?.backgroundColor = UIColor.systemGreen
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
                    vocabRecordsOfCurrentReview[currentIndex].BehaviorHistory.append(CardBehavior.remember.rawValue)
                    vocabRecordsOfCurrentReview[self.currentIndex].ReviewDUEDate = Date().adding(durationVal: calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory), durationType: .second)
                    card_behaviors.append(.remember)
                    
                    let word: String = nextCard.wordLabel?.text ?? ""
                    playMp3GivenWord(word: word)
                    
                    self.currentIndex += 1
                    perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
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
                    vocabRecordsOfCurrentReview[currentIndex].BehaviorHistory.append(CardBehavior.forget.rawValue)
                    vocabRecordsOfCurrentReview[self.currentIndex].ReviewDUEDate = Date().adding(durationVal: calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory), durationType: .second)
                    card_behaviors.append(.forget)
                    
                    let word: String = nextCard.wordLabel?.text ?? ""
                    playMp3GivenWord(word: word)

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
        enableBtns()
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
            if Reachability.isConnectedToNetwork(){
                let word = review_words[currentIndex % review_words.count]
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
        vocabRecordsOfCurrentReview[index].ReviewDUEDate = nil
        switch cardBehavior {
        case .forget:
            vocabRecordsOfCurrentReview[index].BehaviorHistory.removeLast()
        case .remember:
            vocabRecordsOfCurrentReview[index].BehaviorHistory.removeLast()
        case .trash:
            vocabRecordsOfCurrentReview[index].Mastered = false
            vocabRecordsOfCurrentReview[index].MasteredDate = nil
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
            
            thisCard.dragable = !thisCard.dragable
            lastCard.dragable = !lastCard.dragable
            
            lastCard.layer.removeAllAnimations()
            lastCard.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            let word = review_words[currentIndex % review_words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            let collect = card_collect_behaviors[currentIndex] == .yes ? true: false
            setFieldsOfCard(card: lastCard, cardWord: cardWord, collected: collect)
            removeLastVocabRecord(index: currentIndex, cardBehavior: card_behaviors[currentIndex])
            
            let wordStr: String = lastCard.wordLabel?.text ?? ""
            playMp3GivenWord(word: wordStr)
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
            enableBtns()
        }
        else{
            let alertCtl = presentAlert(title: "已经是第一张啦!", message: "", okText: "好的")
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    @IBAction func masterThisCard(_ sender: UIButton) {
        cardAnimation(rememberLabelText: "掌握", backgroundColor: .systemBlue, cardBehavior: .trash)
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
                        vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory.append(CardBehavior.remember.rawValue)
                        vocabRecordsOfCurrentReview[self.currentIndex].ReviewDUEDate = Date().adding(durationVal: calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory), durationType: .second)
                        self.card_behaviors.append(.remember)
                    case .forget:
                        vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory.append(CardBehavior.forget.rawValue)
                        vocabRecordsOfCurrentReview[self.currentIndex].ReviewDUEDate = Date().adding(durationVal: calcSecondsDurationGivenBehaviorHistory(cardBehaviorHistory: vocabRecordsOfCurrentReview[self.currentIndex].BehaviorHistory), durationType: .second)
                        self.card_behaviors.append(.forget)
                    case .trash:
                        vocabRecordsOfCurrentReview[self.currentIndex].Mastered = true
                        if vocabRecordsOfCurrentReview[self.currentIndex].MasteredDate == nil{
                            vocabRecordsOfCurrentReview[self.currentIndex].MasteredDate = Date()
                        }
                        self.card_behaviors.append(.trash)
                    }
                    let word: String = nextCard.wordLabel?.text ?? ""
                    self.playMp3GivenWord(word: word)

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
            vocabRecordsOfCurrentReview[currentIndex].CollectDate = Date()
            DispatchQueue.main.async {
                card.collectImageView.alpha = 1
                self.enableBtns()
            }
            
        }
        else{
            card_collect_behaviors[currentIndex] = .no
            vocabRecordsOfCurrentReview[currentIndex].CollectDate = nil
            DispatchQueue.main.async {
                card.collectImageView.alpha = 0
                self.enableBtns()
            }
        }
    }
}
