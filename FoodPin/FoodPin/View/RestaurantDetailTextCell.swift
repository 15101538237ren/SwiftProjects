//
//  RestaurantDetailTextCell.swift
//  FoodPin
//
//  Created by 任红雷 on 3/26/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class RestaurantDetailTextCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 0
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
