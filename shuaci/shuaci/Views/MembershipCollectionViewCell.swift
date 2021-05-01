//
//  MembershipCollectionViewCell.swift
//  shuaci
//
//  Created by Honglei on 4/30/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
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
