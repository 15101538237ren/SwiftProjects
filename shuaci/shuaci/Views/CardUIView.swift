//
//  CardUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class CardUIView: UIView {
    @IBOutlet var cardImageView: UIImageView!{
        didSet {
            cardImageView.layer.cornerRadius = 20.0
            cardImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var wordLabel: UILabel!
    
    @IBOutlet var meaningLabel: UILabel!{
        didSet {
            meaningLabel.numberOfLines = 0
        }
    }
    @IBOutlet var rememberImageView: UIImageView!
    @IBOutlet var accentLabel: UILabel!
    @IBOutlet var phoneticLabel: UILabel!
    @IBOutlet var audioButton: UIButton!
}
