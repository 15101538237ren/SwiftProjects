//
//  LearnOrReviewFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 8/15/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import Nuke
import SwiftMessages
import SwiftTheme

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
    var currentUser: LCUser!
    var preference:Preference!
    var vocabsLearned:[VocabularyRecord]!
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    func setElements(enable: Bool){
        self.view.isUserInteractionEnabled = enable
    }
    
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
        self.dismiss(animated: true, completion: {
            AppStoreReviewManager.requestReviewIfAppropriate()
        })
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
        let today_records = getRecordsOfDate(date: today)
        let todayLearnRec = today_records.filter { $0.recordType == 1}
        let todayReviewRec = today_records.filter { $0.recordType == 2}
        
        var number_of_vocab_today:Int = 0
        var number_of_learning_secs_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
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
                    if count.isSuccess {
                        let query = LCQuery(className: "Qoute")
                        if count.intValue > 0{
                            let rand_index = Int.random(in: 0 ... count.intValue - 1)
                            query.limit = 1
                            query.skip = rand_index
                        }
                        _ = query.getFirst { result in
                            switch result {
                            case .success(object: let quote):
                                // wallpapers 是包含满足条件的 (className: "Wallpaper") 对象的数组
                                if let file = quote.get("img") as? LCFile {
                                    
                                    let imgUrl = URL(string: file.url!.stringValue!)!
                                    
                                    _ = ImagePipeline.shared.loadImage(
                                        with: imgUrl,
                                        completion: { [self] response in
                                            self.stopIndicator()
                                            self.setElements(enable: true)
                                            switch response {
                                              case .failure:
                                                break
                                              case let .success(imageResponse):
                                                let image = imageResponse.image
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
                                                    
                                                    self.view.layoutIfNeeded()
                                                }
                                              }
                                        }
                                    )
                                }
                                break
                            case .failure(error: let error):
                                print(error.localizedDescription)
                                self.setElements(enable: true)
                                self.stopIndicator()
                            }
                        }
                    }else{
                        print(count.error)
                        self.setElements(enable: true)
                    }
                }
            }
            }
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            setElements(enable: true)
        }
    }
    
    func loadQouteScene(){
        addBlurBackgroundView()
        initActivityIndicator(text: loadingDakaText)
        setElements(enable: false)
        getQoute()
    }
    
    func loadScene(){
        loadQouteScene()
        setTodyWordNum()
        setInsistDay()
        setDateLabel()
        popNotificationMessage()
    }
    
    func popAlert(){
        if preference.reminder_time == nil && !isKeyPresentInUserDefaults(key: everydayNotificationViewedKey){
            let alertController = UIAlertController(title: reminderSettingText, message: reminderAskingText, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: okText, style: .default, handler: { [self] _ in
                loadSetReminderVC()
            })
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: everydayNotificationViewedKey)
        }else{
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        }
    }
    
    func loadSetReminderVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let reminderTimePickerVC = mainStoryBoard.instantiateViewController(withIdentifier: "reminderTimePickerVC") as! ReminderTimePickerViewController
        reminderTimePickerVC.settingVC = nil
        reminderTimePickerVC.preference = preference
        reminderTimePickerVC.currentUser = currentUser
        reminderTimePickerVC.mainPanelViewController = mainPanelViewController
        reminderTimePickerVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(reminderTimePickerVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "Global.barTitleColor"
        loadScene()
    }
    override func viewDidAppear(_ animated: Bool) {
        popAlert()
    }
    func popNotificationMessage(){
        if !isKeyPresentInUserDefaults(key: notificationAskedKey){
            let messageView: NotificationAskView = try! SwiftMessages.viewFromNib()
            messageView.textView.text = ebbinhausNotificationText
            messageView.configureDropShadow()
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            messageView.agreeAction = {
                //同意开启通知
                UserDefaults.standard.set(true, forKey: notificationAskedKey)
                SwiftMessages.hide()
                //设置艾宾浩斯提醒⏰
                self.registerNotification()
            }
            messageView.cancelAction = {
                //不同意通知，不提醒。
                SwiftMessages.hide()
                self.view.makeToast(notificationRejectedText, duration: durationOfNotificationText, position: .center)
            }
            
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            config.duration = .forever
            config.presentationStyle = .center
            config.dimMode = .blur(style: .light, alpha: 0.6, interactive: false)
            SwiftMessages.show(config: config, view: messageView)
        }else{
            registerNotification()
        }
    }
    
    func registerNotification() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    if let nextReviewDate = obtainNextReviewDate(vocabs: self.vocabsLearned) {
                        if let notification_request = add_notification_date(notification_date: nextReviewDate){
                            UNUserNotificationCenter.current().add(notification_request, withCompletionHandler: nil)
                            
                            DispatchQueue.main.async {
                                self.view.makeToast("\(basedOnMemLawsText) \(nicknameOfApp) \(willText) \(printDate(date: nextReviewDate)) \(willRemindText)", duration: durationOfNotificationText, position: .center)
                            }
                        }
                    }
                } else {
                    self.view.makeToast(notificationRejectedText, duration: durationOfNotificationText, position: .center)
                }
            }
        }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if let currentUser = LCApplication.default.currentUser {
            var pref = loadPreference(userId: currentUser.objectId!.stringValue!)
            if traitCollection.userInterfaceStyle == .dark{
                pref.dark_mode = true
            }else{
                pref.dark_mode = false
            }
            savePreference(userId: currentUser.objectId!.stringValue!, preference: pref)
            mainPanelViewController.update_preference()
            mainPanelViewController.loadWallpaper(force: true)
            if pref.dark_mode{
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: theme_category_to_name[pref.current_theme]!.rawValue, path: .mainBundle)
            }
        }
    }
}
