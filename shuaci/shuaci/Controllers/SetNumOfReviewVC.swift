//
//  SetNumOfReviewVC.swift
//  shuaci
//
//  Created by Honglei on 3/25/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

class SetNumOfReviewVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ntrLabel: UILabel!
    @IBOutlet weak var ttrLabel: UILabel!
    @IBOutlet weak var numToReviewLabel: UILabel!
    @IBOutlet weak var numWordPickerView: UIPickerView!
    @IBOutlet weak var setNumBtn: UIButton!
    var mainPanelViewController: MainPanelViewController!
    var vocab_rec_need_to_be_review:[VocabularyRecord]!
    var numToReview: Int = 0
    let number_of_words: [Int] = [10, 20, 30, 50]
    var number_of_wordsReal: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
        addBlurBackgroundView()
    }
    
    func initVC(){
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        ntrLabel.theme_textColor = "TableView.labelTextColor"
        ttrLabel.theme_textColor = "TableView.labelTextColor"
        numToReviewLabel.theme_textColor = "TableView.labelTextColor"
        setNumBtn.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        numWordPickerView.delegate = self
        numWordPickerView.dataSource = self
        numToReviewLabel.text = "\(vocab_rec_need_to_be_review.count)个"
        
        for ntv in number_of_words{
            if ntv < vocab_rec_need_to_be_review.count{
                number_of_wordsReal.append(ntv)
            }
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
        let vocabTRS = vocab_rec_need_to_be_review.shuffled()
        let vocabSelected:[VocabularyRecord] = Array<VocabularyRecord>(vocabTRS.choose(numToReview))
        initIndicator(view: self.mainPanelViewController.view)
        self.dismiss(animated: true, completion: {
            self.mainPanelViewController.loadReviewController(vocab_rec_need_to_be_review: vocabSelected)
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let itemLabel:String = "\(number_of_wordsReal[row])个"
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
}
