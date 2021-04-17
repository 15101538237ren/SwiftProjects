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
    
    @IBOutlet var giveupUIView: UIView!{
        didSet{
            giveupUIView.backgroundColor = .clear
            giveupUIView.alpha = 0
        }
    }
    
    @IBOutlet var userPanelView: UIView!
    @IBOutlet var loadingView: UIView!
    
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
    
    @IBOutlet var backBtn: UIButton!{
        didSet{
            backBtn.theme_tintColor = "Global.backBtnTintColor"
        }
    }
    
    @IBOutlet var leftAvatar: UIImageView!{
        didSet{
            leftAvatar.layer.cornerRadius = leftAvatar.layer.frame.width/2.0
            leftAvatar.layer.masksToBounds = true
            leftAvatar.layer.borderWidth = learningUserAvtarBorderWidth
            leftAvatar.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet var midAvatar: UIImageView!{
        didSet{
            midAvatar.layer.cornerRadius = midAvatar.layer.frame.width/2.0
            midAvatar.layer.masksToBounds = true
            midAvatar.layer.borderWidth = learningUserAvtarBorderWidth
            midAvatar.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet var rightAvatar: UIImageView!{
        didSet{
            rightAvatar.layer.cornerRadius = rightAvatar.layer.frame.width/2.0
            rightAvatar.layer.masksToBounds = true
            rightAvatar.layer.borderWidth = learningUserAvtarBorderWidth
            rightAvatar.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet var usersPanelView: UIView!{
        didSet{
            let conerRadius: CGFloat = 22
            usersPanelView.clipsToBounds = true
            if #available(iOS 11.0, *) {
                usersPanelView.layer.cornerRadius = conerRadius
                usersPanelView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else {
                let path = UIBezierPath(roundedRect: usersPanelView.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: conerRadius, height: conerRadius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.cgPath
                usersPanelView.layer.mask = maskLayer
            }
        }
    }
    
}
