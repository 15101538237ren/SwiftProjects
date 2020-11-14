//
//  UploadWallpaperVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import UIKit
import PopMenu

class UploadWallpaperVC: UIViewController, UITextFieldDelegate {
    
    var wallpaper: UIImage!
    var currentDisplayMode:DisplayMode = .Plain
    
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
    
    @IBOutlet weak var captionTextField: UITextField!{
        didSet{
            captionTextField.textColor = .darkGray
        }
    }
    
    @IBOutlet weak var selectCategoryBtn: UIButton!{
        didSet {
            selectCategoryBtn.layer.cornerRadius = 6.0
            selectCategoryBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var previewImgView: UIImageView!
    
    @IBOutlet weak var submitBtn: UIButton!{
        didSet {
            submitBtn.layer.cornerRadius = 6.0
            submitBtn.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    func initVC(){
        DispatchQueue.main.async {
            self.wallpaperImgView.image = self.wallpaper
        }
        captionTextField.delegate = self
        addGestureRecognizers()
    }
    
    func addGestureRecognizers(){
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        previewImgView.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap2)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        currentDisplayMode = getNextDisplayMode(mode: currentDisplayMode)
        DispatchQueue.main.async { [self] in
            switch currentDisplayMode {
            case .Plain:
                maskImgView.alpha = 0
            case .LockScreen:
                maskImgView.alpha = 1
                maskImgView.image = UIImage(named: "LockScreen")
            case .HomeScreen:
                maskImgView.alpha = 1
                maskImgView.image = UIImage(named: "HomeScreen")
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func presentPopMenu(_ sender: UIButton) {
        let iconWidthHeight:CGFloat = 20
        let popAction = PopMenuDefaultAction(title: "最热壁纸", image: UIImage(named: "heart-fill-icon"), color: UIColor.darkGray)
        let latestAction = PopMenuDefaultAction(title: "最新壁纸", image: UIImage(named: "calendar-icon"), color: UIColor.darkGray)
        let uploadAction = PopMenuDefaultAction(title: "上传壁纸", image: UIImage(named: "upload"), color: UIColor.darkGray)
        
        popAction.iconWidthHeight = iconWidthHeight
        latestAction.iconWidthHeight = iconWidthHeight
        uploadAction.iconWidthHeight = iconWidthHeight
        
        let menuVC = PopMenuViewController(sourceView:sender, actions: [popAction, latestAction, uploadAction])
        menuVC.delegate = self
        menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
        
        menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(red: 128, green: 128, blue: 128, alpha: 1))
        self.present(menuVC, animated: true, completion: nil)
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UploadWallpaperVC: PopMenuViewControllerDelegate {

    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        
    }
}
