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
    
    @IBOutlet var tableView: UITableView!
    let separatorHeight:CGFloat = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "View.BackgroundColor"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath) as! SettingTableViewCell
        
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        cell.imgView.image = settingItems[section][row].icon
        cell.titleLbl.text = settingItems[section][row].name
        
        if row != settingItems[section].count - 1{
            let bottomBorder = CALayer()

            bottomBorder.frame = CGRect(x: 0.0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight)
            bottomBorder.backgroundColor = UIColor(white: 0.92, alpha: 1.0).cgColor
            
            cell.contentView.layer.addSublayer(bottomBorder)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
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
    
    func showFeedBackMailComposer(){
        guard MFMailComposeViewController.canSendMail() else{
            let ac = UIAlertController(title: "无法使用邮箱", message: "请检查您的网络或者邮箱设置。", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
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
        let ac = UIAlertController(title: "缓存清除成功", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
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
                let ac = UIAlertController(title: "反馈已发送", message: "感谢您的反馈，我们会认真考虑并在需要时给您回复。", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
}
