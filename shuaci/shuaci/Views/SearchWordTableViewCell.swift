//
//  SearchWordTableViewCell.swift
//  shuaci
//
//  Created by Honglei on 7/31/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SearchWordTableViewCell: UITableViewCell {
    @IBOutlet var wordLabel: UILabel!{
        didSet{
            wordLabel.lineBreakMode = .byWordWrapping
            wordLabel.numberOfLines = 0
            wordLabel.theme_textColor = "SearchVC.wordColor"
        }
    }
    @IBOutlet var meaningLabel: UILabel!{
        didSet{
            meaningLabel.lineBreakMode = .byWordWrapping
            meaningLabel.numberOfLines = 0
            meaningLabel.theme_textColor = "SearchVC.transColor"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
             contentView.theme_backgroundColor = "TableView.selectedColor"
         } else {
            contentView.theme_backgroundColor = "Global.viewBackgroundColor"
         }
    }

}
