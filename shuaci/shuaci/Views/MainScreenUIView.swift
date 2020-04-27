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
    @IBOutlet var cardView: CustomKolodaView!
    
    @IBOutlet var emailLoginBtn: UIButton!{
        didSet {
            emailLoginBtn.layer.cornerRadius = 9.0
            emailLoginBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var mobileLoginBtn: UIButton!{
        didSet {
            mobileLoginBtn.layer.cornerRadius = 9.0
            mobileLoginBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var fastLoginBtn: UIButton!

}
