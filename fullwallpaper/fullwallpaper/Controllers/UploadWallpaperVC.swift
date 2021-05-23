//
//  UploadWallpaperVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import UIKit
import AYPopupPickerView
import SwiftValidators
import LeanCloud

class UploadWallpaperVC: UIViewController, UITextFieldDelegate {
    
    var wallpaper: UIImage!
    var currentDisplayMode:DisplayMode = .Plain
    let popupPickerView = AYPopupPickerView()
    
    var rowNamesInPickerView:[String] = []
    var hideSelectCategory: Bool!
    var currentCategory:String? = nil
    var categoryCN: String? = nil
    var collection: LCObject? = nil
    var uploadType: UploadType!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.theme_alpha = "DimView.Alpha"
        }
    }
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = uploadWallpaperText
            if english{
                titleLabel.font = UIFont(name: "Clicker Script", size: 25.0)
            }
        }
    }
    
    @IBOutlet weak var headerView: UIView!{
        didSet{
            headerView.theme_backgroundColor = "View.BackgroundColor"
        }
    }
    
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
            captionTextField.placeholder = wallpaperCaptionPlaceHolderText
        }
    }
    
    @IBOutlet weak var selectCategoryBtn: UIButton!{
        didSet {
            selectCategoryBtn.theme_backgroundColor = "TableCell.BackGroundColor"
            selectCategoryBtn.theme_setTitleColor("TableCell.TextColor", forState: .normal)
            selectCategoryBtn.layer.cornerRadius = 6.0
            selectCategoryBtn.layer.masksToBounds = true
            selectCategoryBtn.setTitle(selectCategoryText, for: .normal)
        }
    }
    
    @IBOutlet weak var previewImgView: UIImageView!
    
    @IBOutlet weak var submitBtn: UIButton!{
        didSet {
            submitBtn.theme_backgroundColor = "TableCell.BackGroundColor"
            submitBtn.theme_setTitleColor("TableCell.TextColor", forState: .normal)
            submitBtn.layer.cornerRadius = 6.0
            submitBtn.layer.masksToBounds = true
            submitBtn.setTitle(ensureSubmitText, for: .normal)
        }
    }
    
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 60.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 16, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var info = ["Um_Key_PageName": "进入上传页"] as [String : Any]
        if let user = LCApplication.default.currentUser{
            let userId = user.objectId!.stringValue!
            info["Um_Key_UserID"] = userId
        }
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    func initVC(){
        view.theme_backgroundColor = "View.BackgroundColor"
        if let _ = self.wallpaper{
            DispatchQueue.main.async {
                self.wallpaperImgView.image = self.wallpaper
            }
        }
        
        if hideSelectCategory{
            self.selectCategoryBtn.removeFromSuperview()
        }else{
            if let _ = self.currentCategory{
                
                DispatchQueue.main.async {
                    self.selectCategoryBtn.isEnabled = false
                    self.selectCategoryBtn.setTitle(self.categoryCN, for: .disabled)
                    self.selectCategoryBtn.setTitleColor(UIColor.darkGray, for: .disabled)
                }
            }
        }
        
        captionTextField.delegate = self
        addGestureRecognizers()
        checkHint()
        rowNamesInPickerView = english ? categories.map { $0.eng } : categories.map { $0.name }
    }
    
    func checkHint(){
        if uploadType == .FROM_CATEGORY{
            let categoryName:String = english ? currentCategory! : categoryCN!
            self.view.makeToast("\(makeSureWPRightCategoryText) : \(categoryName)", duration: 3.0, position: .center)
        }else if uploadType == .FROM_COLLECTION{
            let attrName:String = english ? "enName": "name"
            let collectionName:String = collection!.get(attrName)!.stringValue!
            self.view.makeToast("\(makeSureWPRightCollectionText) :  \(collectionName)", duration: 3.0, position: .center)
        }else{
            var hintNum:Int = 0
            let uploadHintKey:String = "UploadVCHint"
            if isKeyPresentInUserDefaults(key: uploadHintKey){
                hintNum = UserDefaults.standard.integer(forKey: uploadHintKey)
            }
            if hintNum < 3 {
                self.view.makeToast(clickForPreviewText, duration: 1.0, position: .center)
            }
            UserDefaults.standard.set(hintNum + 1, forKey: uploadHintKey)
        }
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
            if categories.count > selectedIndex{
                self.currentCategory = categories[selectedIndex].eng
                DispatchQueue.main.async {
                    self.selectCategoryBtn.setTitle(self.rowNamesInPickerView[selectedIndex], for: .normal)
                    self.selectCategoryBtn.setTitleColor(UIColor.darkGray, for: .normal)
                }
            }else{
                loadCategories(completion: {
                    self.currentCategory = categories[selectedIndex].eng
                    DispatchQueue.main.async {
                        self.selectCategoryBtn.setTitle(self.rowNamesInPickerView[selectedIndex], for: .normal)
                        self.selectCategoryBtn.setTitleColor(UIColor.darkGray, for: .normal)
                    }
                })
            }
            
            
        })
    }
    
    func presentAlertInView(title: String, message: String, okText: String){
        let alertController = presentAlert(title: title, message: message, okText: okText)
        self.present(alertController, animated: true)
    }
    
    func setElements(enable: Bool){
        self.backBtn.isUserInteractionEnabled = enable
        self.view.isUserInteractionEnabled = enable
        if !hideSelectCategory{
            self.selectCategoryBtn.isUserInteractionEnabled = enable
        }
        self.captionTextField.isUserInteractionEnabled = enable
        self.submitBtn.isUserInteractionEnabled = enable
    }
    
    @IBAction func uploadWallpaper(_ sender: UIButton) {
        
        let titleEmptyValidator = Validator.isEmpty(nilResponse: true).apply(captionTextField.text)
        if titleEmptyValidator{
            self.view.makeToast(addedCaptionText, duration: 1.0, position: .center)
            return
        }
        
        let categoryRequiredValidator = Validator.isEmpty(nilResponse: true).apply(self.currentCategory)
        if categoryRequiredValidator{
            self.view.makeToast(addedCategoryText, duration: 1.0, position: .center)
            return
        }
        
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            DispatchQueue.main.async {
                self.setElements(enable: false)
                self.initActivityIndicator(text: uploadingText)
            }
            let caption: String = self.captionTextField.text!
            let imageData: Data = self.wallpaper!.jpegData(compressionQuality: 1.0)!
            DispatchQueue.global(qos: .background).async {
            do {
                if let user = LCApplication.default.currentUser
                {
                    do {
                        // 构建对象
                        
                        let wallpaperObj = LCObject(className: "Wallpaper")
                        
                        // 为属性赋值
                        try wallpaperObj.set("caption", value: caption)
                        try wallpaperObj.set("category", value: self.currentCategory!)
                        try wallpaperObj.set("likes", value: 0)
                        try wallpaperObj.set("status", value: 0)
                        try wallpaperObj.set("uploader", value: user)
                        if let collectionObj = self.collection{
                            try wallpaperObj.set("dependent", value: collectionObj)
                        }
                        
                        let file = LCFile(payload: .data(data: imageData))
                        if let _ =  file.get("name")?.stringValue{
                            
                        }else{
                            do{
                                try file.set("name", value: caption)
                            }catch{
                                print("无法设置文件名称")
                            }
                        }
                        _ = file.save { result in
                            switch result {
                            case .success:
                                // 将对象保存到云端
                                do {
                                    try wallpaperObj.set("img", value: file)
                                    _ = wallpaperObj.save { result in
                                        switch result {
                                        case .success:
                                            DispatchQueue.main.async {
                                                self.stopIndicator()
                                                let alertController = UIAlertController(title: uploadSucessText, message: uploadSucessDetailText, preferredStyle: .alert)
                                                let okayAction = UIAlertAction(title: OkTxt, style: .cancel, handler: {_ in
                                                    DispatchQueue.main.async {
                                                        self.dismiss(animated: true, completion: nil)
                                                    }
                                                })
                                                alertController.addAction(okayAction)
                                                self.present(alertController, animated: true)
                                            }
                                        case .failure(error: let error):
                                            self.stopIndicator()
                                            // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                                            
                                            self.view.makeToast("\(uploadFailedText)\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                                            self.setElements(enable: true)
                                        }
                                    }
                                }catch {
                                    print(error)
                                }
                                
                            case .failure(error: let error):
                                // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                                DispatchQueue.main.async {
                                    self.stopIndicator()
                                    self.presentAlertInView(title: uploadFailedText, message: "\(error.reason?.stringValue ?? errorText)", okText: OkTxt)
                                    self.setElements(enable: true)
                                }
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                }
            }}
            
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
        
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            setTheme(theme: .day)
        } else {
            setTheme(theme: .night)
        }
    }
}
