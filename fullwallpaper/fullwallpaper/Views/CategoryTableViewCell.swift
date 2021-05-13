//
//  CategoryTableViewCell.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import SwiftTheme

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "CollectionCellTextColor"
            if english{
                titleLabel.font = UIFont(name: "Clicker Script", size: 40.0)
            }
        }
    }
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var dimUIView: UIView!{
        didSet{
            dimUIView.theme_alpha = "DimView.Alpha"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
