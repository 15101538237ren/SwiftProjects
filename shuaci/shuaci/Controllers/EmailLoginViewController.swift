//
//  EmailLoginViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import SwiftTheme

class EmailLoginViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailLoginBtn: UIButton!
    var mainScreenVC: MainScreenViewController!
    
    let regex = try! NSRegularExpression(pattern: "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$")
    
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
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlertInView(title: String, message: String, okText: String){
        let alertController = presentAlert(title: title, message: message, okText: okText)
        self.present(alertController, animated: true)
    }
    
    @IBAction func loginOrRegister(sender: UIButton){
            self.view.endEditing(true)
             let email:String? = emailTextField.text
             let pwd:String? = passwordField.text
             
            
            var emailEmpty: Bool = false
            
            if let email = email {
                let match = regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count))
                if email == "" || match == nil{
                    emailEmpty = true
                }
            }
            else{
                emailEmpty = true
            }
            
            var pwdEmpty: Bool = false
            if let pwd = pwd {
                if pwd == ""{
                    pwdEmpty = true
                }
            }
            else{
                pwdEmpty = true
            }
            
            if emailEmpty {
                presentAlertInView(title: "请输入正确的邮箱!", message: "", okText: "好")
            }
            else if pwdEmpty {
                presentAlertInView(title: "密码不能为空!", message: "", okText: "好")
            }
            else{
                if Reachability.isConnectedToNetwork(){
                    let lastEmailLoginClickTimeKey:String = "lastEmailLoginClickTime1"
                    var lastEmailLoginClickTime = Date()
                    var emailClickKeySet = false
                    if isKeyPresentInUserDefaults(key: lastEmailLoginClickTimeKey){
                        lastEmailLoginClickTime = UserDefaults.standard.object(forKey: lastEmailLoginClickTimeKey) as! Date
                        emailClickKeySet = true
                    }
//                    else
//                    {
//                        UserDefaults.standard.set(lastEmailLoginClickTime, forKey: lastEmailLoginClickTimeKey)
//                    }
                    
                    if !emailClickKeySet || (minutesBetweenDates(lastEmailLoginClickTime, Date()) > 1) {
                        DispatchQueue.main.async {
                            self.initActivityIndicator(text: "正在登录")
                        }
                        _ = LCUser.logIn(email: email!, password: pwd!) { result in
                            switch result {
                            case .success(object: let _):
                                UserDefaults.standard.set(Date(), forKey: lastEmailLoginClickTimeKey)
                                self.showMainPanel()
                                
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

                                            // 等同于 user.set("username", value: "Tom")
                                            user.username = LCString(email!)
                                            user.password = LCString(pwd!)
                                            user.email = LCString(email!)

                                            _ = user.signUp { (result) in
                                                switch result {
                                                case .success:
                                                    self.presentAlertInView(title: "提示", message: "已发送验证邮件到\(email!)。请您单击邮件中的链接，完成验证后登录!", okText: "好")
                                                    UserDefaults.standard.set(Date(), forKey: lastEmailLoginClickTimeKey)
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
                                                        self.presentAlertInView(title: "错误", message: error.description, okText: "好")
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
                                    self.presentAlertInView(title: error.reason ?? "登录错误,请稍后再试", message: "", okText: "好")
                                }
                            }
                        }
                    }
                    else{
                        self.presentAlertInView(title: "登录请求太快，请等待1分钟!", message: "", okText: "好")
                    }
                }else{
                   if non_network_preseted == false{
                        let alertCtl = presentNoNetworkAlert()
                        self.present(alertCtl, animated: true, completion: nil)
                        non_network_preseted = true
                    }
                }
                
            }
            
        }
    func showMainPanel() {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: {
                self.stopIndicator()
                self.mainScreenVC.showMainPanel()
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        if !Reachability.isConnectedToNetwork(){
            let alertCtl = presentNoNetworkAlert()
            UIApplication.topViewController()?.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func forgetPwd(_ sender: UIButton) {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let resetPwdVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "resetPwd") as! ResetPwdViewController
        resetPwdVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(resetPwdVC, animated: true, completion: nil)
            
        }
    }
    
    
}
