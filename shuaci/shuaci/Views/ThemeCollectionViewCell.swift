//
//  ThemeCollectionViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var themeImageView: UIImageView!
    @IBOutlet var themeNameLabel: UILabel!{
        didSet {
            themeNameLabel.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet var dimUIView: UIView!{
        didSet {
            dimUIView.backgroundColor = .black
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
        }
    }
}
