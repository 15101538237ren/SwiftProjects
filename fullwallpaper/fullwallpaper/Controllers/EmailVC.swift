//
//  EmailVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/9/20.
//

import UIKit
import LeanCloud
import SwiftValidators

class EmailVC: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var forgotPwdBtn: UIButton!
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
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
    
    func presentAlertInView(title: String, message: String, okText: String){
        let alertController = presentAlert(title: title, message: message, okText: okText)
        self.present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginOrRegister(sender: UIButton){
            self.view.endEditing(true)
             let email:String? = emailTextField.text
             let pwd:String? = passwordField.text
            
            if let email = email {
                if !Validator.isEmail().apply(email){
                    presentAlertInView(title: "邮箱格式不正确!", message: "", okText: "好")
                    return
                }
            }
            else{
                presentAlertInView(title: "邮箱不能为空!", message: "", okText: "好")
                return
            }
            
            var pwdWrong: Bool = false
            if let pwd = pwd {
                if pwd == "" || (!Validator.minLength(8).apply(pwd)) || (!Validator.maxLength(15).apply(pwd)) || (!Validator.regex("^[a-zA-Z0-9_]{8,15}$").apply(pwd)){
                    pwdWrong = true
                }
            }
            else{
                pwdWrong = true
            }
            if pwdWrong{
                presentAlertInView(title: "密码格式有误", message: "密码应为8-15位，且只包含字母、数字或下划线", okText: "好")
                return
            }
        
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                var lastEmailLoginClickTime = Date()
                var emailClickKeySet = false
                if isKeyPresentInUserDefaults(key: "lastEmailLoginClickTime"){
                    lastEmailLoginClickTime = UserDefaults.standard.object(forKey: "lastEmailLoginClickTime") as! Date
                    emailClickKeySet = true
                }
                
                if !emailClickKeySet || (minutesBetweenDates(lastEmailLoginClickTime, Date()) > 0.5) {
                    
                    DispatchQueue.main.async {
                        self.initActivityIndicator(text: "正在登录")
                    }
                    
                    _ = LCUser.logIn(email: email!, password: pwd!) { result in
                        switch result {
                        case .success(object: _):
                            UserDefaults.standard.set(Date(), forKey: "lastEmailLoginClickTime")
                            DispatchQueue.main.async {
                                self.stopIndicator()
                            }
                            //登录成功
                            
                        case .failure(error: let error):
                            DispatchQueue.main.async {
                                self.stopIndicator()
                            }
                            switch error.code {
                            case 211:
                                let alertController = UIAlertController(title: "该邮箱尚未注册,是否注册?", message: "", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
                                     do {
                                        // 创建实例
                                        let user = LCUser()
                                        user.username = LCString(email!)
                                        user.password = LCString(pwd!)
                                        user.email = LCString(email!)

                                        _ = user.signUp { (result) in
                                            switch result {
                                            case .success:
                                                self.presentAlertInView(title: "提示", message: "已发送验证邮件到\(email!)。请您单击邮件中的链接，完成验证后登录!", okText: "好")
                                                UserDefaults.standard.set(Date(), forKey: "lastEmailLoginClickTime")
                                                DispatchQueue.main.async {
                                                    self.emailLoginBtn.setTitle("登录", for: .normal)
                                                }
                                            case .failure(error: let error):
                                                switch error.code {
                                                case 202 :
                                                    self.presentAlertInView(title: "该邮箱已注册!", message: "", okText: "好")
                                                case 214:
                                                    self.presentAlertInView(title: "该邮箱已注册!", message: "", okText: "好")
                                                default:
                                                    self.presentAlertInView(title: "错误", message: error.reason?.stringValue ?? "出现错误，请重试", okText: "好")
                                                }
                                            }
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.emailLoginBtn.setTitle("注册", for: .normal)
                                    }})
                                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                                alertController.addAction(okayAction)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            case 210:
                                self.presentAlertInView(title: "密码不正确!", message: "", okText: "好")
                            case 400:
                                self.presentAlertInView(title: "密码不正确!", message: "", okText: "好")
                            default:
                                self.presentAlertInView(title: error.reason?.stringValue ?? "登录错误,请稍后再试", message: "", okText: "好")
                            }
                        }
                    }
                }
                else{
                    self.presentAlertInView(title: "登录请求太快，请等待30秒!", message: "", okText: "好")
                    return
                }
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
            
        }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgetPwd(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resetPwdVC = storyBoard.instantiateViewController(withIdentifier: "resetPwdVC") as! ResetPwdViewController
        resetPwdVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(resetPwdVC, animated: true, completion: nil)
            
        }
    }

}
