//
//  NumberOfWordTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 6/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class NumberOfWordTableViewCell: UITableViewCell {
    @IBOutlet var numberOfWordLabel: UILabel!{
        didSet{
            numberOfWordLabel.textColor = .black
        }
    }
    @IBOutlet var checkedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
