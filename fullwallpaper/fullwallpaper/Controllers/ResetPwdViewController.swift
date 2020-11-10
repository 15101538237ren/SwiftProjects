//
//  ResetPwdViewController.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/9/20.
//

import UIKit
import LeanCloud
import SwiftValidators

class ResetPwdViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var resetPwdBtn: UIButton!{
        didSet {
            resetPwdBtn.layer.cornerRadius = 9.0
            resetPwdBtn.layer.masksToBounds = true
        }
    }
    
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 60.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 16, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
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
        
        if !emailSentKeySet || (minutesBetweenDates(lastResetEmailSentTime, Date()) > 1) {
            if let email = email, Validator.isEmail().apply(email){
                
                let connected = Reachability.isConnectedToNetwork()
                if connected {
                    DispatchQueue.main.async {
                        self.initActivityIndicator(text: "发送中")
                    }
                    _ = LCUser.requestPasswordReset(email: email) { (result) in
                        DispatchQueue.main.async {
                            self.stopIndicator()
                        }
                        
                        switch result {
                        case .success:
                            self.presentAlert(title: "密码重置邮件已发送至\(email)!", message: "", okText: "好")
                            UserDefaults.standard.set(Date(), forKey: lastResetEmailSentTimeKey)
                        case .failure(error: let error):
                            switch error.code {
                            case 205:
                                self.presentAlert(title: "该邮箱尚未注册!", message: "", okText: "好")
                            default:
                                self.presentAlert(title: error.reason?.stringValue ?? "出现错误，请检查并重试", message: "", okText: "好")
                            }
                        }
                    }
                }else{
                    let alertCtl = presentNoNetworkAlert()
                    self.present(alertCtl, animated: true, completion: nil)
                }
                
            }
            else{
                presentAlert(title: "邮箱格式不正确!", message: "", okText: "好")
                return
            }
        } else{
            presentAlert(title: "邮件已发送，如需重新发送，请等待1分钟!", message: "", okText: "好")
            return
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
