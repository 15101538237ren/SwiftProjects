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
import SwiftTheme

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var mainPanelViewController: MainPanelViewController!
    let settingItems:[SettingItem] = [
        SettingItem(symbol_name : "auto_pronunciation", name: "自动发音", value: "开"),
        SettingItem(symbol_name : "english_american_pronunce", name: "发音类型", value: "美"),
        SettingItem(symbol_name : "book", name: "选择单词书", value: ""),
        SettingItem(symbol_name : "scope", name: "设置学习计划", value: "乱序,20个/组"),
        SettingItem(symbol_name : "alarm", name: "每日提醒", value: ""),
        SettingItem(symbol_name : "clean", name: "清除缓存", value: "3.25M"),
        SettingItem(symbol_name : "arrow.2.circlepath", name: "同步学习记录至云端", value: ""),
        SettingItem(symbol_name : "rate_app", name: "评价应用", value: "v1.0.0"),
        SettingItem(symbol_name : "bubble.left.and.bubble.right", name: "意见反馈", value: ""),
        SettingItem(symbol_name : "share", name: "推荐给好友", value: ""),
        SettingItem(symbol_name : "q_and_a", name: "常见问题", value: "")
    ]
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        tableView.theme_backgroundColor = "Global.viewBackgroundColor"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        self.modalPresentationStyle = .overCurrentContext
        
        view.isOpaque = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableTheme),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
        // Do any additional setup after loading the view.
    }
    
    @objc func updateTableTheme(){
        self.tableView.reloadData()
    }
    
    
    func initActivityIndicator(text: String) {
        activityLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        activityEffectView.removeFromSuperview()
        let height:CGFloat = 72.0
        activityLabel = UILabel(frame: CGRect(x: 48, y: 0, width: 180, height: height))
        activityLabel.text = text
        activityLabel.numberOfLines = 0
        activityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        activityLabel.textColor = .darkGray
        activityLabel.alpha = 1.0
        activityEffectView.frame = CGRect(x: view.frame.midX - activityLabel.frame.width/2, y: view.frame.midY - activityLabel.frame.height/2 , width: 200, height: height)
        activityEffectView.layer.cornerRadius = 15
        activityEffectView.layer.masksToBounds = true
        activityEffectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        activityEffectView.alpha = 1.0
        activityIndicator = .init(style: .medium)
        let indicatorWidth:CGFloat = 46
        activityIndicator.frame = CGRect(x: 0, y: indicatorWidth/4, width: indicatorWidth, height: indicatorWidth)
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()

        activityEffectView.contentView.addSubview(activityIndicator)
        activityEffectView.contentView.addSubview(activityLabel)
        view.addSubview(activityEffectView)
    }
    
    func stopIndicator(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.activityEffectView.alpha = 0
        self.activityLabel.alpha = 0
    }
    
    func disableElementsWhenSynchronizing(){
        self.backBtn.isUserInteractionEnabled = false
        self.tableView.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
    }
    
    func enableElementsAfterSynchronization(){
        self.backBtn.isUserInteractionEnabled = true
        self.tableView.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
    }
    
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func getSettingTextforTableView() -> String {
        var order = "乱序"
        if let memOrder = getPreference(key: "memOrder") as? Int{
            switch memOrder {
            case 1:
                order = "乱序"
            case 2:
                order = "顺序"
            case 3:
                order = "倒序"
            default:
                order = "乱序"
            }
        }
        if let number_of_words_per_group = getPreference(key: "number_of_words_per_group") as? Int{
            return "\(order)  \(number_of_words_per_group)个/组"
        }
        else{
            return "\(order)"
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if  row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingToggleCell", for: indexPath) as! SettingToggleTableViewCell
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            let settingItem:SettingItem = settingItems[row]
            cell.iconView?.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel?.text = settingItem.name
            cell.leftValueLabel?.text = "关"
            cell.rightValueLabel?.text = "开"
            cell.toggleSwitch.addTarget(self, action: #selector(autoPronunceSwitched), for: UIControl.Event.valueChanged)
            let autoPronunce = getPreference(key: "auto_pronunciation") as! Bool
            if autoPronunce{
                cell.toggleSwitch.isOn = true
                cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
            }
            else{
                cell.toggleSwitch.isOn = false
                cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
            }
            return cell
        }
        else if row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingToggleCell", for: indexPath) as! SettingToggleTableViewCell
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.toggleSwitch.addTarget(self, action: #selector(pronunceStyleSwitched), for: UIControl.Event.valueChanged)
            cell.iconView?.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel?.text = settingItem.name
            cell.leftValueLabel?.text = "美"
            cell.rightValueLabel?.text = "英"
            let usPronunce = getPreference(key: "us_pronunciation") as! Bool
            if usPronunce{
                cell.toggleSwitch.isOn = false
                cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
            }
            else{
                cell.toggleSwitch.isOn = true
                cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
            }
            return cell
        }
        else if row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
            
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            let settingItem:SettingItem = settingItems[row]
            cell.iconView?.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel?.text = settingItem.name
            cell.valueLabel?.text = getSettingTextforTableView()
            return cell
        }
            
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
            
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.iconView?.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel?.text = settingItem.name
            cell.valueLabel?.text = row == 4 ? getPreference(key: "reminder_time") as? String ?? "" : settingItem.value
            return cell
        }
    }
    
    func updateReminderTime(){
        let indexPath = IndexPath(row: 4, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .top)
        }
        
        let remindStr = getPreference(key: "reminder_time") as? String ?? ""
        var alertStr:String = "已移除每日学习提醒"
        if remindStr != ""{
            alertStr = "已为您设置每日学习提醒 \(remindStr)"
        }
        
        let ac = UIAlertController(title: alertStr, message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let cell = tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
            cell.toggleSwitch.isOn = !cell.toggleSwitch.isOn
            autoPronunceSwitched(uiSwitch: cell.toggleSwitch)
            if cell.toggleSwitch.isOn == true{
                cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
            }
            else{
                cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
            }
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
            cell.toggleSwitch.isOn = !cell.toggleSwitch.isOn
            pronunceStyleSwitched(uiSwitch: cell.toggleSwitch)
            if cell.toggleSwitch.isOn == true{
                cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
            }
        else{
            cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
            cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
        }
        case 2:
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
            booksVC.modalPresentationStyle = .fullScreen
            booksVC.mainPanelViewController = nil
            fetchBooks()
            DispatchQueue.main.async {
                self.present(booksVC, animated: true, completion: nil)
            }
        case 3:
            if let book = getCurrentBook() {
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let SetMemOptionVC = mainStoryBoard.instantiateViewController(withIdentifier: "SetMemOptionVC") as! SetMemOptionViewController
                SetMemOptionVC.modalPresentationStyle = .overCurrentContext
                SetMemOptionVC.bookIndex = -1
                SetMemOptionVC.book = book
                SetMemOptionVC.bookVC = nil
                SetMemOptionVC.mainPanelVC = nil
                SetMemOptionVC.setting_tableView = self.tableView
                
                DispatchQueue.main.async {
                    self.present(SetMemOptionVC, animated: true, completion: nil)
                }
            }
        case 4:
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let reminderTimePickerVC = mainStoryBoard.instantiateViewController(withIdentifier: "reminderTimePickerVC") as! ReminderTimePickerViewController
            reminderTimePickerVC.settingVC = self
            reminderTimePickerVC.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.async {
                self.present(reminderTimePickerVC, animated: true, completion: nil)
            }
        case 6:
            disableElementsWhenSynchronizing()
            initActivityIndicator(text: "正在同步【设置】\n请勿退出!")
            savePreference(saveToLocal: false, saveToCloud: true, completionHandler: {_ in
                DispatchQueue.main.async {
                self.activityLabel.text = "正在同步【学习记录】\n请勿退出!"
                }})
            
            saveVocabRecords(saveToLocal: false, saveToCloud: true, random_new_word: false, delaySeconds: 1.0, completionHandler: {_ in })
            saveLearningRecords(saveToLocal: false, saveToCloud: true, delaySeconds: 1.5, completionHandler: {_ in })
            saveReviewRecords(saveToLocal: false, saveToCloud: true, delaySeconds: 2.0, completionHandler: {success in
                var successMessage: String = "记录上传成功!"
                if !success {
                    successMessage = "上传失败，请稍后再试。"
                }
                DispatchQueue.main.async {
                    self.stopIndicator()
                    self.enableElementsAfterSynchronization()
                    let ac = UIAlertController(title: "\(successMessage)", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            })
        case 8:
            showFeedBackMailComposer()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func autoPronunceSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            setPreference(key: "auto_pronunciation", value: true)
        }else{
            setPreference(key: "auto_pronunciation", value: false)
        }
        let indexPath = IndexPath(row: 0, section: 0)
        let cell =  tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
        
        if uiSwitch.isOn{
            cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
            cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
        }
        else{
            cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
            cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
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
            cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
            cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
        }
        else{
            cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
            cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
        }
    }
    
    func showFeedBackMailComposer(){
        guard MFMailComposeViewController.canSendMail() else{
            let ac = UIAlertController(title: "无法发送邮件，请检查网络或设置!", message: "", preferredStyle: .alert)
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
                let ac = UIAlertController(title: "提示", message: "感谢您的反馈！我们会认真阅读您的意见,并在1-3天内给您回复", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
}
