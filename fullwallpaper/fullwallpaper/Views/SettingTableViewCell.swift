//
//  SettingTableViewCell.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/7/20.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet var titleLbl: UILabel!{
        didSet{
            titleLbl.theme_textColor = "TableCell.TextColor"
        }
    }
    @IBOutlet var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
