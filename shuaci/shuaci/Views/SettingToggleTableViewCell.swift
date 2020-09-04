//
//  SettingToggleTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 6/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SettingToggleTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
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
    @IBOutlet var toggleSwitch: UISwitch!{
        didSet{
            toggleSwitch.theme_onTintColor = "TableView.switchOnTintColor"
            toggleSwitch.theme_thumbTintColor = "TableView.switchThumbTintColor"
        }
    }
    
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
