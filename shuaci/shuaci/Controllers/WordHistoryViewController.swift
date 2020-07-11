//
//  WordHistoryViewController.swift
//  shuaci
//
//  Created by Honglei on 7/11/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class WordHistoryViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var wordsTableView: UITableView!
    var groupedVocabs:[String : [VocabularyRecord]] = [:]
    var sortedKeys:[String] = []
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
        sortedKeys = Array(groupedVocabs.keys).sorted(by: <)
        wordsTableView.reloadData()
    }
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        getGroupVocabs()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupVocabs()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
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
        let vocab: VocabularyRecord = groupedVocabs[sortedKeys[section]]![row]
        cell.wordHeadLabel.text = vocab.VocabRecId
        let progress: Float = getMasteredProgress(vocab: vocab)
        cell.progressView.progress = progress
        cell.progressView.progressTintColor = progressBarColor(progress: progress)
        cell.masterPercentLabel.text = "\(Int(round(100.0*Double(progress))))"
        return cell
    }
    
    
}
