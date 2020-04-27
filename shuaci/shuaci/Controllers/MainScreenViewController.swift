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
    @IBOutlet var cards: [CardUIView]!
    
    var audioPlayer: AVAudioPlayer?
    
    var currentIndex:Int = 0
    
    var words: [Word] = [
        Word(wordHead: "sea", trans: [["tranCn":"n. 海；海洋", "pos": "n"]], usphone: "siː", ukphone: "siː", usspeech: "sea_0", ukspeech: "sea_1", remMethod: "", relWords: [], phrases: [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "beach", trans: [["tranCn":"海滩，沙滩", "tranOther":"an area of sand or small stones at the edge of the sea or a lake", "pos":"n"]], usphone: "bitʃ", ukphone: "biːtʃ", usspeech: "beach_0", ukspeech: "beach_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "Paris", trans: [["tranCn":"n.巴黎","pos":"n"]], usphone: "'pærɪs", ukphone: "'pærɪs", usspeech: "Paris_0", ukspeech: "Paris_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "aurora", trans: [["tranCn":"[地物] 极光；曙光","pos":"n"]], usphone: "ɔ:'rɔ:rə", ukphone: "ɔ:'rɔ:rə", usspeech: "aurora_0", ukspeech: "aurora_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "pharmacy", trans: [["tranCn":"药房；配药学，药剂学；制药业；一批备用药品", "tranOther":"a shop or a part of a shop where medicines are prepared and sold", "pos":"n"]], usphone: "'fɑrməsi", ukphone: "'fɑːməsɪ", usspeech: "pharmacy_0", ukspeech: "pharmacy_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]])]
    
    
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
            card.rememberImageView?.image = UIImage(named: "bushou")
            card.speech? = word.usspeech
        }
    }
    func moveCard() {
        let card = cards[(currentIndex + 1) % 2]
        let word = words[(currentIndex + 1) % words.count]
        
        card.cardImageView?.image = UIImage(named: word.wordHead)
        card.wordLabel?.text = word.wordHead
        card.meaningLabel?.text = word.trans[0]["tranCn"]!
        card.accentLabel?.text = "美"
        card.phoneticLabel?.text = word.usphone
        card.rememberImageView?.image = UIImage(named: "bushou")
        card.rememberImageView?.alpha = 0
        card.speech? = word.usspeech
        card.transform = .identity
        card.alpha = 1
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        card.layer.zPosition = 20
        mainScreenUIView.bringSubviewToFront(cards[currentIndex % 2])
        mainScreenUIView.sendSubviewToBack(card)
//        let card1 = cards[1]
//        card1.layer.zPosition = 0
        //cards.append(card)
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {

        let card = sender.view! as! CardUIView
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        let alpha = max(1.5 * (abs(xFromCenter) / view.center.x), 1.0)
        
        let scale = min(0.35 * view.frame.width / abs(xFromCenter), 1.0)
        card.transform = CGAffineTransform(rotationAngle: 0.61 * xFromCenter / view.center.x).scaledBy(x: scale, y: scale)
        if xFromCenter > 0
        {
            card.rememberImageView?.image = UIImage(named: "bushou")
        }
        else
        {
            card.rememberImageView?.image = UIImage(named: "huile")
        }
        card.rememberImageView?.alpha = alpha
        
        
        if sender.state == UIGestureRecognizer.State.ended
        {
            if card.center.x < (0.25 * view.frame.width)
            {
                UIView.animate(withDuration: 0.3, animations:
                {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                self.currentIndex += 1
                self.moveCard()
                return
            }
            else if card.center.x > (0.75 * view.frame.width)
            {
                UIView.animate(withDuration: 0.3, animations:
                {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                self.currentIndex += 1
                self.moveCard()
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

