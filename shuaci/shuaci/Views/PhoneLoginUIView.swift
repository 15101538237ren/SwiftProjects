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
}
