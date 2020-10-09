//
//  ManageCollectionViewCell.swift
//  Blackpink
//
//  Created by Honglei on 10/8/20.
//

import UIKit

class ManageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var selectedV: UIImageView!
    @IBOutlet var categoryV: UIImageView!{
        didSet{
            categoryV.layer.cornerRadius = categoryV.layer.frame.width/2.0
            categoryV.layer.masksToBounds = true
        }
    }
    
    override var isSelected: Bool{
        didSet{
            selectedV.isHidden = !isSelected
        }
    }
}
