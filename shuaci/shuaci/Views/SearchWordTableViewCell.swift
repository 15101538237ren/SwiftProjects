//
//  SearchWordTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 7/31/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SearchWordTableViewCell: UITableViewCell {
    let redColor:UIColor = UIColor(red: 168, green: 0, blue: 0, alpha: 1)
    @IBOutlet var wordLabel: UILabel!{
        didSet{
            wordLabel.numberOfLines = 0
            wordLabel.textColor = redColor
        }
    }
    @IBOutlet var meaningLabel: UILabel!{
        didSet{
            meaningLabel.lineBreakMode = .byWordWrapping
            meaningLabel.numberOfLines = 0
            meaningLabel.theme_textColor = "TableView.valueTextColor"
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
