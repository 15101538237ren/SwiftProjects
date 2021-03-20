//
//  AuditCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/5/20.
//

import UIKit

class AuditCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var selectedV: UIImageView!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var proBtn: UIButton!{
        didSet{
            proBtn.alpha = 0
            proBtn.layer.cornerRadius = 4
            proBtn.layer.masksToBounds = true
        }
    }
    override var isSelected: Bool{
        didSet{
            selectedV.isHidden = !isSelected
        }
    }
}
