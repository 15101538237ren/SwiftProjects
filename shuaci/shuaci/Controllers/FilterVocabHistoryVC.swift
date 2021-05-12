//
//  FilterVocabHistoryVC.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/3/17.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import MBRadioCheckboxButton
import SwiftTheme

class FilterVocabHistoryVC: UIViewController {
    var wordHistoryVC: WordHistoryViewController!
    var viewTranslation = CGPoint(x: 0, y: 0)
    @IBOutlet var periodSegCtrl: UISegmentedControl!
    @IBOutlet var statusSegCtrl: UISegmentedControl!
    
    var numOfContinuousMemTimes:[Int] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var vocabDateLabel: UILabel!
    @IBOutlet weak var memStatusLabel: UILabel!
    @IBOutlet weak var continuesMemLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var smallView: UIView!
    
    @IBOutlet weak var option0: CheckboxButton!
    @IBOutlet weak var option1: CheckboxButton!
    @IBOutlet weak var option2: CheckboxButton!
    @IBOutlet weak var option3: CheckboxButton!
    var btnCtn = CheckboxButtonContainer()
    
    func addBlurBackgroundView(){
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    
    func setupTheme(){
        view.backgroundColor = .clear
        smallView.backgroundColor = .clear
        addBlurBackgroundView()
        
        backBtn.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        filterBtn.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        option0.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        option1.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        option2.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        option3.theme_setTitleColor("Global.barTitleColor", forState: .normal)
        
        titleLabel.theme_textColor = "TableView.labelTextColor"
        vocabDateLabel.theme_textColor = "Global.barTitleColor"
        memStatusLabel.theme_textColor = "Global.barTitleColor"
        continuesMemLabel.theme_textColor = "Global.barTitleColor"
        periodSegCtrl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        periodSegCtrl.theme_selectedSegmentTintColor = "WordHistory.segmentedCtrlSelectedTintColor"
        periodSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        periodSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getThemeColor(key: "WordHistory.segTextColor")) ?? .darkGray], for: .normal)
        statusSegCtrl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        statusSegCtrl.theme_selectedSegmentTintColor = "WordHistory.segmentedCtrlSelectedTintColor"
        statusSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        statusSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getThemeColor(key: "WordHistory.segTextColor")) ?? .darkGray], for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
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
            view.makeToast(youDidNothingText, duration: 1.0, position: .center)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            ThemeManager.setTheme(plistName: "Light_White", path: .mainBundle)
        } else {
            ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
        }
    }
}
