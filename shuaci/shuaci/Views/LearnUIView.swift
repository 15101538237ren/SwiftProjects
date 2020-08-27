//
//  LearnUIView.swift
//  shuaci
//
//  Created by 任红雷 on 5/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class LearnUIView: UIView {
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
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var firstMemLeft: UILabel!
    @IBOutlet var enToCNLeft: UILabel!
    @IBOutlet var cnToENLeft: UILabel!
    @IBOutlet var progressLabel: UILabel!
}
