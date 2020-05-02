//
//  EmailLoginViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class EmailLoginViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailLoginBtn: UIButton!

    
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
                presentAlert(title: "邮箱格式错误", message: "请输入正确的邮箱!", okText: "好")
            }
            else if pwdEmpty {
                presentAlert(title: "密码为空", message: "密码不能为空!", okText: "好")
            }
            else{
                _ = LCUser.logIn(email: email!, password: pwd!) { result in
                    switch result {
                    case .success(object: let user):
                        self.showMainPanel()
                    case .failure(error: let error):
                        switch error.code {
                        case 211:
                            let alertController = UIAlertController(title: "该邮箱尚未注册", message: "该邮箱尚未注册,是否注册?", preferredStyle: .alert)
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
                                            self.presentAlert(title: "请验证邮件", message: "已发送验证邮件到\(email!)。请您单击邮件中的链接，完成验证后登录!", okText: "好")
                                            DispatchQueue.main.async {
                                                self.emailLoginBtn.setTitle("登录", for: .normal)
                                            }
                                        case .failure(error: let error):
                                            switch error.code {
                                            case 202 :
                                                self.presentAlert(title: "邮箱已注册", message: "该邮箱已注册!", okText: "好")
                                            case 214:
                                                self.presentAlert(title: "邮箱已注册", message: "该邮箱已注册!", okText: "好")
                                            default:
                                                print(error)
                                            }
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                                
                                DispatchQueue.main.async {
                                    self.emailLoginBtn.setTitle("注册", for: .normal)
                                }})
                            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                            alertController.addAction(okayAction)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                            default:
                                print(error)
                        }
                    }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
    }
    
}
