//
//  ClassicalStyleVC.swift
//  fullwallpaper
//
//  Created by Honglei on 5/8/21.
//

import UIKit

class ClassicalStyleVC: UIViewController {
    
    var bgImg:UIImage!
    var centerImg:UIImage!
    
    @IBOutlet var bgImgView: UIImageView!{
        didSet{
            if let blurredImg = blurImage(usingImage: bgImg, blurAmount: 33.0){
                bgImgView.image = blurredImg
            }else{
                bgImgView.image = bgImg
            }
        }
    }
    @IBOutlet var centerImgView: UIImageView!{
        didSet {
            centerImgView.image = centerImg
            centerImgView.layer.cornerRadius = 12.0
            centerImgView.layer.masksToBounds = true
        }
    }
    @IBOutlet var homeLockImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
