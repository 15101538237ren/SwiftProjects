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
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var learnBtn: UIButton!{
        didSet {
            learnBtn.layer.cornerRadius = 9.0
            learnBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.backgroundColor = .black
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
        }
    }
    @IBOutlet var reviewBtn: UIButton!{
        didSet {
            reviewBtn.layer.cornerRadius = 9.0
            reviewBtn.layer.masksToBounds = true
        }
    }
}
