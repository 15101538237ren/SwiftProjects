//
//  WordHistoryViewController.swift
//  shuaci
//
//  Created by Honglei on 7/11/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme
import SwiftyJSON

class WordHistoryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let headerViewHeight:CGFloat = 30
    
    var tableISEditing: Bool = false
    var cellIsSelected:[String:[Bool]] = [:]
    
    var AllData:[String:JSON] = [:]
    var AllData_keys:[String] = []
    var AllInterp_keys:[String] = []
    
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    var sortedKeys:[String] = []
    var sectionsExpanded:[Bool] = []
    
    private var DICT_URL: URL = Bundle.main.url(forResource: "DICT.json", withExtension: nil)!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var wordsTableView: UITableView!
    
    @IBOutlet weak var multiSelectionBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    @IBOutlet weak var reviewSelectionBtn: UIButton!{
        didSet {
            reviewSelectionBtn.layer.cornerRadius = 9.0
            reviewSelectionBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var filterBtn: UIButton!{
        didSet {
            filterBtn.layer.cornerRadius = 9.0
            filterBtn.layer.masksToBounds = true
        }
    }
    
    func load_DICT(){
        do {
           let data = try Data(contentsOf: DICT_URL, options: [])//.mappedIfSafe
           AllData = try JSON(data: data)["data"].dictionary!
            let key_arr = try JSON(data: data)["keys"].arrayValue
            for key in key_arr{
                let key_str = key.stringValue
                AllData_keys.append(key_str)
                AllInterp_keys.append(AllData[key_str]!.stringValue)
            }
           print("Load \(DICT_URL) successful!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func reviewSelectedWords(_ sender: UIButton) {
        multiSelectionBtn.isEnabled = true
        tableISEditing = false
        wordsTableView.setEditing(false, animated: true)
        for key in sortedKeys{
            for idx in 0..<groupedVocabs[key]!.count{
                if cellIsSelected[key]![idx]{
                    print(groupedVocabs[key]![idx].VocabHead)
                }
            }
        }
    }
    
    @IBAction func multiSelectionTapped(_ sender: UIButton) {
        tableISEditing.toggle()
        
        wordsTableView.setEditing(tableISEditing, animated: true)
        
        multiSelectionBtn.setTitleColor(tableISEditing ? .lightGray : .systemBlue, for: .normal)
    }
    
    func disableMultiSelectionBtn(){
        tableISEditing = false
        
        wordsTableView.setEditing(tableISEditing, animated: true)
        
        multiSelectionBtn.isEnabled = false
        multiSelectionBtn.setTitleColor(.lightGray, for: .disabled)
    }
    
    func enableMultiSelectionBtn(){
        tableISEditing = false
        
        wordsTableView.setEditing(tableISEditing, animated: true)
        
        multiSelectionBtn.isEnabled = true
        multiSelectionBtn.setTitleColor(tableISEditing ? .lightGray : .systemBlue, for: .normal)
    }
    
    func initCellIsSelected(){
        cellIsSelected = [:]
        for key in sortedKeys{
            cellIsSelected[key] = []
            for _ in groupedVocabs[key]!{
                cellIsSelected[key]!.append(false)
            }
        }
    }
    func getGroupVocabs(){
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                groupedVocabs = groupVocabRecByDate(dateType: .learn)
                enableMultiSelectionBtn()
            case 1:
                groupedVocabs = groupVocabRecByDate(dateType: .collect)
                enableMultiSelectionBtn()
            case 2:
                groupedVocabs = groupVocabRecByDate(dateType: .master)
                disableMultiSelectionBtn()
            default:
                break
        }
        sortedKeys = Array(groupedVocabs.keys).sorted(by: >)
        sectionsExpanded = []
        for idx in 0..<sortedKeys.count{
            if idx == 0 {
                sectionsExpanded.append(true)
            }else{
                sectionsExpanded.append(false)
            }
        }
        initCellIsSelected()
        wordsTableView.reloadData()
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
            case 2:
                wordsTableView.allowsSelection = false
            default:
                wordsTableView.allowsSelection = true
        }
        
        getGroupVocabs()
    }
    
    func getSegmentedCtrlUnselectedTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "WordHistory.segTextColor") as! String
        return viewBackgroundColor
    }
    
    func getMeaningOfVocab(vocab: VocabularyRecord) -> String? {
        let word = vocab.VocabHead
        for ik in 0..<AllData_keys.count{
            let key = AllData_keys[ik]
            if key.lowercased() == word.lowercased(){
                return AllInterp_keys[ik].replacingOccurrences(of: "\\n", with: "\n")
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load_DICT()
        
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        wordsTableView.theme_backgroundColor = "Global.viewBackgroundColor"
        wordsTableView.allowsMultipleSelection = false
        wordsTableView.allowsSelectionDuringEditing = true
        wordsTableView.allowsMultipleSelectionDuringEditing = true

        getGroupVocabs()
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "WordHistory.segmentedCtrlSelectedTintColor"
//        startTimer()
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func startTimer()
    {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                self.wordsTableView.reloadData()
            }
        }
    }
}

