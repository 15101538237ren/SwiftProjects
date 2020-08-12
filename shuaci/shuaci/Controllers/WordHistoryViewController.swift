//
//  WordHistoryViewController.swift
//  shuaci
//
//  Created by Honglei on 7/11/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

class WordHistoryViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var wordsTableView: UITableView!
    @IBOutlet weak var multiSelectionBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    var tableISEditing: Bool = false
    var cellIsSelected:[String:[Bool]] = [:]
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    
    @IBOutlet weak var reviewSelectionBtn: UIButton!{
        didSet {
            reviewSelectionBtn.layer.cornerRadius = 15.0
            reviewSelectionBtn.layer.masksToBounds = true
        }
    }
    
    
    @IBAction func reviewSelectedWords(_ sender: UIButton) {
        multiSelectionBtn.isEnabled = true
        tableISEditing = false
        wordsTableView.setEditing(false, animated: true)
        wordsTableView.allowsMultipleSelectionDuringEditing = false
        for key in sortedKeys{
            for idx in 0..<groupedVocabs[key]!.count{
                if cellIsSelected[key]![idx]{
                    print(groupedVocabs[key]![idx].VocabRecId)
                }
            }
        }
    }
    
    @IBAction func multiSelectionTapped(_ sender: UIButton) {
        tableISEditing.toggle()
        wordsTableView.allowsMultipleSelectionDuringEditing = tableISEditing
        wordsTableView.setEditing(tableISEditing, animated: true)
        multiSelectionBtn.setTitleColor(tableISEditing ? .lightGray : .systemBlue, for: .normal)
    }
    
    func disableMultiSelectionBtn(){
        multiSelectionBtn.isEnabled = false
        tableISEditing = false
        wordsTableView.setEditing(tableISEditing, animated: true)
        wordsTableView.allowsMultipleSelectionDuringEditing = tableISEditing
        multiSelectionBtn.setTitleColor(.lightGray, for: .disabled)
    }
    
    func enableMultiSelectionBtn(){
        tableISEditing = false
        wordsTableView.setEditing(tableISEditing, animated: true)
        wordsTableView.allowsMultipleSelectionDuringEditing = tableISEditing
        
        multiSelectionBtn.isEnabled = true
        multiSelectionBtn.setTitleColor(tableISEditing ? .lightGray : .systemBlue, for: .normal)
    }
    
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    var sortedKeys:[String] = []
    
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
        sortedKeys = Array(groupedVocabs.keys).sorted(by: <)
        initCellIsSelected()
        wordsTableView.reloadData()
    }
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        getGroupVocabs()
    }
    
    func enableReviewSelectedBtn(){
        reviewSelectionBtn.backgroundColor = redColor
        reviewSelectionBtn.isEnabled = true
        reviewSelectionBtn.setTitleColor(.white, for: .normal)
    }
    
    func disableReviewSelectedBtn(){
        reviewSelectionBtn.backgroundColor = .lightGray
        reviewSelectionBtn.isEnabled = false
        reviewSelectionBtn.setTitleColor(.white, for: .normal)
    }
    
    func getSegmentedCtrlUnselectedTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "WordHistory.segTextColor") as! String
        return viewBackgroundColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        wordsTableView.theme_backgroundColor = "Global.viewBackgroundColor"
        getGroupVocabs()
        disableReviewSelectedBtn()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        let color = UIColor(hex: getSegmentedCtrlUnselectedTextColor())
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "WordHistory.segCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WordHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        groupedVocabs.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section].components(separatedBy: "-")[0]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupedVocabs = groupedVocabs[sortedKeys[section]] {
            return groupedVocabs.count
        } else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "vocabHistoryCell", for: indexPath) as! WordHistoryTableViewCell
        cell.backgroundColor = .clear
        let vocab: VocabularyRecord = groupedVocabs[sortedKeys[section]]![row]
        cell.wordHeadLabel.text = vocab.VocabRecId
        let progress: Float = getMasteredProgress(vocab: vocab)
        cell.progressView.progress = progress
        cell.progressView.progressTintColor = progressBarColor(progress: progress)
        cell.masterPercentLabel.text = "\(Int(round(100.0*Double(progress))))"
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//      let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//        headerView.backgroundColor = .clear
//      return headerView
//    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        tableISEditing = true
        tableView.setEditing(tableISEditing, animated: true)
        if !reviewSelectionBtn.isEnabled{
            enableReviewSelectedBtn()
        }
    }
    
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        print("\(#function)")
        var numberOfSelected:Int = 0
        for key in sortedKeys{
            numberOfSelected += cellIsSelected[key]!.filter({ $0 == true }).count
        }
        print(numberOfSelected)
        if numberOfSelected == 0 && reviewSelectionBtn.isEnabled{
            disableReviewSelectedBtn()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if cellIsSelected[sortedKeys[section]]![row]{
            return
        }
        cellIsSelected[sortedKeys[section]]![row].toggle()
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
