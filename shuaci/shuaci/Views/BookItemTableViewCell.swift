//
//  BookItemTableViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class BookItemTableViewCell: UITableViewCell {
    var corner_radius: CGFloat = 9.0
    @IBOutlet var coverView: UIView!{
        didSet{
            coverView.theme_backgroundColor = "StatView.panelBgColor"
        }
    }
    @IBOutlet var upperView: UIView!{
        didSet{
            upperView.clipsToBounds = true
            if #available(iOS 11.0, *) {
                upperView.layer.cornerRadius = corner_radius
                upperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else
            {
                let path = UIBezierPath(roundedRect: upperView.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: corner_radius, height: corner_radius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.cgPath
                upperView.layer.mask = maskLayer
            }
        }
    }
    @IBOutlet var bottomView: UIView!{
        didSet{
            bottomView.clipsToBounds = true
            if #available(iOS 11.0, *) {
                bottomView.layer.cornerRadius = corner_radius
                bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else
            {
                let path = UIBezierPath(roundedRect: bottomView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: corner_radius, height: corner_radius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.cgPath
                upperView.layer.mask = maskLayer
            }
        }
    }
    @IBOutlet var bookTitle: UILabel!{
        didSet{
            bookTitle.setLineSpacing(lineSpacing: 1.5, lineHeightMultiple: 1.0)
            bookTitle.textAlignment = .center
        }
    }
    @IBOutlet var bookSubtitle: UILabel!{
        didSet{
            bookSubtitle.setLineSpacing(lineSpacing: 1.5, lineHeightMultiple: 1.0)
            bookSubtitle.textAlignment = .center
        }
    }
    
    @IBOutlet var proBtn: UIButton!{
        didSet{
            proBtn.alpha = 0
            proBtn.layer.cornerRadius = 4
            proBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.theme_backgroundColor = "Global.viewBackgroundColor"
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
        if selected {
             contentView.theme_backgroundColor = "TableView.selectedColor"
         } else {
            contentView.theme_backgroundColor = "StatView.panelBgColor"
         }
    }

}
