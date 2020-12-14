//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit

class VIPBenefitsVC: UIViewController {
    
    //Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
