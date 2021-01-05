//
//  LearnOrReviewFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 8/15/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class LearnOrReviewFinishViewController: UIViewController {
    var mainPanelViewController: MainPanelViewController!
    @IBOutlet var dragonBallImageView: UIImageView!
    @IBOutlet var qouteImageView: UIImageView!
    @IBOutlet var sentenceLabel: UILabel!
    @IBOutlet var transLabel: UILabel!
    @IBOutlet var cnSourceLabel: UILabel!
    @IBOutlet var numOfWordTodayValue: UILabel!
    @IBOutlet var numOfWordTodayLabel: UILabel!
    @IBOutlet var numMinuteTodayValue: UILabel!
    @IBOutlet var numMinuteTodayLabel: UILabel!
    @IBOutlet var insistDaysValue: UILabel!
    @IBOutlet var insistDaysLabel: UILabel!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numbOfPeopleOnline: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var dimUIView: UIView!
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            
            if viewTranslation.y > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func addBlurBackgroundView(){
        dimUIView.alpha = 1.0
        dimUIView.backgroundColor = .clear
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimUIView.insertSubview(blurEffectView, at: 0)
    }
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 46.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 220, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 200, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
        self.dimUIView.alpha = 0
    }
    
    @IBAction func unwind(segue: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDateLabel(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        let dateStr = formatter.string(from: Date())
        DispatchQueue.main.async {
            self.dateLabel.text = dateStr
        }
    }
    
    func setTodyWordNum() {
        let today = Date()
        let todayLearnRec = getLearningRecordsOf(date: today)
        let todayReviewRec = getReviewRecordsOf(date: today)
        var number_of_vocab_today:Int = 0
        var number_of_learning_secs_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.VocabRecHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.StartDate, to: lrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.VocabRecHeads.count
            let difference = Calendar.current.dateComponents([.second], from: rrec.StartDate, to: rrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        
        DispatchQueue.main.async {
            self.numOfWordTodayValue.text = "\(number_of_vocab_today)"
            let learning_mins_today = Double(number_of_learning_secs_today)/60.0
            if learning_mins_today > 1.0 || number_of_learning_secs_today == 0{
                self.numMinuteTodayValue.text = String(format: "%d", Int(round(learning_mins_today)))
            }
            else{
                self.numMinuteTodayValue.text = String(format: "%.1f", learning_mins_today)
            }
        }
    }
    
    func setInsistDay(){
        let numOfInsistDay = getNumOfDayInsist()
        print("坚持了\(numOfInsistDay)天✊")
        DispatchQueue.main.async {
            self.insistDaysValue.text = "\(numOfInsistDay)"
        }
    }
    
    func getQoute() {
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                let count_query = LCQuery(className: "Qoute")
                count_query.count{ count in
                    let count = count.intValue
                    if count > 0 {
                        let rand_index = Int.random(in: 0 ... count - 1)
                        let query = LCQuery(className: "Qoute")
                        query.limit = 1
                        query.skip = rand_index
                        _ = query.getFirst { result in
                            switch result {
                            case .success(object: let quote):
                                // wallpapers 是包含满足条件的 (className: "Wallpaper") 对象的数组
                                print("Downloaded Qoute \(rand_index)")
                                if let qoute_image = quote.get("img") as? LCFile {
                                    //let imgData = photoData.value as! LCData
                                    let url = URL(string: qoute_image.url?.stringValue ?? "")!
                                    DispatchQueue.global(qos: .background).async{
                                    do{
                                        let data = try? Data(contentsOf: url)
                                        if let imageData = data {
                                            if let image = UIImage(data: imageData){
                                                _ = savePhoto(image: image, name_of_photo: "today_quote.jpg")
                                                DispatchQueue.main.async {
                                                    self.qouteImageView.image = image
                                                    if let sentence = quote.sentence?.stringValue {
                                                        self.sentenceLabel.text = sentence
                                                    }
                                                    if let translation = quote.trans?.stringValue {
                                                        self.transLabel.text = translation
                                                    }
                                                    if let star = quote.star?.intValue {
                                                        self.dragonBallImageView.image = UIImage(named: "dragon_ball_star_\(star)")
                                                    }
                                                    if let source_cn = quote.source_cn?.stringValue {
                                                        self.cnSourceLabel.text = "——《\(source_cn)》"
                                                    }
                                                    if let source_cn = quote.source_cn?.stringValue {
                                                        self.cnSourceLabel.text = "——《\(source_cn)》"
                                                    }
                                                    self.stopIndicator()
                                                    self.view.layoutIfNeeded()
                                                }
                                            }
                                        }
                                    }}
                                }
                                break
                            case .failure(error: let error):
                                print(error.localizedDescription)
                                self.stopIndicator()
                            }
                        }
                    }
                }
            }
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    func loadScene(){
        addBlurBackgroundView()
        initActivityIndicator(text: "正在加载打卡数据😊..")
        getQoute()
        setTodyWordNum()
        setInsistDay()
        setDateLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "Global.barTitleColor"
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        loadScene()
    }

}
