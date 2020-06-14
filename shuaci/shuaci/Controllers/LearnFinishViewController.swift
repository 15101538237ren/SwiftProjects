//
//  LearnFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 5/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import UserNotifications

class LearnFinishViewController: UIViewController {
    
    @IBOutlet var mainPanelViewController: MainPanelViewController!
    @IBOutlet var emojiImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var goReviewBtn: UIButton!
    @IBOutlet var learnMoreBtn: UIButton!
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
        center.removeAllPendingNotificationRequests()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                if let notification_request = add_notification_date(){
                    UNUserNotificationCenter.current().add(notification_request, withCompletionHandler: nil)
                }
                
            } else {
                print("User denied notification!")
            }
        }
    }
    
    func setUpView(){
        DispatchQueue.main.async {
            self.greetingLabel.text = "真棒，你又学习了\(vocabRecordsOfCurrentLearning.count)个单词!"
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func learnOneMoreGroup(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            self.mainPanelViewController.loadLearnController()
        }
    }
    
}
