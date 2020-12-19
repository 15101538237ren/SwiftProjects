//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit

class VIPBenefitsVC: UIViewController {
    
    //Variables
    
    
    @IBOutlet weak var headerView: UIView!{
        didSet{
            headerView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    @IBOutlet weak var upperView: UIView!{
        didSet{
            upperView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var midView: UIView!{
        didSet{
            midView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var bottomView: UIView!{
        didSet{
            bottomView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet var upperDimUIView: UIView!{
        didSet{
            upperDimUIView.theme_alpha = "DimView.Alpha"
        }
    }
    
    @IBOutlet var bottomDimUIView: UIView!{
        didSet{
            bottomDimUIView.theme_alpha = "DimView.Alpha"
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var vipLabel: UILabel!{
        didSet{
            vipLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
        }
    }
    override func viewDidLoad() {
        view.theme_backgroundColor = "View.BackgroundColor"
        super.viewDidLoad()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
