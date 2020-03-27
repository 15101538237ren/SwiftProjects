//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by 任红雷 on 3/22/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!{
        didSet {
            locationLabel.numberOfLines = 0
        }
    }
    @IBOutlet var locationLabel: UILabel! {
        didSet {
            locationLabel.numberOfLines = 0
        }
    }
    @IBOutlet var typeLabel : UILabel!{
        didSet {
            locationLabel.numberOfLines = 0
        }
    }
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var heartImageView: UIImageView!{
        didSet {
            heartImageView.image = UIImage(named: "heart-tick")?.withRenderingMode(.alwaysTemplate)
            heartImageView.tintColor = .white
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

