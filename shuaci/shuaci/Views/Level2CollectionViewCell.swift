//
//  Level2CollectionViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class Level2CollectionViewCell: UICollectionViewCell {
    // this will be our "call back" action
    var btnTapAction : (()->())?
    
    @objc func btnTapped() {
        btnTapAction?()
    }
    
    @IBOutlet var level2_category_button: UIButton!{
        didSet{
            level2_category_button.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
            level2_category_button.theme_backgroundColor = "BookVC.level2BtnColor"
            level2_category_button.setTitleColor(.white, for: .normal)
        }
    }
}
