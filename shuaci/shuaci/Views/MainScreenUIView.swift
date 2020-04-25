//
//  MainScreenUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class MainScreenUIView: UIView {
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var introLabel: UILabel!
    @IBOutlet var cardView: CardUIView!
    
    @IBOutlet var loginButton: UIButton!{
        didSet {
            loginButton.layer.cornerRadius = 9.0
            loginButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var registerButton: UIButton!{
        didSet {
            registerButton.layer.cornerRadius = 9.0
            registerButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var fastLoginLabel: UILabel!
    @IBOutlet var wechatLoginButton: UIButton!
    @IBOutlet var qqLoginButton: UIButton!
    @IBOutlet var weiboLoginButton: UIButton!

}
