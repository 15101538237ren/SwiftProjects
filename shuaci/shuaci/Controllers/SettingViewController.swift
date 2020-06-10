//
//  SettingViewController.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let settingItems:[SettingItem] = [
        SettingItem(icon: UIImage(named: "auto_pronunciation") ?? UIImage(), name: "自动发音", value: "开"),
        SettingItem(icon: UIImage(named: "english_american_pronunce") ?? UIImage(), name: "发音类型", value: "美 音"),
        SettingItem(icon: UIImage(named: "choose_book") ?? UIImage(), name: "选择单词书", value: ""),
        SettingItem(icon: UIImage(named: "vocab_amount_each_group") ?? UIImage(), name: "每组单词数", value: "120"),
        SettingItem(icon: UIImage(named: "learning_reminder") ?? UIImage(), name: "学习提醒", value: "8:00"),
        SettingItem(icon: UIImage(named: "clean_cache") ?? UIImage(), name: "清除缓存", value: "3.25M"),
        SettingItem(icon: UIImage(named: "sync_record") ?? UIImage(), name: "同步学习记录", value: ""),
        SettingItem(icon: UIImage(named: "rate_app") ?? UIImage(), name: "评价应用", value: "v1.0.0"),
        SettingItem(icon: UIImage(named: "feedback") ?? UIImage(), name: "意见反馈", value: ""),
        SettingItem(icon: UIImage(named: "share_app") ?? UIImage(), name: "推荐给好友", value: ""),
        SettingItem(icon: UIImage(named: "q_and_a") ?? UIImage(), name: "常见问题", value: "")
    ]
    @IBOutlet var tableView: UITableView!
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        self.modalPresentationStyle = .overCurrentContext
        view.isOpaque = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if  row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingToggleCell", for: indexPath) as! SettingToggleTableViewCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.iconView?.image = settingItem.icon
            cell.nameLabel?.text = settingItem.name
            cell.leftValueLabel?.text = "关"
            cell.rightValueLabel?.text = "开"
            if settingItem.value == "开"{
                cell.toggleSwitch.isOn = true
                cell.leftValueLabel.textColor = .darkGray
                cell.rightValueLabel.textColor = self.redColor
            }
            else{
                cell.toggleSwitch.isOn = false
                cell.leftValueLabel.textColor = self.redColor
                cell.rightValueLabel.textColor = .darkGray
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.iconView?.image = settingItem.icon
            cell.nameLabel?.text = settingItem.name
            cell.valueLabel?.text = settingItem.value
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
            booksVC.modalPresentationStyle = .fullScreen
            booksVC.mainPanelViewController = nil
            DispatchQueue.main.async {
                self.present(booksVC, animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
           let alertController = UIAlertController(title: "注销", message: "确定注销?", preferredStyle: .alert)
           let okayAction = UIAlertAction(title: "确定", style: .default, handler: { action in
               LCUser.logOut()
               self.dismiss(animated: false, completion: nil)
           })
           let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           alertController.addAction(okayAction)
           alertController.addAction(cancelAction)
           self.present(alertController, animated: true, completion: nil)
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