extension WordHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        groupedVocabs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupedVocabs = groupedVocabs[sortedKeys[section]]{
            if sectionsExpanded[section]{
                return groupedVocabs.count
            }else
            {
                return 0
            }
        } else{
            return 0
        }
    }
    
    func get_hour_difference_between_date_to_vocab_review_due(vocab: VocabularyRecord) -> Int?{
        if let dueDate = vocab.ReviewDUEDate{
            let date = Date()
            let hourDiff = Calendar.current.dateComponents([.hour], from: date, to: dueDate).hour ?? -1
            return hourDiff
        }
        return nil
    }
    
    func get_timer_text_of(vocab: VocabularyRecord) -> String?{
        if let dueDate = vocab.ReviewDUEDate{
            let date = Date()
            let dc = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: dueDate)
            
            let dayDiff = dc.day ?? 0
            let hourDiff = dc.hour ?? 0
            let minuteDiff = dc.minute ?? 0
            let secondDiff = dc.second ?? 0
            var timer_text = ""
            var negative: String = "距第\(vocab.NumOfReview + 1)轮复习: "
            if date > dueDate{
                negative = "第\(vocab.NumOfReview + 1)轮逾期: "
            }
            if (dayDiff != 0){
                timer_text = timer_text + "\(abs(dayDiff))天"
            }
            if ((hourDiff != 0) || (dayDiff != 0)) {
                timer_text = timer_text + String(format: "%02d", abs(hourDiff)) + "时"
            }
            if ((minuteDiff != 0) || (hourDiff != 0)) {
                timer_text = timer_text + String(format: "%02d", abs(minuteDiff)) + "分"
            }
            if dayDiff == 0{
                timer_text = timer_text + String(format: "%02d", abs(secondDiff)) + "秒"
            }
            if timer_text != ""{
                return "\(negative)\(timer_text)"
            }else{
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "vocabHistoryCell", for: indexPath) as! WordHistoryTableViewCell
        cell.backgroundColor = .clear
        let vocab: VocabularyRecord = groupedVocabs[sortedKeys[section]]![row]
        cell.wordHeadLabel.text = vocab.VocabHead
        
        if let meaning = getMeaningOfVocab(vocab: vocab){
            cell.wordTransLabel.text = meaning
        }
        cell.progressView.transform = .init(scaleX: 1, y: 2)
        
        if segmentedControl.selectedSegmentIndex == 2{
            cell.statLabel.text = "已掌握"
            
            cell.progressView.progress = 1.0
            cell.progressView.theme_progressTintColor = "WordHistory.HighProgressBarColor"
            cell.timerLabel.alpha = 0
        }else{
            let numOfSeqMem:Int = getNumOfSeqMem(vocab: vocab)
            
            cell.statLabel.text = "连续记住 \(numOfSeqMem) / \(numberOfContDaysForMasteredAWord) 次"
            
            let progress:Float = Float(numOfSeqMem)/Float(numberOfContDaysForMasteredAWord)
            
            cell.progressView.progress = progress
            if progress > 0.7{
                cell.progressView.theme_progressTintColor = "WordHistory.HighProgressBarColor"
            } else if progress > 0.4{
                cell.progressView.theme_progressTintColor = "WordHistory.MiddleHighProgressBarColor"
            } else if progress > 0.2{
                cell.progressView.theme_progressTintColor = "WordHistory.MiddleLowProgressBarColor"
            }else{
                cell.progressView.theme_progressTintColor = "WordHistory.LowProgressBarColor"
            }
            
            cell.timerLabel.alpha = 1
            if let timerText = get_timer_text_of(vocab: vocab){
                cell.timerLabel.text = timerText
                
                if let dueDate = vocab.ReviewDUEDate{
                    let date = Date()
                    if date > dueDate{
                        cell.timerLabel.theme_textColor = "WordHistory.overdueTextColor"
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
      
      let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: headerViewHeight))
        headerView.theme_backgroundColor = "WordHistory.headerViewBgColor"
        
        let groupedVocabsCount = groupedVocabs[sortedKeys[section]]?.count ?? 0
        
        let header_label = UILabel()
        
        header_label.text = "\(sortedKeys[section].components(separatedBy: "-")[0]) (\(groupedVocabsCount)词)"
        header_label.font = UIFont.boldSystemFont(ofSize: 16)
        header_label.frame = CGRect(x: 20, y: -5, width: 200, height: 40)
        header_label.textAlignment = .left
        header_label.theme_textColor = "WordHistory.headerViewTextColor"
        headerView.addSubview(header_label)
        
        let tapGSR = CustomTapGestureRecognizer(target: self, action:#selector(handleHeaderTap(_:)))
        tapGSR.section = section
        tapGSR.delegate = self
        headerView.addGestureRecognizer(tapGSR)
      return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1.0
    }
    
    @objc func handleHeaderTap(_ sender: CustomTapGestureRecognizer) {
        let section:Int = sender.section
        var indexPaths:[IndexPath] = []
        
        for row in groupedVocabs[sortedKeys[section]]!.indices{
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = !sectionsExpanded[section]
        sectionsExpanded[section] = isExpanded
        if isExpanded{
            wordsTableView.insertRows(at: indexPaths, with: .fade)
            
            for row in cellIsSelected[sortedKeys[section]]!.indices{
                
                let indexPath = IndexPath(row: row, section: section)
                if cellIsSelected[sortedKeys[section]]![row]{
                    wordsTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
            
        }else{
            wordsTableView.deleteRows(at: indexPaths, with: .fade)
        }
    
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        tableISEditing = true
        tableView.setEditing(tableISEditing, animated: true)
    }
    
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if cellIsSelected[sortedKeys[section]]![row]{
            return
        }
        cellIsSelected[sortedKeys[section]]![row].toggle()
        
        print("\(#function)")
        var numberOfSelected:Int = 0
        for key in sortedKeys{
            numberOfSelected += cellIsSelected[key]!.filter({ $0 == true }).count
        }
        print(numberOfSelected)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if !cellIsSelected[sortedKeys[section]]![row]{
            return
        }
        cellIsSelected[sortedKeys[section]]![row].toggle()
    }
}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var section: Int = 0
}
