//
//  ThemeCollectionViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var themeImageView: UIImageView!{
        didSet {
            themeImageView.layer.cornerRadius = 15.0
            themeImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var themeNameLabel: UILabel!{
        didSet {
            themeNameLabel.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet var dimUIView: UIView!{
        didSet {
            dimUIView.layer.cornerRadius = 15.0
            dimUIView.theme_backgroundColor = "Global.viewBackgroundColor"
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
        }
    }
    @IBOutlet var proBtn: UIButton!{
        didSet{
            proBtn.alpha = 0
            proBtn.layer.cornerRadius = 4
            proBtn.layer.masksToBounds = true
        }
    }
}
