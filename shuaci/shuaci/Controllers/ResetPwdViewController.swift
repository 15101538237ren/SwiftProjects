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
        
        if let email = email, let match = regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)), email != "" {
            if Reachability.isConnectedToNetwork(){
                _ = LCUser.requestPasswordReset(email: email) { (result) in
                    switch result {
                    case .success:
                        self.presentAlert(title: "提示", message: "密码重置邮件已发送至\(email)!请查看邮件", okText: "好")
                    case .failure(error: let error):
                        print(error)
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
    }

}
