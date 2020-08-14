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
    @IBOutlet weak var everyDayNumWordLabel: UILabel!
    @IBOutlet weak var estDaysLabel: UILabel!
    @IBOutlet weak var ESTLabel: UILabel!
    @IBOutlet weak var ESTTime: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var memMethodSegCtrl: UISegmentedControl!
    @IBOutlet weak var memOrderSegCtrl: UISegmentedControl!
    @IBOutlet var title_To_Bottom_Y_Constraint: NSLayoutConstraint!
    
    var book: Book!
    var itemToDayDict: [Int: Int] = [:]
    var dayToItemDict: [Int: Int] = [:]
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
    let number_of_words: [Int] = [10, 20, 30, 40, 50, 100, 150, 200, 300, 400, 500]
    let number_of_chapters: [Int] = [1, 2, 3, 4, 5]
    var num_of_items : [Int] = []
    var num_days_to_complete: [Int] = []
    
    enum memMethod {
        case byWord
        case byChpater
    }
    
    enum memOrder {
        case byRandom
        case byAlphabet
        case byReversedAlphabet
    }
    
    var memMet: memMethod = .byWord
    var memOrd: memOrder = .byRandom
    
    @IBAction func memMethodChanged(_ sender: UISegmentedControl) {
        if memMethodSegCtrl.selectedSegmentIndex == 0{
            memMet = .byWord
        }
        else{
            memMet = .byChpater
        }
        refreshPickerView()
    }
    
    @IBAction func memOrderChanged(_ sender: UISegmentedControl) {
        if memOrderSegCtrl.selectedSegmentIndex == 0{
            memOrd = .byRandom
        }
        else if memOrderSegCtrl.selectedSegmentIndex == 1{
            memOrd = .byAlphabet
        }else{
            memOrd = .byReversedAlphabet
        }
        refreshPickerView()
    }
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "TableView.labelTextColor") as! String
        return viewBackgroundColor
    }
    
    func selectedFirstIndex(numWord: Int) -> Int{
        for i in 0..<num_of_items.count{
            if num_of_items[i] == numWord{
                return i
            }
        }
        return -1
    }
    
    func selectedSecondIndex(numDay: Int) -> Int{
        for i in 0..<num_days_to_complete.count{
            if num_days_to_complete[i] == numDay{
                return i
            }
        }
        return -1
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
    
    func refreshPickerView() {
        num_of_items = []
        num_days_to_complete = []
        itemToDayDict = [:]
        var num_days_to_complete_set: Set = Set<Int>()
        var tempItems:[Int] = []
        var numTot: Int = 0
        if memMet == .byWord{
            tempItems = number_of_words
            numTot = book.word_num
            DispatchQueue.main.async {
                self.everyDayNumWordLabel.text = "每日单词数"
            }
        }else{
            tempItems = number_of_chapters
            numTot = book.nchpt
            DispatchQueue.main.async {
                self.everyDayNumWordLabel.text = "每日Unit数"
            }
        }
        for item in tempItems{
            if item <= numTot{
                num_of_items.append(item)
                let numDayToComplete:Int = Int((Float(numTot) / Float(item)).rounded(.up))
                num_days_to_complete_set.insert(numDayToComplete)
                itemToDayDict[item] = numDayToComplete
                if dayToItemDict[numDayToComplete] == nil{
                    dayToItemDict[numDayToComplete] = item
                }
            }
        }
        
        for item in num_days_to_complete_set.sorted(by: >){
            num_days_to_complete.append(item)
        }
        
        
        dailyNumWordPickerView.reloadAllComponents()
        
        let selected_ind:Int = 0
        dailyNumWordPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
        
        let numOfDayToComplete: Int = itemToDayDict[num_of_items[selected_ind]] ?? 0
        let selected_second_ind:Int = selectedSecondIndex(numDay: numOfDayToComplete)
        if selected_second_ind >= 0{
            dailyNumWordPickerView.selectRow(selected_second_ind, inComponent: 1, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addBlurBackgroundView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
        
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        titleLabel.text = book.name
        setBtn.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        
        dailyNumWordPickerView.delegate = self
        dailyNumWordPickerView.dataSource = self
        loadContentFromBook()
    }
    
    func loadContentFromBook() {
        if book.nchpt == 1{
            DispatchQueue.main.async {
                self.memMethodLabel.isUserInteractionEnabled = false
                self.memMethodSegCtrl.isUserInteractionEnabled = false
                
                self.memMethodLabel.alpha = 0
                self.memMethodSegCtrl.alpha = 0
                
                self.memOrderLabel.text = "1. 背词顺序"
                self.everyDayPlanLabel.text = "2. 每日计划"
                
                self.title_To_Bottom_Y_Constraint.constant = -10
            }
            memMet = .byWord
        }
        refreshPickerView()
    }
    
    override func didReceiveMemoryWarning()
     {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     }
     
     // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return num_of_items.count
        }else{
            return num_days_to_complete.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var itemLabel:String = String(num_of_items[row])
        if component != 0{
            itemLabel = "\(num_days_to_complete[row])天"
        }
        return NSAttributedString(string: itemLabel, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: getDisplayTextColor()) ?? UIColor.black])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            let numOfDayToComplete: Int = itemToDayDict[num_of_items[row]] ?? 0
            
            let selected_second_ind:Int = selectedSecondIndex(numDay: numOfDayToComplete)
            if selected_second_ind >= 0{
                dailyNumWordPickerView.selectRow(selected_second_ind, inComponent: 1, animated: true)
            }
        }else{
            let numOfWord: Int = dayToItemDict[num_days_to_complete[row]] ?? 0
            
            let selected_ind:Int = selectedFirstIndex(numWord: numOfWord)
            if selected_ind >= 0{
                dailyNumWordPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
            }
        }
    }
    
}
