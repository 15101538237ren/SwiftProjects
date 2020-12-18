//
//  SettingTableViewCellWithValue.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/11/20.
//

import UIKit

class SettingTableViewCellWithValue: UITableViewCell {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var titleLbl: UILabel!{
        didSet{
            titleLbl.theme_textColor = "TableCell.TextColor"
        }
    }
    
    @IBOutlet var labelValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
