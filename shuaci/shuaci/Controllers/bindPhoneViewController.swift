//
//  bindPhoneViewController.swift
//  shuaci
//
//  Created by Honglei on 7/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class bindPhoneViewController: UIViewController {
    var phoneNumber: String?
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var verificationCodeTextField: UITextField!
    @IBOutlet var getVerificationCodeBtn: UIButton!{
        didSet {
            getVerificationCodeBtn.layer.cornerRadius = 15.0
            getVerificationCodeBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var phoneBindBtn: UIButton!{
        didSet {
            phoneBindBtn.layer.cornerRadius = 15.0
            phoneBindBtn.layer.masksToBounds = true
        }
    }
    var verificationCodeSent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if phoneNumber != nil && phoneNumber != "" {
            phoneTextField.text = phoneNumber!
        }
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
