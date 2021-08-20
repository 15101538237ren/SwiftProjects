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
    
    // MARK: - Constants
    let activityEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    let settingItems:[SettingItem] = [
        SettingItem(symbol_name : "auto_pronunciation", name: autoPronounceText, value: onText),
        SettingItem(symbol_name : "english_american_pronunce", name: pronounceTypeText, value: usText),
        SettingItem(symbol_name : "dark_mode", name: darkModeText, value: offText),
        SettingItem(symbol_name : "group", name: groupStudyText, value: onText),
        SettingItem(symbol_name : "membership", name: membershipText, value: ""),
        SettingItem(symbol_name : "scope", name: setLearningPlanText, value: defaultPlanText),
        SettingItem(symbol_name : "alarm", name: everyDayNotificationText, value: ""),
        SettingItem(symbol_name : "rate_app", name: rateAppText, value: "v1.0.0"),
        SettingItem(symbol_name : "share", name: shareAppText, value: ""),
        SettingItem(symbol_name : "wechat", name: wechatText, value: "")
    ]
    
    
    // MARK: - Outlet Variables
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    
    // MARK: - Variables
    var currentUser: LCUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var activityIndicator = UIActivityIndicatorView()
    var activityLabel = UILabel()
    
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if  (row < 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingToggleCell", for: indexPath) as! SettingToggleTableViewCell
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            let settingItem:SettingItem = settingItems[row]
            cell.iconView.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel.text = settingItem.name
            if row  == 1{
                cell.leftValueLabel.text = usText
                cell.rightValueLabel.text = ukText
            }else{
                cell.leftValueLabel.text = offText
                cell.rightValueLabel.text = onText
            }
            
            var value:Bool = false
            if row == 0 {
                cell.toggleSwitch.addTarget(self, action: #selector(autoPronunceSwitched), for: UIControl.Event.valueChanged)
                value = preference.auto_pronunciation
            }else if row == 1{
                cell.toggleSwitch.addTarget(self, action: #selector(pronunceStyleSwitched), for: UIControl.Event.valueChanged)
                value = preference.us_pronunciation
            }
            else if row == 2{
                cell.toggleSwitch.addTarget(self, action: #selector(darkModeSwitched), for: UIControl.Event.valueChanged)
                value = preference.dark_mode
            }else{
                cell.toggleSwitch.addTarget(self, action: #selector(studyOnlineSwitched), for: UIControl.Event.valueChanged)
                value = preference.online_people
            }
            
            if value{
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
        
        else if row == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
            
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            let settingItem:SettingItem = settingItems[row]
            cell.iconView.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel.text = settingItem.name
            cell.valueLabel.text = getSettingTextforTableView(number_of_words_per_group: preference.number_of_words_per_group)
            return cell
        }
            
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
            
            cell.backgroundColor = .clear
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            let settingItem:SettingItem = settingItems[row]
            cell.iconView.image = settingItem.icon
            cell.iconView.theme_tintColor = "Global.settingIconTintColor"
            cell.nameLabel.text = settingItem.name
            cell.valueLabel.text = row == 6 ? getStringOfReminderTime(reminderTime: preference.reminder_time) : settingItem.value
            return cell
        }
    }
    
    func getStringOfReminderTime(reminderTime: DateComponents?) -> String{
        if let datetime = reminderTime{
            return String(format: "%02d:%02d", datetime.hour!, datetime.minute!)
        }else{
            return ""
        }
        
    }
    
    func getSettingTextforTableView(number_of_words_per_group: Int) -> String {
        var order = randomOrderText
        switch preference.memory_order {
        case 1:
            order = randomOrderText
        case 2:
            order = alphabetOrderText
        case 3:
            order = reversedText
        default:
            order = randomOrderText
        }
        return "\(order)  \(number_of_words_per_group)\(unitText)"
    }
    
    func updateMemOptionDisplay(){
        let indexPath = IndexPath(row: 5, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func updateReminderTime(){
        let indexPath = IndexPath(row: 6, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        let timeStr = getStringOfReminderTime(reminderTime: preference.reminder_time)
        if timeStr != ""{
            self.view.makeToast("\(planSetText) \(timeStr)", duration: 1.0, position: .center)
        }
    }
    
    func loadWechatVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let wechatVC = mainStoryBoard.instantiateViewController(withIdentifier: "wechatFeedbackViewController") as! WechatFeedbackViewController
        wechatVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(wechatVC, animated: true, completion: {})
        }
    }
    
    func loadBooksVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let booksVC = mainStoryBoard.instantiateViewController(withIdentifier: "booksController") as! BooksViewController
        booksVC.modalPresentationStyle = .fullScreen
        booksVC.mainPanelViewController = mainPanelViewController
        booksVC.currentUser = currentUser
        booksVC.preference = preference
        DispatchQueue.main.async {
            self.present(booksVC, animated: true, completion: {
                booksVC.view.makeToast(noBookSelectedText, duration: 1.0, position: .center)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if (row < 4){
            let cell = tableView.cellForRow(at: indexPath) as! SettingToggleTableViewCell
            cell.toggleSwitch.isOn = !cell.toggleSwitch.isOn
            if cell.toggleSwitch.isOn == true{
                cell.leftValueLabel.theme_textColor = "TableView.switchOffTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOnTextColor"
            }
            else{
                cell.leftValueLabel.theme_textColor = "TableView.switchOnTextColor"
                cell.rightValueLabel.theme_textColor = "TableView.switchOffTextColor"
            }
            if row == 0{
                autoPronunceSwitched(uiSwitch: cell.toggleSwitch)
            }else if row == 1{
                pronunceStyleSwitched(uiSwitch: cell.toggleSwitch)
            }else if row == 2{
                darkModeSwitched(uiSwitch: cell.toggleSwitch)
            }else{
                studyOnlineSwitched(uiSwitch: cell.toggleSwitch)
            }
        }else if row == 4{
            initIndicator(view: self.view)
            
            checkIfVIPSubsciptionValid(successCompletion: { [self] in
                stopIndicator()
                loadMembershipVC(hasTrialed: false, reason: .success, reasonToShow: .NONE)
            }, failedCompletion: { [self] reason in
                stopIndicator()
                if reason == .notPurchasedNewUser{
                    loadMembershipVC(hasTrialed: false, reason: reason, reasonToShow: .NONE)
                }else{
                    loadMembershipVC(hasTrialed: true, reason: reason, reasonToShow: .NONE)
                }
            })
        }else if (row == 5){
            if let book = getCurrentBook(preference: preference) {
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let SetMemOptionVC = mainStoryBoard.instantiateViewController(withIdentifier: "SetMemOptionVC") as! SetMemOptionViewController
                SetMemOptionVC.currentUser = currentUser
                SetMemOptionVC.preference = preference
                SetMemOptionVC.modalPresentationStyle = .overCurrentContext
                SetMemOptionVC.bookIndex = -1
                SetMemOptionVC.book = book
                SetMemOptionVC.bookVC = nil
                SetMemOptionVC.mainPanelVC = nil
                SetMemOptionVC.settingVC = self
                
                DispatchQueue.main.async {
                    self.present(SetMemOptionVC, animated: true, completion: nil)
                }
            }else{
                loadBooksVC()
            }
        }else if (row == 6 ){
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let reminderTimePickerVC = mainStoryBoard.instantiateViewController(withIdentifier: "reminderTimePickerVC") as! ReminderTimePickerViewController
            reminderTimePickerVC.settingVC = self
            reminderTimePickerVC.mainPanelViewController = mainPanelViewController
            reminderTimePickerVC.preference = preference
            reminderTimePickerVC.currentUser = currentUser
            reminderTimePickerVC.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.async {
                self.present(reminderTimePickerVC, animated: true, completion: nil)
            }
        }else if (row == 7){
            askUserExperienceBeforeReview()
        }else if (row == 8){
            showShareVC()
        }else if (row == 9){
            loadWechatVC()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func showShareVC(){
        if let url = productURL, !url.absoluteString.isEmpty {
            let textToShare = shareContentText
            let activityVC = UIActivityViewController(activityItems: [textToShare, url], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList, .addToiCloudDrive, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll, .print, .postToFlickr, .postToLinkedIn, .postToTencentWeibo, .postToVimeo, .postToXing]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func askUserExperienceBeforeReview(){
        let alertController = UIAlertController(title: feedBackTitleText, message: askExperienceText, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: greatResponseText, style: .default, handler: { action in
            self.requestWriteReview()
        })
        let cancelAction = UIAlertAction(title: awefulResponseText, style: .default, handler: { action in self.showFeedBackMailComposer()
        })
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestWriteReview(){
        if let url = productURL{
            // 1.
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

            // 2.
            components?.queryItems = [
              URLQueryItem(name: "action", value: "write-review")
            ]

            // 3.
            guard let writeReviewURL = components?.url else {
              return
            }

            // 4.
            UIApplication.shared.open(writeReviewURL)
        }
    }
    
    func update_preference(pref: Preference){
        preference = pref
        self.mainPanelViewController.update_preference()
    }
    
    @objc func autoPronunceSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            preference.auto_pronunciation = true
        }else{
            preference.auto_pronunciation = false
        }
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        mainPanelViewController.update_preference()
        
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
    
    @objc func studyOnlineSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            preference.online_people = true
        }else{
            preference.online_people = false
        }
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        mainPanelViewController.update_preference()
        
        let indexPath = IndexPath(row: 3, section: 0)
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
    
    @objc func darkModeSwitched(uiSwitch: UISwitch) {
        if uiSwitch.isOn{
            preference.dark_mode = true
        }else{
            preference.dark_mode = false
        }
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        mainPanelViewController.update_preference()
        mainPanelViewController.loadWallpaper(force: true)
        
        if let window = UIApplication.shared.windows.first {
            if preference.dark_mode {
                window.overrideUserInterfaceStyle = .dark
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                window.overrideUserInterfaceStyle = .light
                ThemeManager.setTheme(plistName: theme_category_to_name[preference.current_theme]!.rawValue, path: .mainBundle)
            }
        }
        
        let indexPath = IndexPath(row: 2, section: 0)
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
            preference.us_pronunciation = false
        }else{
            preference.us_pronunciation = true
        }
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        mainPanelViewController.update_preference()
        
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
            let ac = UIAlertController(title: canNotSendEmailText, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: okText, style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([OfficialEmail])
        composer.setSubject(emailTitleText)
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
                let ac = UIAlertController(title: promptText, message: thanksForFeedbackText, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: okText, style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
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
