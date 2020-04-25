//
//  MainPanelUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class MainPanelUIView: UIView {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var sentenceOfDayLabel: UILabel!
    @IBOutlet var cardView: CardUIView!
    @IBOutlet var learnBtn: UIButton!{
        didSet {
            learnBtn.layer.cornerRadius = 9.0
            learnBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var reviewBtn: UIButton!{
        didSet {
            reviewBtn.layer.cornerRadius = 9.0
            reviewBtn.layer.masksToBounds = true
        }
    }
}
