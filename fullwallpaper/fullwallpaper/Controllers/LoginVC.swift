//
//  EmailVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/9/20.
//

import UIKit
import LeanCloud
import SwiftValidators
import PhoneNumberKit

class LoginVC: UIViewController {
    enum LoginType {
        case Phone
        case Email
        case ResetEmail
    }
    
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
    @IBOutlet var forgotPwdBtn: UIButton!{
        didSet{
            forgotPwdBtn.alpha = 0
        }
    }
    
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
            emailLoginBtn.alpha = 0
        }
    }
    
    @IBOutlet var emailLoginIndicationBtn: UIButton!{
        didSet {
            emailLoginIndicationBtn.alpha = 1
        }
    }
    
    @IBOutlet var phoneLoginBtn: UIButton!{
        didSet {
            phoneLoginBtn.layer.cornerRadius = 9.0
            phoneLoginBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var phoneNumTextField: UITextField!{
        didSet{
            phoneNumTextField.attributedPlaceholder = NSAttributedString(string: "手机号",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var verificationCodeTextField: UITextField!{
        didSet{
            verificationCodeTextField.attributedPlaceholder = NSAttributedString(string: "短信验证码",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var getVerificationCodeBtn: UIButton!{
        didSet {
            getVerificationCodeBtn.layer.cornerRadius = 15.0
            getVerificationCodeBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var phoneStackView: UIStackView!
    
    @IBOutlet var emailStackView: UIStackView!{
        didSet{
            emailStackView.alpha = 0
        }
    }
    
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
    var loginType: LoginType = .Email
    var verificationCodeSent = false
    var dialCode: String = "+86"
    var countryCode: String = "CN"
    let phoneNumberKit:PhoneNumberKit = PhoneNumberKit()
    
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
    
    func setupElements(){
        DispatchQueue.main.async { [self] in
            switch loginType {
            case .Phone:
                emailStackView.alpha = 0
                resetStackView.alpha = 0
                emailLoginBtn.alpha = 0
                resetPwdBtn.alpha = 0
                forgotPwdBtn.alpha = 0
                emailLoginIndicationBtn.setTitle("邮箱登录", for: .normal)
                phoneStackView.alpha = 1
                emailLoginIndicationBtn.alpha = 1
                phoneLoginBtn.alpha = 1
            case .Email:
                emailStackView.alpha = 1
                emailLoginBtn.alpha = 1
                emailLoginIndicationBtn.alpha = 1
                forgotPwdBtn.alpha = 1
                resetStackView.alpha = 0
                phoneStackView.alpha = 0
                phoneLoginBtn.alpha = 0
                resetPwdBtn.alpha = 0
                emailLoginIndicationBtn.setTitle("手机号登录", for: .normal)
            case .ResetEmail:
                emailStackView.alpha = 0
                phoneStackView.alpha = 0
                emailLoginBtn.alpha = 0
                phoneLoginBtn.alpha = 0
                emailLoginIndicationBtn.alpha = 0
                forgotPwdBtn.alpha = 0
                emailLoginIndicationBtn.setTitle("邮箱登录", for: .normal)
                resetStackView.alpha = 1
                resetPwdBtn.alpha = 1
            }
        }
    }
    
    func showSetProfileVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setUserProfileVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "setUserProfileVC") as! SetUserProfileVC
        setUserProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(setUserProfileVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeLoginMethod(_ sender: UIButton) {
        self.view.endEditing(true)
        switch loginType {
            case .Phone:
                loginType = .Email
            case .Email:
                loginType = .Phone
            default:
                loginType = .Email
        }
        setupElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        getVerificationCodeBtn.addTarget(self, action: #selector(verificationBtnTimeChange), for: .touchUpInside)
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
    
    @IBAction func loginByEmail(sender: UIButton){
            self.view.endEditing(true)
             let email:String? = emailTextField.text
             let pwd:String? = passwordField.text
            
            if let email = email {
                if !Validator.isEmail().apply(email){
                    self.view.makeToast("邮箱格式不正确!", duration: 1.0, position: .center)
                    return
                }
            }
            else{
                self.view.makeToast("邮箱不能为空!", duration: 1.0, position: .center)
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
                self.view.makeToast("密码应为8-15位，且只包含字母、数字或下划线", duration: 1.5, position: .center)
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
                            getUserLikedWPs()
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
                                                    self.view.makeToast("该邮箱已注册!", duration: 1.0, position: .center)
                                                case 214:
                                                    self.view.makeToast("该邮箱已注册!", duration: 1.0, position: .center)
                                                default:
                                                    self.view.makeToast("错误:\(error.reason?.stringValue ?? "出现错误，请重试")", duration: 1.0, position: .center)
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
                                self.view.makeToast("密码不正确!", duration: 1.0, position: .center)
                            case 216:
                                self.view.makeToast("请前往邮箱，并完成验证", duration: 1.2, position: .center)
                            case 400:
                                self.view.makeToast("密码不正确!", duration: 1.0, position: .center)
                            default:
                                self.view.makeToast("\(error.reason?.stringValue ?? "登录错误,请稍后再试")", duration: 1.0, position: .center)
                            }
                        }
                    }
                }
                else{
                    self.view.makeToast("登录请求太快，请等待30秒!", duration: 1.0, position: .center)
                    return
                }
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
            
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
                            self.view.makeToast("验证码已发送!", duration: 1.0, position: .center)
                        case .failure(error: let error):
                            switch error.code {
                            case 213:
                                let alertController = UIAlertController(title: "该手机号尚未注册,是否注册?", message: "", preferredStyle: .alert)
                                let okayAction = UIAlertAction(title: "是", style: .default, handler: { action in
                                    DispatchQueue.main.async {
                                        self.phoneLoginBtn.setTitle("注册", for: .normal)
                                    }
                                    _ = LCSMSClient.requestShortMessage(mobilePhoneNumber: phoneNumber, templateName: "创建用户", signatureName: "雷行天下全面屏壁纸") { (result) in
                                        switch result {
                                        case .success:
                                            self.verificationCodeSent = true
                                            self.view.makeToast("验证码已发送!", duration: 1.0, position: .center)
                                        case .failure(error: let error):
                                            self.view.makeToast("发送失败:\(error.reason?.stringValue ?? "")", duration: 1.0, position: .center)
                                        }
                                    }

                                })
                                
                                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                                alertController.addAction(okayAction)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            default:
                                self.view.makeToast("发送失败:\(error.reason?.stringValue ?? "")!", duration: 1.0, position: .center)
                            }
                    }
                }
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
        }
        catch {
            self.view.makeToast("手机号有误!", duration: 1.0, position: .center)
        }
    }
    
    @IBAction func loginByPhone(sender: UIButton){
         self.view.endEditing(true)
         let phoneNumber:String = "\(self.dialCode)\(self.phoneNumTextField.text!)"
         let verificationCode:String = verificationCodeTextField.text!
        
        do {
            let _ = try phoneNumberKit.parse(phoneNumber, withRegion: self.countryCode, ignoreType: true)
            
            if verificationCode.count != 6
            {
                self.view.makeToast("验证码有误!", duration: 1.0, position: .center)
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
                       getUserLikedWPs()
                       self.dismiss(animated: true, completion: nil)
                   case .failure(error: let error):
                        self.view.makeToast("\(error.reason ?? "登录失败，请稍后重试")", duration: 1.0, position: .center)
                   }
                })
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
        }
        catch {
            self.view.makeToast("手机号有误!", duration: 1.0, position: .center)
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
                            self.view.makeToast("密码重置邮件已发送至\(email)!", duration: 1.0, position: .center)
                            UserDefaults.standard.set(Date(), forKey: lastResetEmailSentTimeKey)
                            
                        case .failure(error: let error):
                            switch error.code {
                            case 205:
                                self.view.makeToast("该邮箱尚未注册!", duration: 1.0, position: .center)
                            default:
                                self.view.makeToast("\(error.reason?.stringValue ?? "出现错误，请检查并重试")", duration: 1.0, position: .center)
                            }
                        }
                    }
                }else{
                    self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
                }
                
            }
            else{
                self.view.makeToast("邮箱格式不正确!", duration: 1.0, position: .center)
                return
            }
        } else{
            self.view.makeToast("邮件已发送，如需重新发送，请等待1分钟!", duration: 1.0, position: .center)
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
