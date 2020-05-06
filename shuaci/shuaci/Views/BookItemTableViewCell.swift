//
//  BookItemTableViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class BookItemTableViewCell: UITableViewCell {
    @IBOutlet var cover: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var introduce: UILabel!
    @IBOutlet var num_word: UILabel!
    @IBOutlet var num_recite: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
