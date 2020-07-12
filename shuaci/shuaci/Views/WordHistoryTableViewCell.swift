//
//  WordHistoryTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 7/11/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class WordHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var wordHeadLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var masterPercentLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
