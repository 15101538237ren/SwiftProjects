//
//  NumWordPerGroupViewController.swift
//  shuaci
//
//  Created by Honglei on 6/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import BottomPopup

class NumWordPerGroupViewController: BottomPopupViewController, UITableViewDataSource, UITableViewDelegate {
    
    override var popupHeight: CGFloat { return UIScreen.main.bounds.height }
    
    override var popupPresentDuration: Double { return 0.3 }
    
    override var popupDismissDuration: Double { return 0.3 }
    
    let number_of_words: [Int] = [10, 20, 30, 40, 50, 100, 150, 200, 300]
    var setting_tableView: UITableView!
    var checked_row:Int = 1
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        get_pref_setting()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 20.0
        self.tableView.layer.masksToBounds = true
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func get_pref_setting(){
        let npg_pref:Int = getPreference(key: "number_of_words_per_group") as! Int
        for i in 0..<number_of_words.count{
            if number_of_words[i] == npg_pref{
                checked_row = i
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return number_of_words.count
   }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfWordCell", for: indexPath) as! NumberOfWordTableViewCell
        let alpha:CGFloat = row == checked_row ? 1.0 : 0.0
        cell.checkedImageView.alpha = alpha
        cell.numberOfWordLabel.text = "\(number_of_words[row])个"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "提示", message: "是否更改为每组\(number_of_words[indexPath.row])个单词?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
            let indexPath_prev_selected = IndexPath(row: self.checked_row, section: 0)
            let cell_prev_selected = tableView.dequeueReusableCell(withIdentifier: "NumberOfWordCell", for: indexPath_prev_selected) as! NumberOfWordTableViewCell
            
            self.checked_row = indexPath.row
            setPreference(key: "number_of_words_per_group", value: self.number_of_words[self.checked_row])
            let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfWordCell", for: IndexPath(row: self.checked_row, section: 0)) as! NumberOfWordTableViewCell
            
            DispatchQueue.main.async {
                let indexPath_in_setting = IndexPath(item: 3, section: 0)
                let cell_in_setting = self.setting_tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath_in_setting) as! SettingTableViewCell
                cell_in_setting.valueLabel?.text = "\(self.number_of_words[indexPath.row])"
                self.setting_tableView.reloadRows(at: [indexPath_in_setting], with: .top)
                
                cell_prev_selected.checkedImageView.alpha = 0.0
                tableView.deselectRow(at: indexPath_prev_selected, animated: true)
                cell.checkedImageView.alpha = 1.0
                self.dismiss(animated: true, completion: nil)
            }
            clear_words()
            update_words()
            
        })
        let cancelAction = UIAlertAction(title: "否", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
