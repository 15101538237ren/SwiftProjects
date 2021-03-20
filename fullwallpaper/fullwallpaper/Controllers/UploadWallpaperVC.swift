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
    let rowNamesInPickerView = categories.map { $0.name }
    var hideSelectCategory: Bool!
    var currentCategory:String? = nil
    var categoryCN: String? = nil
    var collection: LCObject? = nil
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.theme_alpha = "DimView.Alpha"
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
        }
    }
    
    @IBOutlet weak var selectCategoryBtn: UIButton!{
        didSet {
            selectCategoryBtn.theme_backgroundColor = "TableCell.BackGroundColor"
            selectCategoryBtn.theme_setTitleColor("TableCell.TextColor", forState: .normal)
            selectCategoryBtn.layer.cornerRadius = 6.0
            selectCategoryBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var previewImgView: UIImageView!
    
    @IBOutlet weak var submitBtn: UIButton!{
        didSet {
            submitBtn.theme_backgroundColor = "TableCell.BackGroundColor"
            submitBtn.theme_setTitleColor("TableCell.TextColor", forState: .normal)
            submitBtn.layer.cornerRadius = 6.0
            submitBtn.layer.masksToBounds = true
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
        
    }
    
    func checkHint(){
        var hintNum:Int = 0
        let uploadHintKey:String = "UploadVCHint"
        if isKeyPresentInUserDefaults(key: uploadHintKey){
            hintNum = UserDefaults.standard.integer(forKey: uploadHintKey)
        }
        if hintNum < 3 {
            self.view.makeToast("点击图片可以切换预览效果哦~😊", duration: 1.0, position: .center)
        }
        
        UserDefaults.standard.set(hintNum + 1, forKey: uploadHintKey)
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
            self.view.makeToast("请您添加壁纸描述以方便他人检索!", duration: 1.0, position: .center)
            return
        }
        
        let categoryRequiredValidator = Validator.isEmpty(nilResponse: true).apply(self.currentCategory)
        if categoryRequiredValidator{
            self.view.makeToast("请您选择壁纸类别!", duration: 1.0, position: .center)
            return
        }
        
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            DispatchQueue.main.async {
                self.setElements(enable: false)
                self.initActivityIndicator(text: "上传中...")
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
                                                let alertController = UIAlertController(title: "上传成功!", message: "感谢您的贡献，我们将审核壁纸质量，通过审核后您上传的壁纸将在【设置】-【个人资料】-【我上传的】中显示", preferredStyle: .alert)
                                                let okayAction = UIAlertAction(title: "好", style: .cancel, handler: {_ in
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
                                            
                                            self.view.makeToast("上传失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
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
                                    self.presentAlertInView(title: "上传失败，请稍后重试!", message: "\(error.reason?.stringValue ?? "出现错误")", okText: "好")
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
}
