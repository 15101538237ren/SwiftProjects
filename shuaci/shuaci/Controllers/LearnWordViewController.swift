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
        super.viewDidLoad()
        setCardBackground()
        initCards()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
        DispatchQueue.main.async {
            self.timeLabel.text = timeString(time: self.secondsPST)
        }
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
            setFieldsOfCard(card: card, cardWord: cardWord)
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
        let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
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
        if self.currentIndex > 0
        {
            self.currentIndex -= 1
            self.updateProgressLabel(index: self.currentIndex)
            let thisCard = cards[(currentIndex + 1) % 2]
            thisCard.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            let lastCard = cards[currentIndex % 2]
            lastCard.layer.removeAllAnimations()
            lastCard.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            let word = words[currentIndex % words.count]
            let cardWord = getFeildsOfWord(word: word, usphone: getUSPhone())
            setFieldsOfCard(card: lastCard, cardWord: cardWord)
            
            let wordStr: String = lastCard.wordLabel?.text ?? ""
            if let mp3_url = getWordPronounceURL(word: wordStr){
                playMp3(url: mp3_url)
            }
            
            lastCard.center = CGPoint(x:  self.view.center.x + 400, y: self.view.center.y + 75)
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
        }
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
