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
import AVFoundation

class WordHistoryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var mp3Player: AVAudioPlayer?
    var Word_indexs_In_Oalecd8:[String:[Int]] = [:]
    
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let darkGreen:UIColor = UIColor(red: 2, green: 108, blue: 69, alpha: 1)
    let headerViewHeight:CGFloat = 30
    
    var tableISEditing: Bool = false{
        didSet{
            if tableISEditing{
                if segmentedControl.selectedSegmentIndex == 2{
                    wordSelectionBtn.setTitle("移出已掌握", for: .normal)
                }
                else{
                    wordSelectionBtn.setTitle("复习选中", for: .normal)
                }
                wordSelectionBtn.isEnabled = false
                wordSelectionBtn.backgroundColor = .lightGray
            }else{
                wordSelectionBtn.setTitle("选择词汇", for: .normal)
                wordSelectionBtn.isEnabled = true
                wordSelectionBtn.backgroundColor = redColor
            }
        }
    }
    
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
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    @IBOutlet var wordSelectionBtn: UIButton!{
        didSet {
            wordSelectionBtn.layer.cornerRadius = 9.0
            wordSelectionBtn.layer.masksToBounds = true
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
            let oalecd8_arr = try JSON(data: data)["oalecd8"].arrayValue
            for kid in 0..<key_arr.count{
                let key = key_arr[kid].stringValue
                AllData_keys.append(key)
                
                AllInterp_keys.append(AllData[key]!.stringValue)
                
                Word_indexs_In_Oalecd8[key] = [kid, oalecd8_arr[kid].intValue]
            }
           print("Load \(DICT_URL) successful!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func operateOnSelectedWords(_ sender: UIButton) {
        
        if tableISEditing{
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
        else{
            tableISEditing = true
            wordsTableView.setEditing(tableISEditing, animated: true)
        }
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
            case 1:
                groupedVocabs = groupVocabRecByDate(dateType: .collect)
            case 2:
                groupedVocabs = groupVocabRecByDate(dateType: .master)
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
        tableISEditing = false
        wordsTableView.setEditing(false, animated: true)
        
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
        wordsTableView.allowsSelection = true
        wordsTableView.allowsMultipleSelection = false
        wordsTableView.allowsSelectionDuringEditing = true
        wordsTableView.allowsMultipleSelectionDuringEditing = true

        getGroupVocabs()
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "WordHistory.segmentedCtrlSelectedTintColor"
    }
    
    
    @IBAction func showFilterVC(_ sender: UIButton) {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let filterVC = mainStoryBoard.instantiateViewController(withIdentifier: "filterVocabHistoryVC") as! FilterVocabHistoryVC
        filterVC.modalPresentationStyle = .overCurrentContext
        filterVC.wordHistoryVC = self
        DispatchQueue.main.async {
            self.present(filterVC, animated: true, completion: nil)
        }
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
        
        if tableISEditing{
            var numberOfSelected:Int = 0
            for key in sortedKeys{
                numberOfSelected += cellIsSelected[key]!.filter({ $0 == true }).count
            }
            
            if numberOfSelected == 0{
                wordSelectionBtn.isEnabled = false
                wordSelectionBtn.backgroundColor = .lightGray
            }
            else{
                wordSelectionBtn.isEnabled = true
                wordSelectionBtn.backgroundColor = .systemBlue
            }
        }else{
            let selected_word:String = groupedVocabs[sortedKeys[section]]![row].VocabHead
            
            let indexItem:[Int] = Word_indexs_In_Oalecd8[selected_word]!
            let wordIndex: Int = indexItem[0]
            let hasValueInOalecd8: Int = indexItem[1]
            if hasValueInOalecd8 == 1{
                if Reachability.isConnectedToNetwork(){
                    print("pronounce \(selected_word)")
                    if let mp3_url = getWordPronounceURL(word: selected_word){
                        playMp3(url: mp3_url)
                    }
                }
                
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let WordDetailVC = mainStoryBoard.instantiateViewController(withIdentifier: "WordDetailVC") as! WordDetailViewController
                WordDetailVC.wordIndex = wordIndex
                WordDetailVC.modalPresentationStyle = .overCurrentContext
                DispatchQueue.main.async {
                    self.present(WordDetailVC, animated: true, completion: nil)
                }
            }else{
                view.makeToast("无词典解释☹️", duration: 1.0, position: .center)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if !cellIsSelected[sortedKeys[section]]![row]{
            return
        }
        cellIsSelected[sortedKeys[section]]![row].toggle()
        
        if tableISEditing{
            var numberOfSelected:Int = 0
            for key in sortedKeys{
                numberOfSelected += cellIsSelected[key]!.filter({ $0 == true }).count
            }
            if numberOfSelected == 0{
                wordSelectionBtn.isEnabled = false
                wordSelectionBtn.backgroundColor = .lightGray
            }
            else{
                wordSelectionBtn.isEnabled = true
                wordSelectionBtn.backgroundColor = .systemBlue
            }
        }
    }
    
    func playMp3(url: URL)
    {
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                var downloadTask: URLSessionDownloadTask
                downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (urlhere, response, error) -> Void in
                    if let urlhere = urlhere{
                        do {
                            self.mp3Player = try AVAudioPlayer(contentsOf: urlhere)
                            self.mp3Player?.play()
                        } catch {
                            print("couldn't load file :( \(urlhere)")
                        }
                    }
            })
                downloadTask.resume()
            }}
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var section: Int = 0
}
