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
import LeanCloud
import UIEmptyState

class WordHistoryViewController: UIViewController, UIGestureRecognizerDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    var currentUser = LCApplication.default.currentUser!
    
    var mp3Player: AVAudioPlayer?
    
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let darkGreen:UIColor = UIColor(red: 2, green: 108, blue: 69, alpha: 1)
    let headerViewHeight:CGFloat = 30
    
    var vocabDatePeriod: VocabDatePeriod = .Unlimited
    var memConstraint: MemConstraint = .Unlimited
    var numOfContinuousMemTimes:[Int] = []
    
    var tableISEditing: Bool = false{
        didSet{
            if tableISEditing{
                if segmentedControl.selectedSegmentIndex == 2{
                    wordSelectionBtn.setTitle(removeFromMasteredText, for: .normal)
                }
                else{
                    wordSelectionBtn.setTitle(reviewSelectedText, for: .normal)
                }
                wordSelectionBtn.isEnabled = false
                wordSelectionBtn.backgroundColor = .lightGray
            }else{
                wordSelectionBtn.setTitle(selectWordsText, for: .normal)
                wordSelectionBtn.isEnabled = true
                wordSelectionBtn.backgroundColor = redColor
            }
        }
    }
    
    var cellIsSelected:[String:[Bool]] = [:]
    
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    var sortedKeys:[String] = []
    var sectionsExpanded:[Bool] = []
    var allSelected:Bool = false{
        didSet{
            tableISEditing = allSelected
            wordsTableView.setEditing(tableISEditing, animated: true)
            for section in 0..<sortedKeys.count{
                let key:String = sortedKeys[section]
                if let groupVocab = groupedVocabs[key]{
                    for row in 0..<groupVocab.count{
                        cellIsSelected[key]![row] = allSelected
                        if sectionsExpanded[section]{
                            let indexPath = IndexPath(row: row, section: section)
                            wordsTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                    }
                }
            }
            if tableISEditing{
                if allSelected {
                    wordSelectionBtn.isEnabled = true
                    wordSelectionBtn.backgroundColor = .systemBlue
                    
                }
                else{
                    wordSelectionBtn.isEnabled = false
                    wordSelectionBtn.backgroundColor = .lightGray
                }
            }
            
            let str:String = allSelected ? selectedAllText : unselectedAllText
            view.makeToast(str, duration: 1.0, position: .center)
        }
    }
    
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
    
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBAction func selectAllCells(_ sender: UIButton) {
        allSelected.toggle()
    }
    
    func reviewSelected(){
        var vocab_rec_need_to_be_review: [VocabularyRecord] = []
        for key in sortedKeys{
            for idx in 0..<groupedVocabs[key]!.count{
                if cellIsSelected[key]![idx]{
                    vocab_rec_need_to_be_review.append(groupedVocabs[key]![idx])
                }
            }
        }
        if vocab_rec_need_to_be_review.count > 0{
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: {
                    self.mainPanelViewController.loadReviewController(vocab_rec_need_to_be_review: vocab_rec_need_to_be_review)
                })
             }
        }
        
    }
    
    func loadMembershipVC(hasTrialed: Bool, reason: FailedVerifyReason, reasonToShow: ShowMembershipReason){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let membershipVC = mainStoryBoard.instantiateViewController(withIdentifier: "membershipVC") as! MembershipVC
        membershipVC.modalPresentationStyle = .overCurrentContext
        membershipVC.currentUser = currentUser
        membershipVC.hasFreeTrialed = hasTrialed
        membershipVC.mainPanelViewController = mainPanelViewController
        membershipVC.FailedReason = reason
        membershipVC.ReasonForShow = reasonToShow
        DispatchQueue.main.async {
            self.present(membershipVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func operateOnSelectedWords(_ sender: UIButton) {
        
        if tableISEditing{
            tableISEditing = false
            wordsTableView.setEditing(false, animated: true)
            if segmentedControl.selectedSegmentIndex != 2{
                
                let today_default:String = getTodayLearnOrReviewDefaultKey(learn: false)
                
                if !isKeyPresentInUserDefaults(key: today_default){
                    reviewSelected()
                }
                else{
                    initIndicator(view: self.view)
                    checkIfVIPSubsciptionValid( successCompletion: { [self] in
                        stopIndicator()
                        reviewSelected()
                    }, failedCompletion: { [self] reason in
                        stopIndicator()
                        if reason == .notPurchasedNewUser{
                            loadMembershipVC(hasTrialed: false, reason: reason, reasonToShow: .OVER_LIMIT)
                        }else{
                            loadMembershipVC(hasTrialed: true, reason: reason, reasonToShow: .OVER_LIMIT)
                        }
                    })
                }
                
            }else{
                
                var vocab_rec_rmv_mastered: [VocabularyRecord] = []
                for key in sortedKeys{
                    for idx in 0..<groupedVocabs[key]!.count{
                        if cellIsSelected[key]![idx]{
                            vocab_rec_rmv_mastered.append(groupedVocabs[key]![idx])
                        }
                    }
                }
                
                for vi in 0..<vocab_rec_rmv_mastered.count{
                    vocab_rec_rmv_mastered[vi].Mastered = false
                }
                updateGlobalVocabRecords(vocabs_updated: vocab_rec_rmv_mastered)
                saveRecordsToDisk(userId: currentUser.objectId!.stringValue!, withRecords: false)
                getGroupVocabs()
                view.makeToast(removedSuccessfullyText, duration: 1.0, position: .center)
                saveVocabRecordsToCloud()
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
        tableISEditing = false
        wordsTableView.setEditing(false, animated: true)
        var dateType: DateType = .learn
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                dateType = .learn
            case 1:
                dateType = .collect
            case 2:
                dateType = .master
            default:
                break
        }
        
        groupedVocabs = groupVocabRecByDate(dateType: dateType)
        
        sortedKeys = Array(groupedVocabs.keys).sorted(by: >)
        if dateType != .master{
            var temp_groupedVocabs:[String : [VocabularyRecord]] = [:]
            
            for key in sortedKeys{
                for idx in 0..<groupedVocabs[key]!.count{
                    let vocab: VocabularyRecord = groupedVocabs[key]![idx]
                    if let learningDate = vocab.LearnDate{
                        if vocabDatePeriod != .Unlimited{
                            var hoursLimit: Int = 999999999
                            switch vocabDatePeriod {
                            case .OneDay:
                                hoursLimit = 24
                            case .ThreeDays:
                                hoursLimit = 72
                            case .OneWeek:
                                hoursLimit = 168
                            default:
                                hoursLimit = 999999999
                            }
                            
                            let hours = Date().hours(from: learningDate)
                            if hours > hoursLimit{
                                continue
                            }
                        }
                    }
                    
                    if let dueDate = vocab.ReviewDUEDate{
                        if memConstraint != .Unlimited {
                            switch memConstraint {
                            case .Overdue:
                                if Date() < dueDate{
                                    // Within Due, Not valid
                                    continue
                                }
                            case .Withindue:
                                if Date() > dueDate{
                                    // Overdue, Not valid
                                    continue
                                }
                            default: break
                            }
                        }
                    }
                    
                    if numOfContinuousMemTimes.count > 0{
                        let numOfSeqMem:Int = getNumOfSeqMem(vocab: vocab)
                        if !numOfContinuousMemTimes.contains(numOfSeqMem){
                            continue
                        }
                    }
                    
                    if let _ = temp_groupedVocabs[key] {
                        temp_groupedVocabs[key]!.append(vocab)
                    }else{
                        temp_groupedVocabs[key] = []
                        temp_groupedVocabs[key]!.append(vocab)
                    }
                }
            }
            
            groupedVocabs = temp_groupedVocabs
            
            sortedKeys = Array(groupedVocabs.keys).sorted(by: >)
        }
        
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
        self.reloadEmptyStateForTableView(self.wordsTableView)
    }
    
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 1 {
            initIndicator(view: self.view)
            checkIfVIPSubsciptionValid(successCompletion: { [self] in
                stopIndicator()
                getGroupVocabs()
            }, failedCompletion: { [self] reason in
                stopIndicator()
                groupedVocabs = [:]
                sortedKeys = []
                tableISEditing = false
                wordsTableView.setEditing(false, animated: true)
                initCellIsSelected()
                wordsTableView.reloadData()
                self.reloadEmptyStateForTableView(self.wordsTableView)
                
                
                if reason == .notPurchasedNewUser{
                    loadMembershipVC(hasTrialed: false, reason: reason, reasonToShow: .PRO_COLLECTION)
                }else{
                    loadMembershipVC(hasTrialed: true, reason: reason, reasonToShow: .PRO_COLLECTION)
                }
            })
        }else{
            getGroupVocabs()
        }
        
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
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        wordsTableView.theme_backgroundColor = "Global.viewBackgroundColor"
        wordsTableView.allowsSelection = true
        wordsTableView.allowsMultipleSelection = false
        wordsTableView.allowsSelectionDuringEditing = true
        wordsTableView.allowsMultipleSelectionDuringEditing = true
        emptyStateDataSource = self
        emptyStateDelegate = self
        
        load_DICT()
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
        filterVC.mainPanelViewController = self.mainPanelViewController
        filterVC.currentUser = currentUser
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
            var negative: String = "\(tillText)\(vocab.NumOfReview + 1)\(reviewTurnText): "
            if date > dueDate{
                negative = "\(overduePreText)\(vocab.NumOfReview + 1)\(overdueNumText): "
            }
            if (dayDiff != 0){
                timer_text = timer_text + "\(abs(dayDiff))\(dayShortText)"
            }
            if ((hourDiff != 0) || (dayDiff != 0)) {
                if timer_text == ""{
                    timer_text = timer_text + String(format: "%02d", abs(hourDiff)) + hoursText
                }
                else{
                    timer_text = timer_text + String(format: " %02d", abs(hourDiff)) + hoursText
                }
            }
            if ((minuteDiff != 0) || (hourDiff != 0)) {
                timer_text = timer_text + String(format: " %02d", abs(minuteDiff)) + minsText
            }
            if dayDiff == 0{
                timer_text = timer_text + String(format: " %02d", abs(secondDiff)) + secsText
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
            cell.statLabel.text = masteredText
            
            cell.progressView.progress = 1.0
            cell.progressView.theme_progressTintColor = "WordHistory.HighProgressBarColor"
            cell.timerLabel.alpha = 0
        }else{
            let numOfSeqMem:Int = getNumOfSeqMem(vocab: vocab)
            
            cell.statLabel.text = "\(rememberSeqText) \(numOfSeqMem) / \(numberOfContDaysForMasteredAWord) \(timesText)"
            
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
        
        header_label.text = "\(sortedKeys[section].components(separatedBy: "-")[0]) (\(groupedVocabsCount) \(wordsText))"
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
                    if preference.auto_pronunciation{
                        if let mp3_url = getWordPronounceURL(word: selected_word, us_pronounce: preference.us_pronunciation){
                            playMp3(url: mp3_url)
                        }
                    }
                }
                
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let WordDetailVC = mainStoryBoard.instantiateViewController(withIdentifier: "WordDetailVC") as! WordDetailViewController
                WordDetailVC.wordIndex = wordIndex
                WordDetailVC.modalPresentationStyle = .overCurrentContext
                WordDetailVC.mainPanelViewController = mainPanelViewController
                DispatchQueue.main.async {
                    self.present(WordDetailVC, animated: true, completion: nil)
                }
            }else{
                view.makeToast(noDictMeaningText, duration: 1.0, position: .center)
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
    
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = noWordText
            return NSAttributedString(string: title, attributes: attrs)
        }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
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

class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var section: Int = 0
}
