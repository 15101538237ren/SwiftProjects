//
//  MembershipCollectionViewCell.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 2021/2/19.
//

import UIKit

class MembershipCollectionViewCell: UICollectionViewCell {
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var pastPriceLabel: UILabel!
    @IBOutlet var amountSavedLabel: UILabel!
    @IBOutlet var avgPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
    }
}
