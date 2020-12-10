//
//  SettingVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/7/20.
//

import UIKit
import SwiftTheme
import MessageUI
import Nuke
import LeanCloud

class SettingVC: UIViewController , UITableViewDataSource, UITableViewDelegate {
    let settingItems:[[SettingItem]] = [
        [SettingItem(symbol_name : "user", name: "登录 / 注册")],
        [SettingItem(symbol_name : "membership", name: "会员权益"),
         SettingItem(symbol_name : "restore", name: "恢复购买")],
        [SettingItem(symbol_name : "theme", name: "主题"),
         SettingItem(symbol_name : "clean", name: "清空壁纸缓存")],
        [SettingItem(symbol_name : "rate", name: "评价我们"),
         SettingItem(symbol_name : "share", name: "分享给朋友"),
         SettingItem(symbol_name : "feedback", name: "意见反馈")],
        [SettingItem(symbol_name : "privacy", name: "用户条款与隐私政策")]
    ]
    
    var displayName: String = ""
    
    @IBOutlet var tableView: UITableView!
    let separatorHeight:CGFloat = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "View.BackgroundColor"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        updateDisplayName()
    }
    
    func updateDisplayName(){
        if let user = LCApplication.default.currentUser {
            _ = user.fetch(keys: ["name"]) { result in
                switch result {
                case .success:
                    let name:String = user.get("name")?.stringValue ?? ""
                    if !name.isEmpty{
                        self.displayName = name
                        let indexPath = IndexPath(row: 0, section: 0)
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setDisplayNameAndUpdate(name : String){
        self.displayName = name
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        if !(section == 2 && row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath) as! SettingTableViewCell
            cell.imgView.image = settingItems[section][row].icon
            if section == 0 && !displayName.isEmpty {
                cell.titleLbl.text = displayName
            }else{
                cell.titleLbl.text = settingItems[section][row].name
            }
            if row != settingItems[section].count - 1{
                let bottomBorder = CALayer()

                bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
                bottomBorder.backgroundColor = UIColor(white: 0.92, alpha: 1.0).cgColor
                
                cell.contentView.layer.addSublayer(bottomBorder)
            }
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCellWithValue", for: indexPath) as! SettingTableViewCellWithValue
            cell.imgView.image = settingItems[section][row].icon
            cell.titleLbl.text = settingItems[section][row].name
            let currentDiskUsageInBytes: Int = Nuke.DataLoader.sharedUrlCache.currentDiskUsage
            let bytesOfMB:Float = 1024*1024
            cell.labelValue.text = String(format: "%.0fMB", Float(currentDiskUsageInBytes)/bytesOfMB)
            if row != settingItems[section].count - 1{
                let bottomBorder = CALayer()

                bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
                bottomBorder.backgroundColor = UIColor(white: 0.92, alpha: 1.0).cgColor
                
                cell.contentView.layer.addSublayer(bottomBorder)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let _ = LCApplication.default.currentUser {
                showProfileVC()
            } else {
                // 显示注册或登录页面
                showLoginOrRegisterVC()
            }
        case 2:
            switch indexPath.row {
                case 1:
                    cleanImageCache()
                default:
                    break
            }
        case 3:
            switch indexPath.row {
                case 2:
                    showFeedBackMailComposer()
                default:
                    break
            }
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: 1, section: 2)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (cell.responds(to: #selector(getter: UIView.tintColor))){
            if tableView == self.tableView {
                let cornerRadius: CGFloat = 12.0
                cell.backgroundColor = .clear
                let layer: CAShapeLayer = CAShapeLayer()
                let path: CGMutablePath = CGMutablePath()
                let bounds: CGRect = cell.bounds
                var addLine: Bool = false

                if indexPath.row == 0 && indexPath.row == ( tableView.numberOfRows(inSection: indexPath.section) - 1) {
                    path.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)

                } else if indexPath.row == 0 {
                    path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
                    path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
                    path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))

                } else if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
                    path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
                    path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
                    path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))

                } else {
                    path.addRect(bounds)
                    addLine = true
                }

                layer.path = path
                layer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor

                if addLine {
                    let lineLayer: CALayer = CALayer()
                    let lineHeight: CGFloat = 1.0 / UIScreen.main.scale
                    lineLayer.frame = CGRect(x: bounds.minX + 10.0, y: bounds.size.height - lineHeight, width: bounds.size.width, height: lineHeight)
                    lineLayer.backgroundColor = tableView.separatorColor?.cgColor
                    layer.addSublayer(lineLayer)
                }

                let testView: UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, at: 0)
                testView.backgroundColor = .clear
                cell.backgroundView = testView
            }
        }
    }
    
    func showProfileVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let userProfileVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "userProfileVC") as! UserProfileVC
        userProfileVC.settingVC = self
        userProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(userProfileVC, animated: true, completion: nil)
        }
    }
    
    func showSetProfileVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setUserProfileVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "setUserProfileVC") as! SetUserProfileVC
        setUserProfileVC.settingVC = self
        setUserProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(setUserProfileVC, animated: true, completion: nil)
        }
    }
    
    func showLoginOrRegisterVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.settingVC = self
        DispatchQueue.main.async {
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func showFeedBackMailComposer(){
        guard MFMailComposeViewController.canSendMail() else{
            self.view.makeToast("无法使用邮箱, 请检查您的网络或者邮箱设置!", duration: 2.0, position: .center)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["fullwallpaper@outlook.com"])
        composer.setSubject("「全面屏壁纸」反馈")
        composer.setMessageBody("", isHTML: false)
        present(composer, animated: true)
    }
    
    func cleanImageCache() {
        Nuke.ImageCache.shared.removeAll()
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        self.view.makeToast("缓存清除成功!", duration: 1.0, position: .center)
    }
    
}


extension SettingVC : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
        }
        var feedback_sent = false
        switch result {
        case .cancelled:
            print("User Canceled")
        case .failed:
            print("Send Failed")
        case .saved:
            print("Draft Saved")
        case .sent:
            print("Send Successful!")
            feedback_sent = true
        default:
            print("")
        }
        controller.dismiss(animated: true, completion: {
            if feedback_sent == true{
                self.view.makeToast("感谢您的反馈！我们会认真考虑您的建议，并在需要时给您回复。", duration: 2.0, position: .center)
            }
        })
    }
}
