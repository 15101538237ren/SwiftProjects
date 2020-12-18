//
//  WallpaperCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit
import SwiftTheme

class WallpaperCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var heartV: UIImageView!{
        didSet{
            heartV.theme_tintColor = "CollectionCellTextColor"
        }
    }
    @IBOutlet var likeLabel: UILabel!{
        didSet{
            likeLabel.theme_textColor = "CollectionCellTextColor"
        }
    }
    @IBOutlet var dimUIView: UIView!{
        didSet{
            dimUIView.theme_alpha = "DimView.Alpha"
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
