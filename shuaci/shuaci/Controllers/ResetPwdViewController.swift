//
//  ResetPwdViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class ResetPwdViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var resetPwdBtn: UIButton!
    let selfController = self
    let regex = try! NSRegularExpression(pattern: "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$")
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String, okText: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resetPwd(sender: UIButton){
        self.view.endEditing(true)
        let email:String? = emailTextField.text
        let lastResetEmailSentTimeKey:String = "lastResetEmailSentTime"
        var lastResetEmailSentTime = Date()
        var emailSentKeySet = false
        if isKeyPresentInUserDefaults(key: lastResetEmailSentTimeKey){
            lastResetEmailSentTime = UserDefaults.standard.object(forKey: lastResetEmailSentTimeKey) as! Date
            emailSentKeySet = true
        }
        
        if !emailSentKeySet || (minutesBetweenDates(lastResetEmailSentTime, Date()) > 2) {
            if let email = email, let match = regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)), email != "" {
                if Reachability.isConnectedToNetwork(){
                    _ = LCUser.requestPasswordReset(email: email) { (result) in
                        switch result {
                        case .success:
                            self.presentAlert(title: "提示", message: "密码重置邮件已发送至\(email)!请查看邮件", okText: "好")
                            UserDefaults.standard.set(Date(), forKey: lastResetEmailSentTimeKey)
                        case .failure(error: let error as LCError):
                            switch error.code {
                            case 205:
                                self.presentAlert(title: "错误", message: "该邮箱尚未注册!", okText: "好")
                            default:
                                self.presentAlert(title: "错误", message: error.reason?.stringValue ?? "出现错误，请检查并重试", okText: "好")
                            }
                        }
                    }
                }else{
                    let alertCtl = presentNoNetworkAlert()
                    self.present(alertCtl, animated: true, completion: nil)
                    non_network_preseted = true
                }
                
            }
            else{
                presentAlert(title: "错误", message: "请输入正确的邮箱!", okText: "好")
            }
        } else{
            presentAlert(title: "提示", message: "邮件已发送，如需重新发送，请等待2分钟!", okText: "好")
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
    }

}
