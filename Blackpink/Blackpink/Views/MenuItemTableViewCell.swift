//
//  MenuItemTableViewCell.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var iconImgV: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
