//
//  LearnUIView.swift
//  shuaci
//
//  Created by 任红雷 on 5/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

class LearnUIView: UIView {
    @IBOutlet var dimUIView: UIView!{
        didSet {
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
            dimUIView.theme_backgroundColor = "Global.viewBackgroundColor"
        }
    }
    @IBOutlet var undoBtn: UIButton!{
        didSet {
            undoBtn.layer.cornerRadius = undoBtn.layer.frame.width/2.0
            undoBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var noBtn: UIButton!{
        didSet {
            noBtn.layer.cornerRadius = noBtn.layer.frame.width/2.0
            noBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var trashBtn: UIButton!{
        didSet {
            trashBtn.layer.cornerRadius = trashBtn.layer.frame.width/2.0
            trashBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var yesBtn: UIButton!{
        didSet {
            yesBtn.layer.cornerRadius = yesBtn.layer.frame.width/2.0
            yesBtn.layer.masksToBounds = true
        }
    }
    @IBOutlet var collectBtn: UIButton!{
        didSet {
            collectBtn.layer.cornerRadius = collectBtn.layer.frame.width/2.0
            collectBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var timeLabel: UILabel!{
        didSet{
            timeLabel.theme_textColor = "LearningVC.TextLabelColor"
        }
    }
    @IBOutlet var firstMemLeft: UILabel!{
        didSet{
            firstMemLeft.theme_textColor = "LearningVC.TextLabelColor"
        }
    }
    @IBOutlet var enToCNLeft: UILabel!{
        didSet{
            enToCNLeft.theme_textColor = "LearningVC.TextLabelColor"
        }
    }
    @IBOutlet var cnToENLeft: UILabel!{
        didSet{
            cnToENLeft.theme_textColor = "LearningVC.TextLabelColor"
        }
    }
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var backBtn: UIButton!{
        didSet{
            backBtn.theme_tintColor = "Global.backBtnTintColor"
        }
    }
}
