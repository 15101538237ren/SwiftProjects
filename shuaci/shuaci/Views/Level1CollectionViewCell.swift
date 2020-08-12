//
//  Level1CollectionViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class Level1CollectionViewCell: UICollectionViewCell {
    @IBOutlet var level1_category_label: UILabel!
    @IBOutlet var indicatorBtn: UIButton!{
        didSet{
            indicatorBtn.alpha = 0
            indicatorBtn.theme_backgroundColor = "BookVC.level2BtnColor"
        }
    }
}
