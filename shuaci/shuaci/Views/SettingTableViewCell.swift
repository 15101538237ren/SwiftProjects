//
//  SettingTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

class SettingTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var nameLabel: UILabel!{
        didSet{
            nameLabel.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet var valueLabel: UILabel!{
        didSet{
            valueLabel.theme_textColor = "TableView.valueTextColor"
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
