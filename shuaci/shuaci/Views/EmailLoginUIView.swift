//
//  EmailLoginUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class EmailLoginUIView: UIView {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var phoneLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
}
