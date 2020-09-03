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
    @IBOutlet var dimUIView: UIView!{
        didSet {
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
            dimUIView.theme_backgroundColor = "Global.viewBackgroundColor"
        }
    }
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
