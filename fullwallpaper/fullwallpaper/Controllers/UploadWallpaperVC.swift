//
//  UploadWallpaperVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import UIKit

class UploadWallpaperVC: UIViewController {
    
    @IBOutlet weak var maskImgView: UIImageView!{
        didSet{
            maskImgView.alpha = 0
            maskImgView.layer.cornerRadius = 6.0
            maskImgView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var wallpaperImgView: UIImageView!{
        didSet{
            wallpaperImgView.layer.cornerRadius = 6.0
            wallpaperImgView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet weak var selectCategoryBtn: UIButton!{
        didSet {
            selectCategoryBtn.layer.cornerRadius = 6.0
            selectCategoryBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var submitBtn: UIButton!{
        didSet {
            submitBtn.layer.cornerRadius = 6.0
            submitBtn.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
