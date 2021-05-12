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
        [SettingItem(symbol_name : "user", name: loginRegText)],
        
        [SettingItem(symbol_name : "membership", name: proBenefitsText)],
        
        [SettingItem(symbol_name : "rate", name: rateAppText),
         SettingItem(symbol_name : "share", name: shareAppText),
         SettingItem(symbol_name : "feedback", name: feedBackText)],
        
        [SettingItem(symbol_name : "clean", name: cleanCacheText),
        SettingItem(symbol_name : "document", name: serviceTermText),
        SettingItem(symbol_name : "privacy", name: privacyText)]
    ]
    
    var displayName: String = ""
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let separatorHeight:CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.theme_textColor = "BarTitleColor"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        view.isOpaque = false
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        updateDisplayName()
    }
    
    func updateDisplayName(){
        if let user = LCApplication.default.currentUser {
            _ = user.fetch(keys: ["name"]) { result in
                switch result {
                case .success:
                    var changed = false
                    
                    let name:String = user.get("name")?.stringValue ?? ""
                    if !name.isEmpty{
                        self.displayName = name
                        changed = true
                    }
                    
                    if changed {
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
        let alertController = UIAlertController(title: feedBackTitleText, message: askExperienceText, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: greatResponseText, style: .default, handler: { action in
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "评价我们-很赞"]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                self.requestWriteReview()
            
            })
        let cancelAction = UIAlertAction(title: awefulResponseText, style: .default, handler: {
            action in
            
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "评价我们-不爽"]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
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
        if section == 0 && row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCellWithImg", for: indexPath) as! SettingTableViewCellWithImg
            
            cell.backgroundColor = .clear
            cell.imgView.image = settingItems[section][row].icon
            
            if isProValid {
                cell.proImgView.alpha = 1
            }else{
                cell.proImgView.alpha = 0
            }
            
            if !displayName.isEmpty {
                cell.titleLbl.text = displayName
            }else{
                cell.titleLbl.text = settingItems[section][row].name
            }
            if row != settingItems[section].count - 1{
                let bottomBorder = CALayer()

                bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
                bottomBorder.theme_backgroundColor = "TableCell.SeparatorColor"
                
                cell.contentView.layer.addSublayer(bottomBorder)
            }
            return cell
        }
        else if !(section == 3 && row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath) as! SettingTableViewCell
            cell.imgView.image = settingItems[section][row].icon
            cell.titleLbl.text = settingItems[section][row].name
            
            cell.backgroundColor = .clear
            if row != settingItems[section].count - 1{
                let bottomBorder = CALayer()

                bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
                bottomBorder.theme_backgroundColor = "TableCell.SeparatorColor"
                
                cell.contentView.layer.addSublayer(bottomBorder)
            }
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCellWithValue", for: indexPath) as! SettingTableViewCellWithValue
            cell.imgView.image = settingItems[section][row].icon
            cell.titleLbl.text = settingItems[section][row].name
            
            cell.backgroundColor = .clear
            let currentDiskUsageInBytes: Int = Nuke.DataLoader.sharedUrlCache.currentDiskUsage
            let bytesOfMB:Float = 1024*1024
            cell.labelValue.text = String(format: "%.0fMB", Float(currentDiskUsageInBytes)/bytesOfMB)
            if row != settingItems[section].count - 1{
                let bottomBorder = CALayer()

                bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
                bottomBorder.theme_backgroundColor = "TableCell.SeparatorColor"
                
                cell.contentView.layer.addSublayer(bottomBorder)
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let user = LCApplication.default.currentUser {
                
                let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "查看Profile"]
                UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                 
                initIndicator(view: view)
                let name:String = user.get("name")?.stringValue ?? ""
                let file = user.get("avatar") as? LCFile
                DispatchQueue.main.async { [self] in
                    stopIndicator()
                    
                    if (name.isEmpty && file != nil){
                        let imgUrl = file!.url!.stringValue!
                        showSetProfileVC(previousName: nil, imageUrl: imgUrl)
                    }else if (!name.isEmpty && file == nil){
                        showSetProfileVC(previousName: name, imageUrl: nil)
                    }else if (name.isEmpty && file == nil){
                        showSetProfileVC(previousName: nil, imageUrl: nil)
                    }
                    else{
                        showProfileVC()
                    }
                }
            } else {
                // 显示注册或登录页面
                
                let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "注册登录"]
                UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                showLoginOrRegisterVC()
            }
            
        case 1:
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "查看会员权益"]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
            showVIPBenefitsVC()
        case 2:
            switch indexPath.row {
                case 0:
                    askUserExperienceBeforeReview()
                case 1:
                    showShareVC()
                case 2:
                    let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "意见反馈"]
                    UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                    showFeedBackMailComposer()
                default:
                    break
            }
        case 3:
            switch indexPath.row {
                case 0:
                    let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "清空缓存"]
                    UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                    cleanImageCache()
                case 1:
                    let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "服务条款"]
                    UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                    let url = URL(string: "\(githubLink)/terms.html")!
                    if testMode{
                        loadURL(url: url)
                    }else{
                        loadPolicyVC(url: url)
                    }
                case 2:
                    let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "隐私政策"]
                    UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
                    let url = URL(string: "\(githubLink)/privacy.html")!
                    if testMode{
                        loadURL(url: url)
                    }else{
                        loadPolicyVC(url: url)
                    }
                default:
                    break
            }
        default:
            break
        }
    }
    
    func loadPolicyVC(url: URL){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let policyVC = mainStoryBoard.instantiateViewController(withIdentifier: "policyVC") as! PolicyVC
        
        policyVC.url = url
        
        DispatchQueue.main.async {
            self.present(policyVC, animated: true, completion: nil)
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
                layer.theme_fillColor = "TableCell.BackGroundColor"

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
    
    func showShareVC(){
        if let url = productURL, !url.absoluteString.isEmpty {
            let textToShare = shareContentText
            let activityVC = UIActivityViewController(activityItems: [textToShare, url], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList, .addToiCloudDrive, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll, .print, .postToFlickr, .postToLinkedIn, .postToTencentWeibo, .postToVimeo, .postToXing]
            self.present(activityVC, animated: true, completion: nil)
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
    
    func showSetProfileVC(previousName: String?, imageUrl: String? = nil) {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setUserProfileVC = MainStoryBoard.instantiateViewController(withIdentifier: "setUserProfileVC") as! SetUserProfileVC
        setUserProfileVC.settingVC = self
        if let imgUrl = imageUrl{
            setUserProfileVC.imageUrl = URL(string: imgUrl)!
        }
        
        if let name = previousName{
            setUserProfileVC.previousName = name
        }
        
        setUserProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(setUserProfileVC, animated: true, completion: nil)
        }
    }
    
    func showVIPBenefitsVC() {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vipBenefitsVC = MainStoryBoard.instantiateViewController(withIdentifier: "vipBenefitsVC") as! VIPBenefitsVC
        vipBenefitsVC.modalPresentationStyle = .overCurrentContext
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
            self.view.makeToast(canNotSendEmailText, duration: 2.0, position: .center)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["fullwallpaper@outlook.com"])
        composer.setSubject(emailTitleText)
        composer.setMessageBody("", isHTML: false)
        present(composer, animated: true)
    }
    
    func cleanImageCache() {
        Nuke.ImageCache.shared.removeAll()
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        let indexPath = IndexPath(row: 0, section: 3)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        self.view.makeToast(cacheClearedText, duration: 1.0, position: .center)
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
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "意见反馈-用户取消发送"]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
            print("User Canceled")
        case .failed:
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "意见反馈-发送失败"]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
            print("Send Failed")
        case .saved:
            print("Draft Saved")
        case .sent:
            var userId: String = ""
            if let user = LCApplication.default.currentUser{
                userId = user.objectId!.stringValue!
            }
            let info = [ "Um_Key_SourcePage": "设置页", "Um_Key_ButtonName" : "意见反馈-发送成功", "Um_Key_UserID" : userId]
            UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
            print("Send Successful!")
            feedback_sent = true
        default:
            print("")
        }
        controller.dismiss(animated: true, completion: {
            if feedback_sent == true{
                self.view.makeToast(thanksForFeedbackText, duration: 2.0, position: .center)
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
