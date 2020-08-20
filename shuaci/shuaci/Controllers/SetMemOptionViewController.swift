//
//  SetMemOptionViewController.swift
//  shuaci
//
//  Created by 任红雷 on 8/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import SwiftTheme

class SetMemOptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memOrderLabel: UILabel!
    @IBOutlet weak var everyDayPlanLabel: UILabel!
    @IBOutlet weak var everyDayNumWordLabel: UILabel!
    @IBOutlet weak var estDaysLabel: UILabel!
    @IBOutlet weak var ESTLabel: UILabel!
    @IBOutlet weak var ESTTime: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var memOrderSegCtrl: UISegmentedControl!
    @IBOutlet var title_To_Bottom_Y_Constraint: NSLayoutConstraint!
    var setting_tableView: UITableView?
    var bookVC: BooksViewController?
    var mainPanelVC: MainPanelViewController?
    
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var book: Book!
    var bookIndex: Int!
    var itemToDayDict: [Int: Int] = [:]
    var dayToItemDict: [Int: Int] = [:]
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
    let number_of_words: [Int] = [10, 20, 30, 40, 50, 100, 150, 200, 300, 400, 500]
    var number_of_items:[Int] = []
    var num_days_to_complete: [Int] = []
    
    enum memOrder: Int {
        case byRandom = 1
        case byAlphabet = 2
        case byReversedAlphabet = 3
    }
    
    var memOrd: memOrder = .byRandom
    
    @IBAction func memOrderChanged(_ sender: UISegmentedControl) {
        if memOrderSegCtrl.selectedSegmentIndex == 0{
            memOrd = .byRandom
        }
        else if memOrderSegCtrl.selectedSegmentIndex == 1{
            memOrd = .byAlphabet
        }else{
            memOrd = .byReversedAlphabet
        }
    }
    
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 46.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "TableView.labelTextColor") as! String
        return viewBackgroundColor
    }
    
    func selectedFirstIndex(numWord: Int) -> Int{
        for i in 0..<number_of_items.count{
            if number_of_items[i] == numWord{
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
    
    func initPickerView() {
        num_days_to_complete = []
        itemToDayDict = [:]
        number_of_items = []
        var num_days_to_complete_set: Set = Set<Int>()
        
        for item in number_of_words{
            if item <= book.word_num{
                number_of_items.append(item)
                let numDayToComplete:Int = Int((Float(book.word_num) / Float(item)).rounded(.up))
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
        var selected_ind:Int = 0
        if let numWord = getPreference(key: "number_of_words_per_group") as? Int{
            selected_ind = selectedFirstIndex(numWord: numWord)
        }
        
        dailyNumWordPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
        
        let numOfDayToComplete: Int = itemToDayDict[number_of_items[selected_ind]] ?? 0
        let selected_second_ind:Int = selectedSecondIndex(numDay: numOfDayToComplete)
        if selected_second_ind >= 0{
            dailyNumWordPickerView.selectRow(selected_second_ind, inComponent: 1, animated: true)
        }
        
        if let memOrder = getPreference(key: "memOrder") as? Int{
            switch memOrder {
            case 1:
                memOrd = .byRandom
                memOrderSegCtrl.selectedSegmentIndex = 0
            case 2:
                memOrd = .byAlphabet
                memOrderSegCtrl.selectedSegmentIndex = 1
            case 3:
                memOrd = .byReversedAlphabet
                memOrderSegCtrl.selectedSegmentIndex = 2
            default:
                memOrd = .byRandom
                memOrderSegCtrl.selectedSegmentIndex = 0
            }
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
        initPickerView()
        refreshESTTimeLabel()
    }
    
    func refreshESTTimeLabel() {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = num_days_to_complete[dailyNumWordPickerView.selectedRow(inComponent: 1)]
        let estDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY年MM月dd日"
        let dateStr = dateFormatter.string(from: estDate)
        DispatchQueue.main.async {
            self.ESTTime.text = "\(dateStr)"
        }
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
            return number_of_items.count
        }else{
            return num_days_to_complete.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var itemLabel:String = String(number_of_items[row])
        if component != 0{
            itemLabel = "\(num_days_to_complete[row])天"
        }
        return NSAttributedString(string: itemLabel, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: getDisplayTextColor()) ?? UIColor.black])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            let numOfDayToComplete: Int = itemToDayDict[number_of_items[row]] ?? 0
            
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
        refreshESTTimeLabel()
    }
    
    func downloadBookJson(book: Book){
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            DispatchQueue.global(qos: .background).async {
            do {
                DispatchQueue.main.async {
                    self.initActivityIndicator(text: "书籍下载中")
                }
                if self.bookIndex >= 0 {
                    if let bookJson = resultsItems[self.bookIndex].get("data") as? LCFile {
                        let url = URL(string: bookJson.url?.stringValue ?? "")!
                        let data = try? Data(contentsOf: url)

                        if let jsonData = data {
                            savejson(fileName: book.identifier, jsonData: jsonData)
                            currentbook_json_obj = load_json(fileName: book.identifier)
                            clear_words()
                            update_words()
                            get_words()
                            DispatchQueue.main.async {
                                self.stopIndicator()
                                self.dismiss(animated: true, completion: {
                                     () -> Void in
                                        if let bookVC = self.bookVC{
                                            bookVC.dismiss(animated: false, completion: { () -> Void in
                                            if self.mainPanelVC != nil{
                                                self.mainPanelVC!.loadLearnController()
                                            }})
                                        }
                                })
                            }
                        }
                    }
                    }
                }
            }
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
        
    }
    func getSettingTextforTableView(number_of_words_per_group: Int) -> String {
        var order = "乱序"
        switch memOrd {
        case .byRandom:
            order = "乱序"
        case .byAlphabet:
            order = "顺序"
        case .byReversedAlphabet:
            order = "倒序"
        }
        return "\(order)  \(number_of_words_per_group)个/组"
    }
    
    @IBAction func setMemOption(_ sender: UIButton) {
        print(self.memOrd.rawValue)
        setPreference(key: "memOrder", value: self.memOrd.rawValue)
        setPreference(key: "current_book_id", value: self.book.identifier)
        let number_of_words_per_group:Int = number_of_words[dailyNumWordPickerView.selectedRow(inComponent: 0)]
        setPreference(key: "number_of_words_per_group", value: number_of_words_per_group)
        if bookVC != nil{
            downloadBookJson(book: book)
        }
        else
        {
            if setting_tableView != nil{
                let setText =  getSettingTextforTableView(number_of_words_per_group: number_of_words_per_group)
                DispatchQueue.main.async {
                    let indexPath_in_setting = IndexPath(row: 3, section: 0)
                    let cell_in_setting = self.setting_tableView!.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath_in_setting) as! SettingTableViewCell
                    cell_in_setting.valueLabel?.text = setText
                    self.setting_tableView!.reloadRows(at: [indexPath_in_setting], with: .none)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            update_words()
        }
    }
    
}
