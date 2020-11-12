//
//  WallpaperCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var heartV: UIImageView!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var proBtn: UIButton!{
        didSet{
            proBtn.alpha = 0
            proBtn.layer.cornerRadius = 4
            proBtn.layer.masksToBounds = true
        }
    }
}
