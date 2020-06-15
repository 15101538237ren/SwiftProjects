//
//  PhoneLoginViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
class PhoneLoginViewController: UIViewController {
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var verificationCodeTextField: UITextField!
    @IBOutlet var getVerificationCodeBtn: UIButton!
    @IBOutlet var phoneLoginBtn: UIButton!
    var verificationCodeSent = false
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let regex = try! NSRegularExpression(pattern: "^1[0-9]{10}$")
    func presentAlert(title: String, message: String, okText: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginOrRegister(sender: UIButton){
         let phoneNumber:String = phoneTextField.text!
         let verificationCode:String = verificationCodeTextField.text!
         if Reachability.isConnectedToNetwork(){
             _ = LCUser.signUpOrLogIn(mobilePhoneNumber: "+86\(phoneNumber)", verificationCode: verificationCode, completion: { (result) in
                switch result {
                case .success(object: let user):
                    print(user)
                    self.showMainPanel()
                    
                case .failure(error: let error as LCError):
                    print(error.reason?.stringValue)
                    self.presentAlert(title: "错误", message: error.reason?.stringValue ?? "登录失败，请稍后重试", okText: "好")
                }
             })
         }else{
             if non_network_preseted == false{
                 let alertCtl = presentNoNetworkAlert()
                 self.present(alertCtl, animated: true, completion: nil)
                 non_network_preseted = true
             }
         }
    }
    
    func showMainPanel() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainPanelViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "mainPanelViewController") as! MainPanelViewController
        mainPanelViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(mainPanelViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendVerificationCode(sender: UIButton){
        
        self.view.endEditing(true)
        
        let phoneNumber:String = phoneTextField.text!
        
        if Reachability.isConnectedToNetwork(){
            _ = LCUser.requestLoginVerificationCode(mobilePhoneNumber: "+86\(phoneNumber)") { result in
                switch result {
                case .success:
                    self.presentAlert(title: "提示", message: "验证码已发送!", okText: "好")
                case .failure(error: let error as LCError):
                    switch error.code {
                    case 213:
                        let alertController = UIAlertController(title: "提示", message: "该手机号尚未注册,是否注册?", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
                            self.verificationCodeSent = true
                            DispatchQueue.main.async {
                                self.phoneLoginBtn.setTitle("注册", for: .normal)
                            }
                            //templateName 是短信模版名称，signatureName 是短信签名名称。可以在控制台 > 消息 > 短信 >设置中查看。
                            _ = LCSMSClient.requestShortMessage(mobilePhoneNumber: "+86\(phoneNumber)", templateName: "shuaci_verification", signatureName: "shuaci") { (result) in
                                switch result {
                                case .success:
                                    self.presentAlert(title: "提示", message: "验证码已发送!", okText: "好")
                                case .failure(error: let error):
                                    print(error)
                                }
                            }
                            
                        })
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        alertController.addAction(okayAction)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    default:
                        print(error.reason?.stringValue)
                        self.presentAlert(title: "错误", message: error.reason?.stringValue ?? "登录失败，请稍后重试", okText: "好")
                    }
                }
            }
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
    }
    
    @objc func verificationBtnTimeChange() {
            
            var time = 60
            let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
            codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))  //此处方法与Swift 3.0 不同
            codeTimer.setEventHandler {
                
                time = time - 1
                
                DispatchQueue.main.async {
                    self.disableVerificationBtn()
                }
                
                if time < 0 {
                    codeTimer.cancel()
                    DispatchQueue.main.async {
                        self.enableVerificationBtn()
                        self.getVerificationCodeBtn.setTitle("重新发送", for: .normal)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.getVerificationCodeBtn.setTitle("\(time)s后重新发送", for: .normal)
                }
                
            }
            
            codeTimer.activate()
            
        }
    
    @objc func phoneTextFieldChange() {
        // Validate the input
        let phoneNumber:String = phoneTextField.text!
        if regex.firstMatch(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count)) != nil {
            DispatchQueue.main.async {
                self.enableVerificationBtn()
            }
        }
        else{
            DispatchQueue.main.async {
                self.disableVerificationBtn()
            }
        }
    }
    
  
    @objc func disableVerificationBtn(first:Bool = false)
    {
        getVerificationCodeBtn.isEnabled = false
        getVerificationCodeBtn.backgroundColor = UIColor(red: 240, green: 239, blue: 244, alpha: 1.0)
        if !first{
            getVerificationCodeBtn.setTitleColor(UIColor(red: 139, green: 139, blue: 139, alpha: 1.0), for: .normal)
        }
    }
    @objc func enableVerificationBtn()
    {
        getVerificationCodeBtn.isEnabled = true
        getVerificationCodeBtn.backgroundColor = UIColor(red: 67, green: 161, blue: 65, alpha: 1.0)
        getVerificationCodeBtn.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1.0), for: .normal)
    }
    
    @objc func disableLoginBtn()
    {
        phoneLoginBtn.isEnabled = false
        phoneLoginBtn.backgroundColor = UIColor(red: 240, green: 239, blue: 244, alpha: 1.0)
        phoneLoginBtn.setTitleColor(UIColor(red: 139, green: 139, blue: 139, alpha: 1.0), for: .normal)
    }
    
    @objc func enableLoginBtn()
    {
        let verficationCode = verificationCodeTextField.text!
        let phoneNumber = phoneTextField.text!
        let match = regex.firstMatch(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count))
        if verficationCode.count == 6 && match != nil
        {
            phoneLoginBtn.isEnabled = true
            phoneLoginBtn.backgroundColor = UIColor(red: 67, green: 161, blue: 65, alpha: 1.0)
            phoneLoginBtn.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1.0), for: .normal)
        }
        else{
            disableLoginBtn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableLoginBtn()
        disableVerificationBtn(first: true)
        
        phoneTextField.addTarget(self, action: #selector(phoneTextFieldChange), for: UIControl.Event.editingChanged)
        verificationCodeTextField.addTarget(self, action: #selector(enableLoginBtn), for: UIControl.Event.editingChanged)
        phoneTextField.addTarget(self, action: #selector(enableLoginBtn), for: UIControl.Event.editingChanged)
        getVerificationCodeBtn.addTarget(self, action: #selector(verificationBtnTimeChange), for: .touchUpInside)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
    }
}
