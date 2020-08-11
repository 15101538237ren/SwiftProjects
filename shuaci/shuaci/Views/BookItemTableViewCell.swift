//
//  BookItemTableViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class BookItemTableViewCell: UITableViewCell {
    @IBOutlet var cover: UIImageView!{
        didSet {
            cover.layer.cornerRadius = 9.0
            cover.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.backgroundColor = .black
            dimUIView.theme_alpha = "MainPanel.dimAlpha"
        }
    }
    @IBOutlet var name: UILabel!{
        didSet{
            name.theme_textColor = "TableView.labelTextColor"
        }
    }
    @IBOutlet var introduce: UILabel!{
        didSet {
            introduce.numberOfLines = 0
            introduce.theme_textColor = "TableView.descriptionTextColor"
        }
    }
    @IBOutlet var num_word: UILabel!{
        didSet{
            num_word.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    @IBOutlet weak var numWordLabel: UILabel!{
        didSet{
            numWordLabel.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    @IBOutlet var num_recite: UILabel!{
        didSet{
            num_recite.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    @IBOutlet weak var numReciteLabel: UILabel!{
        didSet{
            numReciteLabel.theme_textColor = "TableView.valueTextColor"
        }
    }
    
    
    
    
    var identifier: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
