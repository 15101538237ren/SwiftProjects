//
//  ReminderTimePickerViewController.swift
//  shuaci
//
//  Created by Honglei on 7/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme
import UserNotifications
import LeanCloud
import SwiftMessages

class ReminderTimePickerViewController: UIViewController {
    
    var currentUser: LCUser!
    var preference:Preference!
    var settingVC: SettingViewController?
    var mainPanelViewController: MainPanelViewController!
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextTimeLabel: UILabel!
    @IBOutlet weak var nextRemindTime: UILabel!
    @IBOutlet weak var doNotRemind: UIButton!
    @IBOutlet weak var setReminder: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addBlurBackgroundView(){
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
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
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "TableView.labelTextColor") as! String
        return viewBackgroundColor
    }
    
    
    func setupTheme(){
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        nextTimeLabel.theme_textColor = "TableView.labelTextColor"
        nextRemindTime.theme_textColor = "TableView.labelTextColor"
        doNotRemind.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        setReminder.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        timePicker.setValue(UIColor(hex: getDisplayTextColor()), forKeyPath: "textColor")
        view.backgroundColor = .clear
        addBlurBackgroundView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
    }
    
    func getNextReminderDate() -> String {
        let timePickerDate = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        let upComingDate = Calendar.current.nextDate(after: Date(), matching: timePickerDate, matchingPolicy: .nextTime)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = reminderFmtText
        return dateFormatter.string(from: upComingDate)
    }
    
    @IBAction func pickerSelectedTimeChanged(_ sender: UIDatePicker) {
        DispatchQueue.main.async {
            self.nextRemindTime.text = "\(self.getNextReminderDate())"
        }
    }
    
    func popNotificationMessage(){
        if !isKeyPresentInUserDefaults(key: notificationAskedKey){
            let messageView: NotificationAskView = try! SwiftMessages.viewFromNib()
            messageView.textView.text = everydayNotificationText
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
    
    @IBAction func setReminderClock(_ sender: UIButton) {
        popNotificationMessage()
    }
    
    func registerNotification(){
        let timePickerDate = Calendar.current.dateComponents([.hour, .minute], from: self.timePicker.date)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [self] (granted, error) in
            if granted {
                center.removePendingNotificationRequests(withIdentifiers:[ everyDayLearningReminderNotificationIdentifier])
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: timePickerDate, repeats: true)
                DispatchQueue.main.async {
                    preference.reminder_time = timePickerDate
                    savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
                    if let _ = settingVC{
                        settingVC!.preference = preference
                        settingVC!.mainPanelViewController.preference = preference
                    }
                }
                
                let content = UNMutableNotificationContent()
                content.body = notificationBodyText
                content.categoryIdentifier = "learnEveryday"
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: everyDayLearningReminderNotificationIdentifier, content: content, trigger: trigger)
                center.add(request)

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    if let _ = settingVC{
                        settingVC!.updateReminderTime()
                    }
                }
            } else {
                self.view.makeToast(notificationRejectedText, duration: durationOfNotificationText, position: .center)
            }
        }
    }
    
    @IBAction func removeReminderClock(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers:[everyDayLearningReminderNotificationIdentifier])
        preference.reminder_time = nil
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        if let _ = settingVC{
            settingVC!.preference = loadPreference(userId: currentUser.objectId!.stringValue!)
        }
        
        DispatchQueue.main.async { [self] in
            self.dismiss(animated: true, completion: nil)
            if let _ = settingVC{
                settingVC!.updateReminderTime()
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
