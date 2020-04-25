//
//  PhoneLoginUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class PhoneLoginUIView: UIView {
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var verificationCodeTextField: UITextField!
    @IBOutlet var getVerificationCodeBtn: UIButton!
    @IBOutlet var phoneLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
}
