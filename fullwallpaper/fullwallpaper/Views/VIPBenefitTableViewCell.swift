//
//  VIPBenefitTableViewCell.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit

class VIPBenefitTableViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
