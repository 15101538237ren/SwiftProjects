//
//  EmailRegisterUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class EmailRegisterUIView: UIView {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordConfirmField: UITextField!
    @IBOutlet var emailRegisterBtn: UIButton!{
        didSet {
            emailRegisterBtn.layer.cornerRadius = 9.0
            emailRegisterBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var phoneRegisterBtn: UIButton!{
        didSet {
            phoneRegisterBtn.layer.cornerRadius = 9.0
            phoneRegisterBtn.layer.masksToBounds = true
        }
    }
}
