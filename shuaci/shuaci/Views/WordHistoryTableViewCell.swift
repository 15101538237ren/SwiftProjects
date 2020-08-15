//
//  WordHistoryTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 7/11/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class WordHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var wordHeadLabel: UILabel!{
        didSet{
            wordHeadLabel.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet weak var timerLabel: UILabel!{
        didSet{
            timerLabel.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    @IBOutlet weak var timerImgView: UIImageView!
    
    @IBOutlet weak var masteredUILabel: UILabel!{
        didSet{
            masteredUILabel.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    @IBOutlet weak var masterPercentLabel: UILabel!{
        didSet{
            masterPercentLabel.theme_textColor = "TableView.valueTextColor"
        }
    }
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
