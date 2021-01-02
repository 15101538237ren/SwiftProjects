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
    var mp3Player: AVAudioPlayer?
    var scaleOfSecondCard:CGFloat = 0.9
    var currentIndex:Int = 0
    let animationDuration = 0.1
    
    var cardWords:[CardWord] = [
                                CardWord.init(headWord: "forest", meaning: "n. 森林", phone: "ˈfɔːrɪst"),
                                CardWord.init(headWord: "sea", meaning: "n.海；海洋", phone: "siː"),
                                CardWord.init(headWord: "canyon", meaning: "n. 峡谷", phone: "ˈkænjən"),
                                CardWord.init(headWord: "aurora", meaning: "n.极光；曙光", phone: "ɔ:'rɔ:rə"),
                                CardWord.init(headWord: "coast", meaning: "n. 海岸", phone: "koʊst"),
                                CardWord.init(headWord: "bonfire", meaning: "n. 篝火", phone: "ˈbɑːnfaɪər"),
                                CardWord.init(headWord: "glacier", meaning: "n. 冰河，冰川", phone: "ˈɡleɪʃər"),
                                CardWord.init(headWord: "marriage", meaning: "n. 结婚；婚姻", phone: "ˈmærɪdʒ"),
                                CardWord.init(headWord: "metropolis", meaning: "n. 大都市", phone: "məˈtrɑːpəlɪs"),
                                CardWord.init(headWord: "Paris", meaning: "n.巴黎", phone: "'pærɪs"),
                                CardWord.init(headWord: "Cappuccino", meaning: "n. 卡布奇诺咖啡", phone: "ˌkæpuˈtʃiːnoʊ"),
                                CardWord.init(headWord: "strawberry", meaning: "n. 草莓", phone: "ˈstrɔːberi"),
                                CardWord.init(headWord: "galaxy", meaning: "n.星系；银河系", phone: "ˈɡæləksi"),
                                CardWord.init(headWord: "character", meaning: "n. 角色；特性", phone: "ˈkærəktər"),
                                CardWord.init(headWord: "cliff", meaning: "n. 悬崖", phone: "klɪf"),
                                CardWord.init(headWord: "hiking", meaning: "n. 徒步旅行", phone: "ˈhaɪkɪŋ"),
                                CardWord.init(headWord: "avocado", meaning: "n. 牛油果；鳄梨", phone: "ˌævəˈkɑːdoʊ"),
                                CardWord.init(headWord: "bridge", meaning: "n. 桥", phone: "brɪdʒ"),
                                CardWord.init(headWord: "portrait", meaning: "n. 人像", phone: "ˈpɔːrtrət"),
                                CardWord.init(headWord: "beach", meaning: "n.海滩，沙滩", phone: "bitʃ"),
                                CardWord.init(headWord: "robot", meaning: "n. 机器人", phone: "ˈroʊbɑːt"),
                                CardWord.init(headWord: "penguin", meaning: "n. 企鹅", phone: "ˈpeŋɡwɪn"),
                                CardWord.init(headWord: "smile", meaning: "n.微笑", phone: "smaɪl")]
    override func viewDidLoad() {
        super.viewDidLoad()
        initCards()
        let card = cards[0]
        let xshift:CGFloat = card.frame.size.width/8.0
        card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
    }
    
    func setFieldsOfCard(card: CardUIView, cardWord: CardWord){
        DispatchQueue.main.async {
            card.wordLabel?.text = cardWord.headWord
            if cardWord.headWord.count >= 12{
                card.wordLabel?.font = card.wordLabel?.font.withSize(40.0)
            }else{
                card.wordLabel?.font = card.wordLabel?.font.withSize(45.0)
            }
            
            card.meaningLabel?.text = cardWord.meaning
            if cardWord.memMethod != ""{
                card.wordLabel_Top_Space_Constraint.constant = 110
                card.memMethodLabel?.alpha = 1
                card.memMethodLabel?.text = "记: \(cardWord.memMethod)"
            }
            else{
                card.wordLabel_Top_Space_Constraint.constant = 130
                card.memMethodLabel?.alpha = 0
            }
            card.cardImageView?.image = UIImage(named: cardWord.headWord)
        }
    }
    
    func resetCard(card: CardUIView)
    {
        card.X_Constraint.constant = 0
        card.Y_Constraint.constant = 0
        card.rememberImageView?.backgroundColor = UIColor.white
        card.cardImageView?.image = UIImage()
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.text = ""
        card.rememberLabel?.alpha = 0
        card.memMethodLabel?.text = ""
        card.memMethodLabel?.alpha = 0
        card.layer.removeAllAnimations()
        card.transform = CGAffineTransform.identity.scaledBy(x: scaleOfSecondCard, y: scaleOfSecondCard)
        card.center = CGPoint(x: view.center.x, y: view.center.y)
        card.alpha = 1
    }
    
    func initCards() {
        for index in 0..<cards.count
        {
            let card = cards[index % cards.count]
            card.center = CGPoint(x: view.center.x, y: view.center.y)
            let cardWord = cardWords[index % cardWords.count]
            setFieldsOfCard(card: card, cardWord: cardWord)
            if index == 1
            {
                card.transform = CGAffineTransform(scaleX: scaleOfSecondCard, y: scaleOfSecondCard)
                card.dragable = false
            }
            else
            {
                if let mp3_url = getWordPronounceURL(word: cardWord.headWord, fromMainScreen: true){
                    playMp3(url: mp3_url)
                }
            }
        }
    }
    
    @objc func moveCard() {
        self.mp3Player?.stop()
        let card = cards[(currentIndex + 1) % 2]
        let cardWord = cardWords[(currentIndex + 1) % cardWords.count]
        setFieldsOfCard(card: card, cardWord: cardWord)
        let next_card = cards[currentIndex % 2]
        next_card.dragable = true
        card.dragable = false
        mainScreenUIView.bringSubviewToFront(next_card)
        resetCard(card: card)
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {

        let card = sender.view! as! CardUIView
        if !card.dragable{
            return
        }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
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
        card.rememberImageView?.alpha = 0.7 + (abs(xFromCenter) / view.center.x) * 0.3
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
                    card.X_Constraint.constant = card.center.x - self.view.center.x
                    card.Y_Constraint.constant = card.center.y - self.view.center.y
                    card.alpha = 0
                    
                })
                sender.view!.frame = card.frame
                let word: String = nextCard.wordLabel?.text ?? ""
                if let mp3_url = getWordPronounceURL(word: word, fromMainScreen: true){
                    playMp3(url: mp3_url)
                }
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
                let word: String = nextCard.wordLabel?.text ?? ""
                if let mp3_url = getWordPronounceURL(word: word, fromMainScreen: true){
                    playMp3(url: mp3_url)
                }
                self.currentIndex += 1
                perform(#selector(moveCard), with: nil, afterDelay: animationDuration)
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
        card.Y_Constraint.constant = 0
        card.rememberImageView?.alpha = 0
        card.rememberLabel?.alpha = 0.0
        card.transform = .identity
    }
    
    func showMainPanel(){
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainPanelViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "mainPanelViewController") as! MainPanelViewController
        mainPanelViewController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(mainPanelViewController, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func showLoginVC(_ sender: UIButton) {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let loginVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.mainScreenVC = self
        DispatchQueue.main.async {
            self.present(loginVC, animated: true, completion: nil)
        }
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
            let alertCtl = presentNoNetworkAlert()
            if non_network_preseted == false{
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
        
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            let cardWord = cardWords[currentIndex % cardWords.count]
            let wordStr: String = cardWord.headWord
            if let mp3_url = getWordPronounceURL(word: wordStr, fromMainScreen: true){
                playMp3(url: mp3_url)
            }
        }else{
            let alertCtl = presentNoNetworkAlert()
            UIApplication.topViewController()?.present(alertCtl, animated: true, completion: nil)
        }
        
    }
    
    
    
}
