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
    @IBOutlet var loginButton: UIButton!{
        didSet{
            loginButton.layer.cornerRadius = 9.0
            loginButton.layer.masksToBounds = true
        }
    }
}
