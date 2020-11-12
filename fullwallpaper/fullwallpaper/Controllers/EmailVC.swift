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
    let silverColor:UIColor = UIColor(red: 192, green: 192, blue: 192, alpha: 1)
    
    @IBOutlet var emailTextField: UITextField!{
        didSet{
            emailTextField.attributedPlaceholder = NSAttributedString(string: "邮 箱",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var passwordField: UITextField!{
        didSet{
            passwordField.attributedPlaceholder = NSAttributedString(string: "密 码",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var forgotPwdBtn: UIButton!
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var emailStackView: UIStackView!
    @IBOutlet var resetStackView: UIStackView!{
        didSet{
            resetStackView.alpha = 0
        }
    }
    
    
    @IBOutlet var resetEmailTextField: UITextField!{
        didSet{
            resetEmailTextField.attributedPlaceholder = NSAttributedString(string: "邮 箱",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var resetPwdBtn: UIButton!{
        didSet {
            resetPwdBtn.layer.cornerRadius = 9.0
            resetPwdBtn.layer.masksToBounds = true
        }
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
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
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
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
                                self.dismiss(animated: true, completion: nil)
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
                            case 216:
                                self.presentAlertInView(title: "请前往邮箱，并完成验证", message: "", okText: "好")
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
    
    @IBAction func resetPwd(sender: UIButton){
        self.view.endEditing(true)
        let email:String? = resetEmailTextField.text
        
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
                            
                            let alertController = UIAlertController(title: "密码重置邮件已发送至\(email)!", message: "", preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "好", style: .cancel, handler: {_ in
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                            alertController.addAction(okayAction)
                            self.present(alertController, animated: true)
                            
                            UserDefaults.standard.set(Date(), forKey: lastResetEmailSentTimeKey)
                            
                        case .failure(error: let error):
                            switch error.code {
                            case 205:
                                self.presentAlertInView(title: "该邮箱尚未注册!", message: "", okText: "好")
                            default:
                                self.presentAlertInView(title: error.reason?.stringValue ?? "出现错误，请检查并重试", message: "", okText: "好")
                            }
                        }
                    }
                }else{
                    let alertCtl = presentNoNetworkAlert()
                    self.present(alertCtl, animated: true, completion: nil)
                }
                
            }
            else{
                presentAlertInView(title: "邮箱格式不正确!", message: "", okText: "好")
                return
            }
        } else{
            presentAlertInView(title: "邮件已发送，如需重新发送，请等待1分钟!", message: "", okText: "好")
            return
        }
        
        
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showResetViews(){
        DispatchQueue.main.async { [self] in
            forgotPwdBtn.alpha = 0
            emailLoginBtn.alpha = 0
            emailStackView.alpha = 0
            
            resetStackView.alpha = 1
            resetPwdBtn.alpha = 1
        }
    }
    
    @IBAction func forgetPwd(_ sender: UIButton) {
        showResetViews()
    }

}
