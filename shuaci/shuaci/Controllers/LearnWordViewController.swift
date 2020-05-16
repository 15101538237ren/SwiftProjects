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
    var json: JSON = load_json(book_id: current_book_id)
    var audioPlayer: AVAudioPlayer?
    var mp3Player: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.1
    var words:[JSON] = []
    func setCardBackground(){
        let theme_category_exist = isKeyPresentInUserDefaults(key: theme_category_string)
        var theme_category  = 1
        if theme_category_exist{
            theme_category = UserDefaults.standard.integer(forKey: theme_category_string)
        }
            
        for card in cards{
            card.cardImageView?.image = UIImage(named: cardBackgrounds[theme_category]!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_words(json_obj: json)
        setCardBackground()
        initCards()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func get_words(json_obj:JSON){
        let number_of_word_per_day_exist = isKeyPresentInUserDefaults(key: "number_of_word_per_day")
        var number_of_word_per_day  = 100
        if number_of_word_per_day_exist{
            number_of_word_per_day = UserDefaults.standard.integer(forKey: "number_of_word_per_day")
        }
        let number_of_words_in_json:Int = json_obj.count
        let sampling_number:Int = min(number_of_word_per_day, number_of_words_in_json)
        let word_ids = Array(0...number_of_words_in_json)
        let sampled_ids = word_ids.choose(sampling_number)
        print(json_obj["data"])
        for i in 0...sampling_number{
            words.append(json_obj["data"][sampled_ids[i]])
        }
    }
    
    
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index]
            let word = words[index % words.count]
            let wordRank: Int = word["wordRank"] as! Int
            card.wordLabel?.text = word["headWord"] as! String
            let content = word["content"]["word"]["content"]
            let trans:[[String:String]] = content["trans"] as! [[String:String]]
            
            var stringArr:[String] = []
            for tran in trans{
                let current_meaning = tran["tranCn"] as! String
                stringArr.append(current_meaning)
            }
            card.meaningLabel?.text = stringArr.joined(separator: "\n")
            card.accentLabel?.text = "美"
            card.phoneticLabel?.text = content["usphone"] as! String
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
    
    @objc func moveCard() {
        let card = cards[(currentIndex + 1) % 2]
        let word = words[(currentIndex + 1) % words.count]
        
        let wordRank: Int = word["wordRank"] as! Int
        card.wordLabel?.text = word["headWord"] as! String
        let content = word["content"]["word"]["content"]
        let trans:[[String:String]] = content["trans"] as! [[String:String]]
        
        var stringArr:[String] = []
        for tran in trans{
            let current_meaning = tran["tranCn"] as! String
            stringArr.append(current_meaning)
        }
        
        card.meaningLabel?.text = stringArr.joined(separator: "\n")
        card.speech? = "\(current_book_id)__\(wordRank)_0"
        card.phoneticLabel?.text = content["usphone"] as! String
        card.accentLabel?.text = "美"
        card.rememberImageView?.backgroundColor = UIColor.white
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.text = ""
        card.rememberLabel?.alpha = 0
        card.layer.removeAllAnimations()
        card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        learnUIView.bringSubviewToFront(cards[currentIndex % 2])
        card.alpha = 1
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {

            let card = sender.view! as! CardUIView
            let point = sender.translation(in: view)
            let xFromCenter = card.center.x - view.center.x
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
            
    //        let alpha = min(1.5 * (abs(xFromCenter) / view.center.x) + 0.6, 1.0)
            
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
                    })
                    playMp3(filename: "Ninja_Jump_1")
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
                        card.alpha = 0
                    })
                    
                    playMp3(filename: "incorrect")
                    self.currentIndex += 1
                    perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
                    return
                }
                resetCard(card: card)
            }
        }
        func resetCard(card: CardUIView)
        {
            UIView.animate(withDuration: 0.2, animations:
            {
                card.center = self.view.center
                card.alpha = 1
            })
            card.rememberImageView?.alpha = 0
            card.rememberLabel?.alpha = 0.0
            card.transform = .identity
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
    
}
