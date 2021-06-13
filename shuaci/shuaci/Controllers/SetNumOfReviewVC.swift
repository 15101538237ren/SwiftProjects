//
//  SetNumOfReviewVC.swift
//  shuaci
//
//  Created by Honglei on 3/25/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme
import LeanCloud

class SetNumOfReviewVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ntrLabel: UILabel!
    @IBOutlet weak var ttrLabel: UILabel!
    @IBOutlet weak var numToReviewLabel: UILabel!
    @IBOutlet weak var numWordPickerView: UIPickerView!
    @IBOutlet weak var setNumBtn: UIButton!
    var viewTranslation = CGPoint(x: 0, y: 0)
    var mainPanelViewController: MainPanelViewController!
    var vocab_rec_need_to_be_review:[VocabularyRecord]!
    var numToReview: Int = 10
    let number_of_words: [Int] = [10, 20, 30, 50]
    var number_of_wordsReal: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
        addBlurBackgroundView()
    }
    
    func initVC(){
        stopIndicator()
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        ntrLabel.theme_textColor = "TableView.labelTextColor"
        ttrLabel.theme_textColor = "TableView.labelTextColor"
        numToReviewLabel.theme_textColor = "TableView.labelTextColor"
        setNumBtn.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        numWordPickerView.delegate = self
        numWordPickerView.dataSource = self
        numToReviewLabel.text = "\(vocab_rec_need_to_be_review.count)\(geText)"
        
        for ntv in number_of_words{
            if ntv <= vocab_rec_need_to_be_review.count{
                number_of_wordsReal.append(ntv)
            }
        }
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(sender:))))
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
        view.backgroundColor = .clear
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        number_of_wordsReal.count
    }
    
    
    @IBAction func setNumToReview(_ sender: UIButton) {
        var vocabSelected:[VocabularyRecord] = vocab_rec_need_to_be_review
        if vocab_rec_need_to_be_review.count > numToReview
        {
            vocabSelected = Array(vocab_rec_need_to_be_review.sorted(by: {$0.LearnDate!.compare($1.LearnDate!) == .orderedDescending}).prefix(numToReview))
        }
        initIndicator(view: self.mainPanelViewController.view)
        self.dismiss(animated: true, completion: {
            self.mainPanelViewController.loadReviewController(vocab_rec_need_to_be_review: vocabSelected)
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let itemLabel:String = "\(number_of_wordsReal[row])\(geText)"
        return NSAttributedString(string: itemLabel, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: getDisplayTextColor()) ?? UIColor.black])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numToReview = number_of_wordsReal[row]
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "TableView.labelTextColor") as! String
        return viewBackgroundColor
    }
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
