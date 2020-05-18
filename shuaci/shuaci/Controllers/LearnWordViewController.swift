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
    @IBOutlet var learnUIView: LearnUIView!
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    
    var secondsPST:Int = 0 // number of seconds past after load
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    var json_obj: JSON = load_json(fileName: "current_book")
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.15
    var words:[JSON] = []
    
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
        super.viewDidLoad()
        get_words()
        setCardBackground()
        initCards()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
        DispatchQueue.main.async {
            self.timeLabel.text = timeString(time: self.secondsPST)
        }
        startTimer()
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
    
    func get_words(){
        let vocabRanks:[Int] = learntVocabRanks()
        let number_of_word_per_day_exist = isKeyPresentInUserDefaults(key: npw_key)
        var number_of_word_per_day = 100
        if number_of_word_per_day_exist{
            number_of_word_per_day = UserDefaults.standard.integer(forKey: npw_key)
        }
        else{
            UserDefaults.standard.set(number_of_word_per_day, forKey: npw_key)
        }
        let word_list = json_obj["data"]
        let number_of_words_in_json:Int = word_list.count
        let word_ids = Array(0...number_of_words_in_json)
        let diff_ids:[Int] = word_ids.difference(from: vocabRanks)
        let sampling_number:Int = min(number_of_word_per_day, diff_ids.count)
        let sampled_ids = diff_ids.choose(sampling_number)
        for i in 0..<sampling_number{
            words.append(word_list[sampled_ids[i]])
        }
        self.updateProgressLabel(index: self.currentIndex)
    }
    
    func updateProgressLabel(index: Int){
        DispatchQueue.main.async {
            self.progressLabel.text = "\(index + 1)/\(self.words.count)"
        }
    }
    
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index]
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            let word = words[index % words.count]
            let wordRank: Int = word["wordRank"].intValue
            card.wordLabel?.text = word["headWord"].stringValue
            let content = word["content"]["word"]["content"].dictionaryValue
            if let trans = content["trans"]?.arrayValue
            {
                var stringArr:[String] = []
                for tran in trans{
                    let pos = tran["pos"].stringValue
                    let current_meaning = tran["tranCn"].stringValue
                    let current_meaning_replaced = current_meaning.replacingOccurrences(of: "；", with: "\n")
                    stringArr.append("\(pos).\(current_meaning_replaced)")
                }
                card.meaningLabel?.text = stringArr.joined(separator: "\n")
            }
            
            card.accentLabel?.text = "美"
            card.phoneticLabel?.text = content["usphone"]?.stringValue
            card.rememberImageView?.backgroundColor = UIColor.systemGreen
            card.rememberImageView?.alpha = 0
            card.rememberLabel?.text = "会了"
            card.rememberLabel?.alpha = 0
            card.speech? = "\(current_book_id)__\(wordRank)_0"
            if index == 1
            {
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            }
        }
    }
    
    func getFeildsOfWord(word: JSON, usphone: Bool) -> CardWord{
        let wordRank: Int = word["wordRank"].intValue
        let headWord: String = word["headWord"].stringValue
        let content = word["content"]["word"]["content"].dictionaryValue
        var meaning = ""
        if let trans = content["trans"]?.arrayValue
        {
            var stringArr:[String] = []
            for tran in trans{
                let pos = tran["pos"].stringValue
                let current_meaning = tran["tranCn"].stringValue
                let current_meaning_replaced = current_meaning.replacingOccurrences(of: "；", with: "\n")
                stringArr.append("\(pos).\(current_meaning_replaced)")
                meaning = stringArr.joined(separator: "\n")
            }
        }
        let speech = "\(current_book_id)__\(wordRank)_0"
        let phoneType = (usphone == true)  ? "usphone" : "ukphone"
        let phone = content[phoneType]?.stringValue ?? ""
        let accent = (usphone == true)  ? "美" : "英"
        let cardWord = CardWord(wordRank: wordRank, headWord: headWord, meaning: meaning, phone: phone, speech: speech, accent: accent)
        return cardWord
    }
    
    func setFieldsOfCard(card: CardUIView, cardWord: CardWord){
        card.wordLabel?.text = cardWord.headWord
        card.meaningLabel?.text = cardWord.meaning
        card.phoneticLabel?.text = cardWord.phone
        card.speech? = cardWord.speech
        card.accentLabel?.text = cardWord.accent
    }
    
    @objc func moveCard() {
        self.updateProgressLabel(index: self.currentIndex)
        let card = cards[(currentIndex + 1) % 2]
        let word = words[(currentIndex + 1) % words.count]
        let cardWord = self.getFeildsOfWord(word: word, usphone: getUSPhone())
        setFieldsOfCard(card: card, cardWord: cardWord)
        learnUIView.bringSubviewToFront(cards[currentIndex % 2])
        resetCard(card: card)
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        
            let card = sender.view! as! CardUIView
            let point = sender.translation(in: view)
            
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
            let xFromCenter = card.center.x - view.center.x
            
            card.X_Constraint.constant = point.x
            card.Y_Constraint.constant = point.y
            sender.view!.frame = card.frame
            
            let scale = min(0.35 * view.frame.width / abs(xFromCenter), 1.0)
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
            card.transform = CGAffineTransform(rotationAngle: 0.61 * xFromCenter / view.center.x).scaledBy(x: scale, y: scale)
            let nextCard = cards[(currentIndex + 1) % 2]
            let relScale = scaleOfSecondCard + (abs(xFromCenter) / view.center.x) * (1.0 - scaleOfSecondCard)
            nextCard.transform = CGAffineTransform(scaleX: relScale, y: relScale)
            
        if sender.state == UIGestureRecognizer.State.ended
            {
                if card.center.x < (0.4 * view.frame.width)
                {
                    
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
                    self.currentIndex += 1
                    perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
                    return
                }
                else if card.center.x > (0.6 * view.frame.width)
                {
                    UIView.animate(withDuration: animationDuration, animations:
                    {
                        card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                        card.X_Constraint.constant = card.center.x - self.view.center.x
                        card.Y_Constraint.constant = card.center.y - self.view.center.y
                        card.alpha = 0
                    })

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
        
        func playMp3(filename: String)
        {
            guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return }
            do {
                mp3Player = try AVAudioPlayer(contentsOf: url)
                mp3Player?.play()
            } catch {
                print("couldn't load file :( \(url)")
            }
        }
        
        @IBAction func playAudio(_ sender: UIButton) {
            let word = words[currentIndex % words.count]
            let content = word["content"]["word"]["content"]
            let wordRank: Int = word["wordRank"] as! Int
            
            guard let url = Bundle.main.url(forResource: "\(current_book_id)__\(wordRank)_0", withExtension: "mp3") else { return }
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("couldn't load file :( \(url)")
                //
            }
        }
    
    
    @IBAction func backOneCard(_ sender: UIButton) {
        self.currentIndex -= 1
        self.updateProgressLabel(index: self.currentIndex)
        let lastCard = cards[currentIndex % 2]
    }
    
    @IBAction func masterThisCard(_ sender: UIButton) {
    }
    
    
    @IBAction func learntTheCard(_ sender: UIButton) {
    }
    
    @IBAction func cardDifficultToLearn(_ sender: UIButton) {
    }
    
    @IBAction func addWordToCollection(_ sender: UIButton) {
    }
}
