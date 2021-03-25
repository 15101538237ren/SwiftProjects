//
//  FilterVocabHistoryVC.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/3/17.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import MBRadioCheckboxButton

class FilterVocabHistoryVC: UIViewController {
    var wordHistoryVC: WordHistoryViewController!
    var viewTranslation = CGPoint(x: 0, y: 0)
    @IBOutlet var periodSegCtrl: UISegmentedControl!
    @IBOutlet var statusSegCtrl: UISegmentedControl!
    
    var numOfContinuousMemTimes:[Int] = []
    
    @IBOutlet weak var option0: CheckboxButton!
    @IBOutlet weak var option1: CheckboxButton!
    @IBOutlet weak var option2: CheckboxButton!
    @IBOutlet weak var option3: CheckboxButton!
    var btnCtn = CheckboxButtonContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCtn.addButtons([option0, option1, option2, option3])
        btnCtn.delegate = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
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
    
    @IBAction func filter(_ sender: UIButton) {
        if periodSegCtrl.selectedSegmentIndex == 0 && statusSegCtrl.selectedSegmentIndex == 0 && numOfContinuousMemTimes.count == 0{
            view.makeToast("您什么也没做☹️", duration: 1.0, position: .center)
        }else{
            var period: VocabDatePeriod = .Unlimited
            switch periodSegCtrl.selectedSegmentIndex {
            case 0:
                period = .Unlimited
            case 1:
                period = .OneDay
            case 2:
                period = .ThreeDays
            case 3:
                period = .OneWeek
            default:
                break
            }
            
            var status: MemConstraint = .Unlimited
            switch statusSegCtrl.selectedSegmentIndex {
            case 0:
                status = .Unlimited
            case 1:
                status = .Overdue
            case 2:
                status = .Withindue
            default:
                break
            }
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: {
                    self.wordHistoryVC.vocabDatePeriod = period
                    self.wordHistoryVC.memConstraint = status
                    self.wordHistoryVC.numOfContinuousMemTimes = self.numOfContinuousMemTimes
                    self.wordHistoryVC.getGroupVocabs()
                })
             }
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilterVocabHistoryVC: CheckboxButtonDelegate {
    
    func chechboxButtonDidSelect(_ button: CheckboxButton) {
        numOfContinuousMemTimes.append(button.tag)
    }
    
    func chechboxButtonDidDeselect(_ button: CheckboxButton) {
        for ni in 0..<numOfContinuousMemTimes.count{
            if numOfContinuousMemTimes[ni] == button.tag{
                numOfContinuousMemTimes.remove(at: ni)
                break
            }
        }
    }
}
