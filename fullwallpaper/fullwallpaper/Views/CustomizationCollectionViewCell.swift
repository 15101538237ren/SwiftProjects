//
//  CustomizationCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei on 4/28/21.
//

import UIKit

class CustomizationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var themeImageView: UIImageView!{
        didSet {
            themeImageView.layer.cornerRadius = 15.0
            themeImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var btnImageView: UIImageView!
    @IBOutlet var themeNameLabel: UILabel!
    @IBOutlet var dimUIView: UIView!{
        didSet {
            dimUIView.layer.cornerRadius = 15.0
            dimUIView.theme_backgroundColor = "View.BackgroundColor"
            dimUIView.theme_alpha = "DimView.Alpha"
        }
    }
}
