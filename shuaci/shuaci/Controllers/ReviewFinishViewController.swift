//
//  LearnFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 5/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import UserNotifications

class ReviewFinishViewController: UIViewController {
    
    @IBOutlet var mainPanelViewController: MainPanelViewController!
    @IBOutlet var emojiImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        setUpView()
        registerNotification()
        super.viewDidLoad()
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
    
    @objc func registerNotification() {
        let center = UNUserNotificationCenter.current()
//        center.removeAllPendingNotificationRequests()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                if let nextReviewDate = obtainNextReviewDate() {
                    if let notification_request = add_notification_date(notification_date: nextReviewDate){
                        UNUserNotificationCenter.current().add(notification_request, withCompletionHandler: nil)
                        
                        DispatchQueue.main.async {
                            let ac = UIAlertController(title: "复习提醒", message: "根据艾宾浩斯记忆曲线，我们将在\(printDate(date: nextReviewDate))提醒您复习哦", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                            self.present(ac, animated: true, completion: nil)
                        }
                    }
                }
                
            } else {
                let ac = UIAlertController(title: "请开启【通知】权限以使用艾宾浩斯智能提醒", message: "", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func setUpView(){
        DispatchQueue.main.async {
            self.greetingLabel.text = "真棒，你又复习了\(vocabRecordsOfCurrentReview.count)个单词!"
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
