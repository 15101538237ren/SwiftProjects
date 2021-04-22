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

class MainScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    var isGetUserInfo = false
    @IBOutlet var mainScreenUIView: MainScreenUIView!
    @IBOutlet var launchUIView: UIView!
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
                                CardWord.init(headWord: "rainforest", meaning: "n. 雨林", memMethod: "rain(雨) + forest(森林) → 雨林"),
                                CardWord.init(headWord: "starfish", meaning: "n. 海星", memMethod: "star(星星) + fish(鱼) → 星形鱼 → 海星"),
                                CardWord.init(headWord: "strawberry", meaning: "n.草莓", memMethod: "straw(稻)草 + berry (浆果) → 草莓"),
                                CardWord.init(headWord: "cupcake", meaning: "n.纸杯蛋糕", memMethod: "cup(杯子) + cake(蛋糕) → 纸杯蛋糕"),
                                CardWord.init(headWord: "glacier", meaning: "n. 冰河，冰川", memMethod: "glac(冰) + ier → 冰川"),
                                CardWord.init(headWord: "bookmark", meaning: "n.书签", memMethod: "book(书) + mark(标记) → 书签"),
                                CardWord.init(headWord: "rainbow", meaning: "n.彩虹", memMethod: "rain(雨) ＋ bow(弓) → 雨后天边出现如弓的彩虹 → 彩虹"),
                                CardWord.init(headWord: "metropolis", meaning: "n.大都市", memMethod: "metro(大的) + polis(城市) → 大都市"),
                                CardWord.init(headWord: "armchair", meaning: "n. 扶手椅", memMethod: "arm(手臂) + chair(椅子) → 可以放手臂的椅子"),
                                CardWord.init(headWord: "sunhat", meaning: "n.遮阳帽", memMethod: "sun(太阳) + hat(帽) → 遮阳帽"),
                                CardWord.init(headWord: "ceramic", meaning: "adj.陶器的", memMethod: "ceram(陶瓷) + ic → 陶器的"),
                                CardWord.init(headWord: "doughnut", meaning: "n.甜甜圈", memMethod: "dough(面团) + nut(坚果、核心) → 核心空心的带坚果的面团"),
                                CardWord.init(headWord: "galaxy", meaning: "n.星系；银河系", memMethod: "ˈ源自希腊文galaxias， 词根gala意为乳汁。"),
                                CardWord.init(headWord: "snowflake", meaning: "n. 雪花", memMethod: "snow(雪) ＋ flake(片) → 雪花,雪片"),
                                CardWord.init(headWord: "crosswalk", meaning: "n.人行横道", memMethod: "cross(交叉，十字) + walk(走) → 十字路口供行人走的路"),
                                CardWord.init(headWord: "cliff", meaning: "n. 悬崖", memMethod: "cli(看作climb， 爬) ＋ ff(像两个钩子) → 用钩子攀岩 → 悬崖， 峭壁"),
                                CardWord.init(headWord: "sunflower", meaning: "n. 向日葵", memMethod: "sun(太阳) + flower(花) → 向日葵又称太阳花"),
                                CardWord.init(headWord: "necklace", meaning: "n. 项链", memMethod: "neck(脖子) + lace(绳，花边，蕾丝) → 项链"),
                                CardWord.init(headWord: "cowboy", meaning: "n. 牛仔", memMethod: "cow(母牛) + boy(男孩) → 农场管理母牛的男孩 → 牛仔")]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initVC()
    }
    
    func initVC(){
        if let user = LCApplication.default.currentUser {
            showMainPanel(currentUser: user)
        }
        else {
            load_DICT()
            initCards()
            let card = cards[0]
            let xshift:CGFloat = card.frame.size.width/8.0
            card.transform = CGAffineTransform(translationX: -xshift, y:0.0).rotated(by: -xshift*0.61/card.center.x)
            UIView.animate(withDuration: 1.0, animations: {
                self.launchUIView.alpha = 0.0
            })
        }
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
            card.cardBackView?.alpha = 0
            card.cardBackView?.isUserInteractionEnabled = false
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
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backToCardFront(_:)) )
            tapGesture.delegate = self
            card.cardBackView?.webView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBAction func backToCardFront(_ sender: UITapGestureRecognizer) {
        let card = cards[currentIndex % 2]
        card.cardBackView!.isUserInteractionEnabled = false
        card.cardBackView!.alpha = 0
        card.dragable = true
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
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
            card.rememberLabel?.text = forgetText
        }
        else
        {
            card.rememberImageView?.backgroundColor = UIColor.systemGreen
            card.rememberLabel?.text = rememberedText
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
    
    func showMainPanel(currentUser: LCUser){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainPanelViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainPanelViewController") as! MainPanelViewController
        mainPanelViewController.modalPresentationStyle = .fullScreen
        mainPanelViewController.currentUser = currentUser
        DispatchQueue.main.async {
            self.present(mainPanelViewController, animated: false, completion: {
                self.launchUIView.alpha = 0.0
            })
            
        }
    }
    
    
    @IBAction func showPhoneLoginVC(_ sender: UIButton) {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.mainScreenVC = self
        loginVC.loginType = .Phone
        DispatchQueue.main.async {
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func showEmailLoginVC(_ sender: UIButton) {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.mainScreenVC = self
        loginVC.loginType = .Email
        DispatchQueue.main.async {
            self.present(loginVC, animated: true, completion: nil)
        }
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
        if Reachability.isConnectedToNetwork(){
            let cardWord = cardWords[currentIndex % cardWords.count]
            let wordStr: String = cardWord.headWord
            if let mp3_url = getWordPronounceURL(word: wordStr, fromMainScreen: true){
                playMp3(url: mp3_url)
            }
        }
    }
    
    
    @IBAction func wexinLogin(_ sender: UIButton) {
        
    }
    
}
