//
//  SetMemOptionViewController.swift
//  shuaci
//
//  Created by 任红雷 on 8/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

class SetMemOptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memMethodLabel: UILabel!
    @IBOutlet weak var memOrderLabel: UILabel!
    @IBOutlet weak var everyDayPlanLabel: UILabel!
    @IBOutlet weak var ESTLabel: UILabel!
    @IBOutlet weak var ESTTime: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var memMethodSegCtrl: UISegmentedControl!
    @IBOutlet weak var memOrderSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
    let number_of_words: [Int] = [10, 20, 30, 40, 50, 100, 150, 200, 300]
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "TableView.labelTextColor") as! String
        return viewBackgroundColor
    }
    
    func selectedIndex() -> Int{
        let npg_pref:Int = getPreference(key: "number_of_words_per_group") as! Int
        for i in 0..<number_of_words.count{
            if number_of_words[i] == npg_pref{
                return i
            }
        }
        return 0
    }
    
    @objc func handleDismiss(sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func addBlurBackgroundView(){
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let btmView: UIView = UIView()
        btmView.frame = view.bounds
        btmView.backgroundColor = .white
        btmView.alpha = 0.8
        btmView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(btmView, at: 0)
        view.insertSubview(blurEffectView, at: 1)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addBlurBackgroundView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
        
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        setBtn.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        
        dailyNumWordPickerView.delegate = self
        dailyNumWordPickerView.dataSource = self
        let selected_ind:Int = selectedIndex()
        dailyNumWordPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning()
     {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     }
     
     // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return number_of_words.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(number_of_words[row]), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: getDisplayTextColor()) ?? UIColor.black])
    }
    
}
