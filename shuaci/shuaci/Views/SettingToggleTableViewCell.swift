//
//  SettingToggleTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SettingToggleTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!{
        didSet {
            iconView.layer.cornerRadius = iconView.layer.frame.width/2.0
            iconView.layer.masksToBounds = true
        }
    }
    @IBOutlet var nameLabel: UILabel!{
        didSet{
            nameLabel.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet var leftValueLabel: UILabel!{
        didSet{
            leftValueLabel.theme_textColor = "TableView.valueTextColor"
        }
    }
    @IBOutlet var toggleSwitch: UISwitch!
    
    @IBOutlet var rightValueLabel: UILabel!{
        didSet{
            rightValueLabel.theme_textColor = "TableView.valueTextColor"
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
