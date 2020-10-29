//
//  WallpaperCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!{
        didSet{
            imageV.layer.cornerRadius = 12
            imageV.layer.masksToBounds = true
        }
    }
    @IBOutlet var heartV: UIImageView!
    @IBOutlet var likeLabel: UILabel!
}
