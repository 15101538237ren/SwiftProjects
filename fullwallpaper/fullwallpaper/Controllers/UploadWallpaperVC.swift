//
//  UploadWallpaperVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import UIKit
import AYPopupPickerView
class UploadWallpaperVC: UIViewController, UITextFieldDelegate {
    
    var wallpaper: UIImage!
    var currentDisplayMode:DisplayMode = .Plain
    let popupPickerView = AYPopupPickerView()
    let rowNamesInPickerView = categories.map { $0.name }
    
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
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        wallpaperImgView.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        maskImgView.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap4)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        currentDisplayMode = getNextDisplayMode(mode: currentDisplayMode)
        print(currentDisplayMode)
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
    
    @IBAction func displayPickerView(sender: UIButton){
        popupPickerView.display(itemTitles: rowNamesInPickerView, doneHandler: {
            let selectedIndex = self.popupPickerView.pickerView.selectedRow(inComponent: 0)
            print(self.rowNamesInPickerView[selectedIndex])
        })
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
