//
//  SettingVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/7/20.
//

import UIKit
import MessageUI
import Nuke
import LeanCloud
import PopMenu

class SettingVC: UIViewController , UITableViewDataSource, UITableViewDelegate {
    let settingItems:[[SettingItem]] = [
        [SettingItem(symbol_name : "user", name: "登录 / 注册"),
         SettingItem(symbol_name : "membership", name: "年会员「限时5折」!")],
        
        [SettingItem(symbol_name : "theme", name: "主题")],
        
        [SettingItem(symbol_name : "rate", name: "评价我们"),
         SettingItem(symbol_name : "share", name: "分享给朋友"),
         SettingItem(symbol_name : "feedback", name: "意见反馈")],
        
        [SettingItem(symbol_name : "clean", name: "清空壁纸缓存"),
        SettingItem(symbol_name : "privacy", name: "用户条款与隐私政策")]
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
    
    func setDisplayNameAndUpdate(name : String){
        self.displayName = name
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func askUserExperienceBeforeReview(){
        let alertController = UIAlertController(title: "评价反馈", message: "您在本应用使用体验如何?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "很赞!必须五星好评", style: .default, handler: { action in
                self.requestWriteReview()
            })
        let cancelAction = UIAlertAction(title: "用的不爽，反馈意见给开发团队", style: .default, handler: {
            action in
            self.showFeedBackMailComposer()
        })
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
        if section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCellWithImg", for: indexPath) as! SettingTableViewCellWithImg
            cell.imgView.image = settingItems[section][row].icon
            if !displayName.isEmpty {
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
        }
        else if !(section == 3 && row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath) as! SettingTableViewCell
            cell.imgView.image = settingItems[section][row].icon
            cell.titleLbl.text = settingItems[section][row].name
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
    
    func popThemeMenu(){
        let iconWidthHeight:CGFloat = 20
        let dayAction = PopMenuDefaultAction(title: "白天", image: UIImage(named: "sunlight"), color: UIColor.darkGray)
        let nightAction = PopMenuDefaultAction(title: "夜晚", image: UIImage(named: "moon"), color: UIColor.darkGray)
        let systemAction = PopMenuDefaultAction(title: "跟随系统", image: UIImage(named: "setting"), color: UIColor.darkGray)
        
        dayAction.iconWidthHeight = iconWidthHeight
        nightAction.iconWidthHeight = iconWidthHeight
        systemAction.iconWidthHeight = iconWidthHeight
        
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        
        let menuVC = PopMenuViewController(sourceView: cell, actions: [dayAction, nightAction, systemAction])
        menuVC.delegate = self
        menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
        
        menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(red: 128, green: 128, blue: 128, alpha: 1))
        self.present(menuVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
                case 0:
                    if let _ = LCApplication.default.currentUser {
                        showProfileVC()
                    } else {
                        // 显示注册或登录页面
                        showLoginOrRegisterVC()
                    }
                case 2:
                    showVIPBenefitsVC()
                default:
                    break
            }
            
        case 1:
            popThemeMenu()
        case 2:
            switch indexPath.row {
                case 0:
                    askUserExperienceBeforeReview()
                case 2:
                    showFeedBackMailComposer()
                default:
                    break
            }
        case 3:
            switch indexPath.row {
                case 0:
                    cleanImageCache()
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
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let userProfileVC = MainStoryBoard.instantiateViewController(withIdentifier: "userProfileVC") as! UserProfileVC
        userProfileVC.settingVC = self
        userProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(userProfileVC, animated: true, completion: nil)
        }
    }
    
    func showSetProfileVC() {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setUserProfileVC = MainStoryBoard.instantiateViewController(withIdentifier: "setUserProfileVC") as! SetUserProfileVC
        setUserProfileVC.settingVC = self
        setUserProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(setUserProfileVC, animated: true, completion: nil)
        }
    }
    
    func showVIPBenefitsVC() {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vipBenefitsVC = MainStoryBoard.instantiateViewController(withIdentifier: "vipBenefitsVC") as! VIPBenefitsVC
        vipBenefitsVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vipBenefitsVC, animated: true, completion: nil)
        }
    }
    
    func showLoginOrRegisterVC() {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginVC = MainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
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

// MARK: - Pop Menu Protocal Implementation
extension SettingVC: PopMenuViewControllerDelegate {

    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        
        if index == 0{
            setTheme(theme: .day)
        }else if index == 1{
            setTheme(theme: .night)
        }
        else{
            setTheme(theme: .system)
        }
    }
}
