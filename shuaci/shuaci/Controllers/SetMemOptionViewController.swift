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
import Disk

class SetMemOptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Enumerates
    enum memOrder: Int {
        case byRandom = 1
        case byAlphabet = 2
        case byReversedAlphabet = 3
    }
    
    // MARK: - Outlet Variables
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
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
    func setElements(enable: Bool){
        self.backBtn.isUserInteractionEnabled = enable
        self.view.isUserInteractionEnabled = enable
        self.setBtn.isUserInteractionEnabled = enable
        self.memOrderSegCtrl.isUserInteractionEnabled = enable
    }
    
    
    // MARK: - Variables
    var settingVC: SettingViewController?
    var bookVC: BooksViewController?
    var mainPanelVC: MainPanelViewController?
    
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var book: Book!
    var bookIndex: Int!
    
    var itemToDayDict: [Int: Int] = [:]
    var dayToItemDict: [Int: Int] = [:]
    
    var number_of_items:[Int] = []
    var num_days_to_complete: [Int] = []
    var viewTranslation = CGPoint(x: 0, y: 0)
    var memOrd: memOrder = .byRandom
    
    var currentUser: LCUser!
    var preference:Preference!
    
    // MARK: - Constants
    let number_of_words: [Int] = [5, 10, 20, 30, 40, 50, 100]
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    // MARK: - Outlet Actions
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
    
    func updateUserCurrentBook(currentBook:Book){
        do {
            try currentUser.set("currentBook", value: book.name)
            currentUser.save { result in
                switch result{
                case .success:
                    print("user's currentBook saved successfully ")
                    break
                case .failure(error: let error):
                    print(error.reason ?? "failed to save VocabRecords")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateBookDownloadNum(bookObjId: String){
        do {
            let book = LCObject(className: "Book", objectId: bookObjId)
            // 对 balance 原子减少 100
            try book.increase("recite_user_num", by: 1)
            book.save() { (result) in
                switch result {
                case .success:
                    print("词库下载数已更新")
                case .failure(error: let error):
                    print(error.description)
                }
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func setMemOption(_ sender: UIButton) {
        let nwpg = number_of_words[dailyNumWordPickerView.selectedRow(inComponent: 0)]
        preference.memory_order = self.memOrd.rawValue
        
        preference.current_book_id = self.book.identifier
        
        preference.current_book_name = self.book.name
        
        preference.number_of_words_per_group = nwpg
        
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        
        if let mainVC = mainPanelVC{
            mainVC.update_preference()
        }
        if let settingVC = settingVC{
            settingVC.update_preference(pref: preference)
        }
        
        if bookVC != nil{
            let info = ["Um_Key_ButtonName" : "\(book.name)", "Um_Key_SourcePage":"选了书", "Um_Key_UserID" : currentUser.objectId!.stringValue!]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
            updateBookDownloadNum(bookObjId: book.objectId)
            updateUserCurrentBook(currentBook: book)
            downloadBookJson(book: book)
        }
        else
        {
            if settingVC != nil{
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.settingVC!.updateMemOptionDisplay()
                    })
                }
            }
            _ = update_words(preference: preference)
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
    
    @objc func handleSlideDismiss(sender: UIPanGestureRecognizer) {
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
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    func addBlurBackgroundViewWithGray(){
            let blurEffect = getBlurEffect()
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let btmView: UIView = UIView()
            btmView.frame = view.bounds
            btmView.theme_backgroundColor = "Global.viewBackgroundColor"
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
        
        selected_ind = selectedFirstIndex(numWord: preference.number_of_words_per_group)
        
        dailyNumWordPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
        
        let numOfDayToComplete: Int = itemToDayDict[number_of_items[selected_ind]] ?? 0
        let selected_second_ind:Int = selectedSecondIndex(numDay: numOfDayToComplete)
        if selected_second_ind >= 0{
            dailyNumWordPickerView.selectRow(selected_second_ind, inComponent: 1, animated: true)
        }
        let memory_order = preference.memory_order
        
        switch memory_order {
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
    
    func setupTheme(){
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        titleLabel.theme_textColor = "TableView.labelTextColor"
        everyDayNumWordLabel.theme_textColor = "TableView.labelTextColor"
        memOrderLabel.theme_textColor = "TableView.labelTextColor"
        everyDayPlanLabel.theme_textColor = "TableView.labelTextColor"
        estDaysLabel.theme_textColor = "TableView.labelTextColor"
        ESTLabel.theme_textColor = "TableView.labelTextColor"
        ESTTime.theme_textColor = "TableView.labelTextColor"
        setBtn.theme_setTitleColor("TableView.labelTextColor", forState: .normal)
        view.backgroundColor = .clear
        
        if let _ = bookVC{
            addBlurBackgroundViewWithGray()
        }else{
            addBlurBackgroundView()
        }
        
        memOrderSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        memOrderSegCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getThemeColor(key: "WordHistory.segTextColor")) ?? .darkGray], for: .normal)
        memOrderSegCtrl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        memOrderSegCtrl.theme_selectedSegmentTintColor = "WordHistory.segmentedCtrlSelectedTintColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleSlideDismiss(sender:))))
        
        view.isUserInteractionEnabled = true
        
        titleLabel.text = book.name
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
        dateFormatter.dateFormat = dateFmtText
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
            itemLabel = "\(num_days_to_complete[row])\(daysText)"
        }
        return NSAttributedString(string: itemLabel, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: getThemeColor(key: "TableView.labelTextColor")) ?? UIColor.black])
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
        if !Disk.exists("\(book.identifier).json", in: .documents){
            if Reachability.isConnectedToNetwork(){
                DispatchQueue.global(qos: .background).async { [self] in
                do {
                    DispatchQueue.main.async {
                        self.initActivityIndicator(text: downloadingBookText)
                        self.setElements(enable: false)
                    }
                    if self.bookIndex >= 0 {
                        if let bookJson = resultsItems[self.bookIndex].get("data") as? LCFile {
                            let url = URL(string: bookJson.url?.stringValue ?? "")!
                            let data = try? Data(contentsOf: url)

                            if let jsonData = data {
                                savejson(fileName: book.identifier, jsonData: jsonData)
                                currentbook_json_obj = load_json(fileName: book.identifier)
                                preference.current_book_id = book.identifier
                                preference.current_book_name = book.name
                                savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
                                if let mainVC = mainPanelVC{
                                    mainVC.update_preference()
                                }
                                if let settingVC = settingVC{
                                    settingVC.update_preference(pref: preference)
                                    settingVC.updateMemOptionDisplay()
                                }
                                _ = update_words(preference: preference)
                                DispatchQueue.main.async {
                                    self.stopIndicator()
                                    self.dismiss(animated: true, completion: {
                                         () -> Void in
                                            if let bookVC = self.bookVC{
                                                bookVC.dismiss(animated: false, completion: { () -> Void in
                                                if self.mainPanelVC != nil{
                                                    self.mainPanelVC!.loadLearnController()
                                                }})
                                                if let profileVC = bookVC.userProfileVC{
                                                    profileVC.updateBookName()
                                                }
                                            }
                                    })
                                }
                            }
                        }
                        }
                    }
                }
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
        }
        else{
            currentbook_json_obj = load_json(fileName: book.identifier)
            preference.current_book_id = book.identifier
            preference.current_book_name = book.name
            savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
            
            if let mainVC = mainPanelVC{
                mainVC.update_preference()
            }
            
            if let settingVC = settingVC{
                settingVC.update_preference(pref: preference)
                settingVC.updateMemOptionDisplay()
            }
            
            _ = update_words(preference: preference)
            DispatchQueue.main.async {
                self.stopIndicator()
                self.dismiss(animated: true, completion: {
                     () -> Void in
                        if let bookVC = self.bookVC{
                            bookVC.dismiss(animated: false, completion: { () -> Void in
                                if self.mainPanelVC != nil{
                                    self.mainPanelVC!.loadLearnController()
                                }
                                if let profileVC = bookVC.userProfileVC{
                                    profileVC.updateBookName()
                                }
                            })
                        }
                })
            }
        }
        
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
            if let mainPVC = mainPanelVC{
                mainPVC.update_preference()
                mainPVC.loadWallpaper(force: true)
            }
            
            if pref.dark_mode{
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: theme_category_to_name[pref.current_theme]!.rawValue, path: .mainBundle)
            }
        }
    }
}
