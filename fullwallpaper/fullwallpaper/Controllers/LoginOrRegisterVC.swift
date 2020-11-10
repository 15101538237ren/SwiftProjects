//
//  LoginOrRegisterVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/9/20.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import LeanCloud


class LoginOrRegisterVC: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    @IBOutlet var countryPickerView: CountryPickerView!
    @IBOutlet var phoneNumTextField: UITextField!
    @IBOutlet var verificationCodeTextField: UITextField!
    @IBOutlet var getVerificationCodeBtn: UIButton!{
        didSet {
            getVerificationCodeBtn.layer.cornerRadius = 15.0
            getVerificationCodeBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var phoneLoginBtn: UIButton!{
        didSet {
            phoneLoginBtn.layer.cornerRadius = 15.0
            phoneLoginBtn.layer.masksToBounds = true
        }
    }
    
    var verificationCodeSent = false
    var dialCode: String = "+86"
    var countryCode: String = "CN"
    let phoneNumberKit:PhoneNumberKit = PhoneNumberKit()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.showCountryCodeInView = false
        getVerificationCodeBtn.addTarget(self, action: #selector(verificationBtnTimeChange), for: .touchUpInside)
    }
    
    func presentAlert(title: String, message: String, okText: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okText, style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendVerificationCode(sender: UIButton){
        
        self.view.endEditing(true)
        
        let phoneNumber:String = "\(self.dialCode)\(self.phoneNumTextField.text!)"
        do {
            let _ = try phoneNumberKit.parse(phoneNumber, withRegion: self.countryCode, ignoreType: true)
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                DispatchQueue.main.async {
                    self.initActivityIndicator(text: "正在发送")
                }
                _ = LCUser.requestLoginVerificationCode(mobilePhoneNumber: phoneNumber) { result in
                    DispatchQueue.main.async {
                        self.stopIndicator()
                    }
                    
                    switch result {
                        case .success:
                            self.presentAlert(title: "验证码已发送!", message: "", okText: "好")
                        case .failure(error: let error):
                            switch error.code {
                            case 213:
                                let alertController = UIAlertController(title: "该手机号尚未注册,是否注册?", message: "", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
                                    DispatchQueue.main.async {
                                        self.phoneLoginBtn.setTitle("注册", for: .normal)
                                    }
                                    _ = LCSMSClient.requestShortMessage(mobilePhoneNumber: phoneNumber, templateName: "fullwallpaper_verification", signatureName: "fullwallpaper") { (result) in
                                        switch result {
                                        case .success:
                                            self.verificationCodeSent = true
                                            self.presentAlert(title: "验证码已发送!", message: "", okText: "好")
                                        case .failure(error: let error):
                                            self.presentAlert(title: "发送失败", message: error.reason?.stringValue ?? "", okText: "好")
                                        }
                                    }

                                })
                                
                                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                                alertController.addAction(okayAction)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            default:
                                self.presentAlert(title: "发送失败", message: error.reason?.stringValue ?? "", okText: "好")
                            }
                    }
                }
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
        }
        catch {
            presentAlert(title: "手机号有误", message: "", okText: "好")
        }
    }
    
    
    @objc func verificationBtnTimeChange() {
        if verificationCodeSent{
            var time = 60
            let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
            codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))  //此处方法与Swift 3.0 不同
            codeTimer.setEventHandler { [self] in
                
                time = time - 1
                if getVerificationCodeBtn.isEnabled{
                    DispatchQueue.main.async {
                        self.disableVerificationBtn()
                    }
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
        getVerificationCodeBtn.backgroundColor = .systemOrange
        getVerificationCodeBtn.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1.0), for: .normal)
    }
    
    @IBAction func loginOrRegister(sender: UIButton){
         self.view.endEditing(true)
         let phoneNumber:String = "\(self.dialCode)\(self.phoneNumTextField.text!)"
         let verificationCode:String = verificationCodeTextField.text!
        
        do {
            let _ = try phoneNumberKit.parse(phoneNumber, withRegion: self.countryCode, ignoreType: true)
            
            if verificationCode.count != 6
            {
                presentAlert(title: "验证码有误", message: "", okText: "好")
                return
            }
            
            let connected = Reachability.isConnectedToNetwork()
            if connected {
               DispatchQueue.main.async {
                   self.initActivityIndicator(text: "正在登录")
               }
                _ = LCUser.signUpOrLogIn(mobilePhoneNumber: phoneNumber, verificationCode: verificationCode, completion: { (result) in
                   DispatchQueue.main.async {
                       self.stopIndicator()
                   }
                   switch result {
                   case .success:
                       self.dismiss(animated: true, completion: nil)
                   case .failure(error: let error):
                       self.presentAlert(title: error.reason ?? "登录失败，请稍后重试", message: "", okText: "好")
                   }
                })
            }else{
               let alertCtl = presentNoNetworkAlert()
               self.present(alertCtl, animated: true, completion: nil)
            }
        }
        catch {
            presentAlert(title: "手机号有误", message: "", okText: "好")
        }
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.dialCode = country.phoneCode
        self.countryCode = country.code
    }
    
    @IBAction func emailLogin(_ sender: UIButton) {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let emailVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "emailVC") as! EmailVC
        emailVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(emailVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
