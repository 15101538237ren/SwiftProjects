//
//  DiscoverTableViewCell.swift
//  FoodPin
//
//  Created by 任红雷 on 4/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!{
        didSet {
            nameLabel.numberOfLines = 0
        }
    }
    @IBOutlet var locationLabel: UILabel! {
        didSet {
            locationLabel.numberOfLines = 0
        }
    }
    @IBOutlet var typeLabel : UILabel!{
        didSet {
            typeLabel.numberOfLines = 0
        }
    }
    @IBOutlet var phoneLabel : UILabel!{
        didSet {
            phoneLabel.numberOfLines = 0
        }
    }
    @IBOutlet var descriptionLabel : UILabel!{
        didSet {
            descriptionLabel.numberOfLines = 0
        }
    }
    @IBOutlet var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
