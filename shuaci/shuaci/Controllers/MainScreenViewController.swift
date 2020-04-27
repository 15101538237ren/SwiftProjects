//
//  ViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import AVFoundation

class MainScreenViewController: UIViewController {
    @IBOutlet var mainScreenUIView: MainScreenUIView!
    @IBOutlet var cards: [CardUIView]!{
        didSet {
            for card in cards{
                card.layer.cornerRadius = 20.0
                card.layer.masksToBounds = true
            }
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.1
    var words: [Word] = [
        Word(wordHead: "sea", trans: [["tranCn":"n.海；海洋", "pos": "n"]], usphone: "siː", ukphone: "siː", usspeech: "sea_0", ukspeech: "sea_1", remMethod: "", relWords: [], phrases: [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n.海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "beach", trans: [["tranCn":"n.海滩，沙滩", "tranOther":"an area of sand or small stones at the edge of the sea or a lake", "pos":"n"]], usphone: "bitʃ", ukphone: "biːtʃ", usspeech: "beach_0", ukspeech: "beach_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "Paris", trans: [["tranCn":"n.巴黎","pos":"n"]], usphone: "'pærɪs", ukphone: "'pærɪs", usspeech: "Paris_0", ukspeech: "Paris_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "aurora", trans: [["tranCn":"n.极光；曙光","pos":"n"]], usphone: "ɔ:'rɔ:rə", ukphone: "ɔ:'rɔ:rə", usspeech: "aurora_0", ukspeech: "aurora_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "pharmacy", trans: [["tranCn":"n.药房；药学；制药业", "tranOther":"a shop or a part of a shop where medicines are prepared and sold", "pos":"n"]], usphone: "'fɑrməsi", ukphone: "'fɑːməsɪ", usspeech: "pharmacy_0", ukspeech: "pharmacy_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]])]
    
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCards()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
    }
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index]
            let word = words[index % words.count]
            card.cardImageView?.image = UIImage(named: word.wordHead)
            card.wordLabel?.text = word.wordHead
            card.meaningLabel?.text = word.trans[0]["tranCn"]!
            card.accentLabel?.text = "美"
            card.phoneticLabel?.text = word.usphone
            card.rememberImageView?.backgroundColor = UIColor.systemGreen
            card.rememberImageView?.alpha = 0
            card.rememberLabel?.text = "会了"
            card.rememberLabel?.alpha = 0
            card.speech? = word.usspeech
            if index == 1
            {
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
            }
        }
    }
    @objc func moveCard() {
        let card = cards[(currentIndex + 1) % 2]
        let word = words[(currentIndex + 1) % words.count]
        
        card.cardImageView?.image = UIImage(named: word.wordHead)
        card.wordLabel?.text = word.wordHead
        card.meaningLabel?.text = word.trans[0]["tranCn"]!
        card.accentLabel?.text = "美"
        card.phoneticLabel?.text = word.usphone
        card.rememberImageView?.backgroundColor = UIColor.white
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.text = ""
        card.rememberLabel?.alpha = 0
        card.speech? = word.usspeech
        card.layer.removeAllAnimations()
        card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        mainScreenUIView.bringSubviewToFront(cards[currentIndex % 2])
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
    
    
    @IBAction func playAudio(_ sender: UIButton) {
        guard let url = Bundle.main.url(forResource: words[currentIndex % words.count].usspeech, withExtension: "mp3") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("couldn't load file :( \(url)")
            //
        }
    }
    
}

