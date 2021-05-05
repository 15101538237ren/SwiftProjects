//
//  StyleIntroVC.swift
//  fullwallpaper
//
//  Created by Honglei on 5/3/21.
//

import UIKit

class StyleIntroVC: UIViewController {

    @IBOutlet weak var headerView: UIView!{
        didSet{
            headerView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    @IBOutlet weak var upperView: UIView!{
        didSet{
            upperView.theme_backgroundColor = "TableCell.BackGroundColor"
            upperView.layer.cornerRadius = 8.0
        }
    }
    
    
    @IBOutlet weak var midView: UIView!{
        didSet{
            midView.theme_backgroundColor = "TableCell.BackGroundColor"
            midView.layer.cornerRadius = 8.0
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
