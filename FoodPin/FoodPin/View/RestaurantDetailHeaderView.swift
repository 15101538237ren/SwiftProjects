//
//  RestaurantDetailHeaderView.swift
//  FoodPin
//
//  Created by 任红雷 on 3/26/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class RestaurantDetailHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!{
        didSet {
        nameLabel.numberOfLines = 0
        }
    }
    @IBOutlet var typeLabel: UILabel!{
        didSet {
            typeLabel.layer.cornerRadius = 5.0
            typeLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet var heartImageView: UIImageView!{
        didSet {
            headerImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysTemplate)
            headerImageView.tintColor = .white
        }
    }
    @IBOutlet var ratingImageView: UIImageView!
}
