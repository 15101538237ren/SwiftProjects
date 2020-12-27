//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit

class VIPBenefitsVC: UIViewController {
    
    //Variables
    var showHint: Bool = false
    
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
            upperDimUIView.theme_alpha = "VIPPageDimView.Alpha"
        }
    }
    
    @IBOutlet var bottomDimUIView: UIView!{
        didSet{
            bottomDimUIView.theme_alpha = "VIPPageDimView.Alpha"
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
    
    func checkHint(){
        var hintNum:Int = 0
        let uploadHintKey:String = "ProWallpaperHint"
        if isKeyPresentInUserDefaults(key: uploadHintKey){
            hintNum = UserDefaults.standard.integer(forKey: uploadHintKey)
        }
        if hintNum < 3 {
            self.view.makeToast("这是一张会员专属壁纸哦~", duration: 1.0, position: .center)
        }
        
        UserDefaults.standard.set(hintNum + 1, forKey: uploadHintKey)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "View.BackgroundColor"
        super.viewDidLoad()
        if showHint{
            checkHint()
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
