//
//  ReminderTimePickerViewController.swift
//  shuaci
//
//  Created by Honglei on 7/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftGifOrigin

class ReminderTimePickerViewController: UIViewController {
    var settingVC: SettingViewController!
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nextRemindTime: UILabel!
    
    @IBOutlet weak var doNotRemind: UIButton!
    
    @IBOutlet weak var setReminder: UIButton!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addBlurBackgroundView(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addBlurBackgroundView()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func getNextReminderDate() -> String {
        let timePickerDate = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        let upComingDate = Calendar.current.nextDate(after: Date(), matching: timePickerDate, matchingPolicy: .nextTime)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日 HH:mm"
        return dateFormatter.string(from: upComingDate)
    }
    
    @IBAction func pickerSelectedTimeChanged(_ sender: UIDatePicker) {
        DispatchQueue.main.async {
            self.nextRemindTime.text = "\(self.getNextReminderDate())"
        }
    }
    
    @IBAction func setReminderClock(_ sender: UIButton) {
        let timePickerDate = Calendar.current.dateComponents([.hour, .minute], from: self.timePicker.date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateStr = dateFormatter.string(from: self.timePicker.date)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                center.removePendingNotificationRequests(withIdentifiers:[ everyDayLearningReminderNotificationIdentifier])
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: timePickerDate, repeats: true)
                
                setPreference(key: "reminder_time", value: dateStr)
                
                let content = UNMutableNotificationContent()
                content.body = "你的努力，终将成就自己。开始今天的单词学习吧😊"
                content.categoryIdentifier = "learnEveryday"
                content.sound = UNNotificationSound.default
                if let url = Bundle.main.url(forResource: "study.jpg", withExtension: nil) {
                    if let attachement = try? UNNotificationAttachment(identifier: "attachment", url: url, options: nil) {
                        content.attachments = [attachement]
                    }
                }
                
                let request = UNNotificationRequest(identifier: everyDayLearningReminderNotificationIdentifier, content: content, trigger: trigger)
                center.add(request)

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.settingVC.updateReminderTime()
                }
            } else {
                let ac = UIAlertController(title: "请开启通知权限以使用每日学习提醒", message: "", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func removeReminderClock(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers:[everyDayLearningReminderNotificationIdentifier])
        setPreference(key: "reminder_time", value: "")
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.settingVC.updateReminderTime()
        }
    }
    
    
}
