//
//  SettingViewController.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import MessageUI

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    let settingItems:[SettingItem] = [
        SettingItem(icon: UIImage(named: "auto_pronunciation") ?? UIImage(), name: "自动发音", value: "开"),
        SettingItem(icon: UIImage(named: "english_american_pronunce") ?? UIImage(), name: "发音类型", value: "美"),
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
            cell.toggleSwitch.addTarget(self, action: #selector(autoPronunceSwitched), for: UIControl.Event.valueChanged)
            let autoPronunce = getPreference(key: "us_pronunciation") as! Bool
            if autoPronunce{
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
        else if row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingToggleCell", for: indexPath) as! SettingToggleTableViewCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.toggleSwitch.addTarget(self, action: #selector(pronunceStyleSwitched), for: UIControl.Event.valueChanged)
            cell.iconView?.image = settingItem.icon
            cell.nameLabel?.text = settingItem.name
            cell.leftValueLabel?.text = "美"
            cell.rightValueLabel?.text = "英"
            let usPronunce = getPreference(key: "us_pronunciation") as! Bool
            if usPronunce{
                cell.toggleSwitch.isOn = false
                cell.leftValueLabel.textColor = self.redColor
                cell.rightValueLabel.textColor = .darkGray
            }
            else{
                cell.toggleSwitch.isOn = true
                cell.leftValueLabel.textColor = .darkGray
                cell.rightValueLabel.textColor = self.redColor
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
        case 0:
            let cell = tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
            cell.toggleSwitch.isOn = !cell.toggleSwitch.isOn
            if cell.toggleSwitch.isOn == true{
                cell.leftValueLabel.textColor = .darkGray
                cell.rightValueLabel.textColor = self.redColor
            }
            else{
                cell.leftValueLabel.textColor = self.redColor
                cell.rightValueLabel.textColor = .darkGray
            }
        case 2:
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
            booksVC.modalPresentationStyle = .fullScreen
            booksVC.mainPanelViewController = nil
            DispatchQueue.main.async {
                self.present(booksVC, animated: true, completion: nil)
            }
        case 8:
            showFeedBackMailComposer()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    @IBAction func swipeDetected(_ sender: UISwipeGestureRecognizer) {
//        switch sender.direction {
//        case .right:
//            dismiss(animated: true, completion: nil)
//        default:
//            print("swiped")
//        }
//    }
    
    @objc func autoPronunceSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            setPreference(key: "auto_pronunciation", value: true)
        }else{
            setPreference(key: "auto_pronunciation", value: false)
        }
        let indexPath = IndexPath(row: 0, section: 0)
        let cell =  tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
        
        if uiSwitch.isOn{
            cell.leftValueLabel.textColor = .darkGray
            cell.rightValueLabel.textColor = self.redColor
        }
        else{
            cell.leftValueLabel.textColor = self.redColor
            cell.rightValueLabel.textColor = .darkGray
        }
        
    }
    
    @objc func pronunceStyleSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            setPreference(key: "us_pronunciation", value: false)
        }else{
            setPreference(key: "us_pronunciation", value: true)
        }
        let indexPath = IndexPath(row: 1, section: 0)
        let cell =  tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
        
        if uiSwitch.isOn{
            cell.leftValueLabel.textColor = .darkGray
            cell.rightValueLabel.textColor = self.redColor
        }
        else{
            cell.leftValueLabel.textColor = self.redColor
            cell.rightValueLabel.textColor = .darkGray
        }
    }
    
    func showFeedBackMailComposer(){
        guard MFMailComposeViewController.canSendMail() else{
            let ac = UIAlertController(title: "无法发送邮件", message: "无法发送邮件，请检查网络或设置", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return 
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["shuaci@outlook.com"])
        composer.setSubject("「刷词」意见反馈")
        composer.setMessageBody("", isHTML: false)
        present(composer, animated: true)
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

}

extension SettingViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
        }
        var feedback_sent = false
        switch result {
        case .cancelled:
            print("用户取消")
        case .failed:
            print("发送失败")
        case .saved:
            print("草稿已保存")
        case .sent:
            print("发送成功")
            feedback_sent = true
        default:
            print("")
        }
        controller.dismiss(animated: true, completion: {
            if feedback_sent == true{
                let ac = UIAlertController(title: "反馈已发送", message: "感谢您的反馈！我们会认真阅读您的意见,并在1-3天内给您回复", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
}
