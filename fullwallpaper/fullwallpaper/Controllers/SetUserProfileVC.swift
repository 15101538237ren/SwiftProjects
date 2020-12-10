//
//  SetUserProfileVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/3/20.
//

import UIKit
import CropViewController
import LeanCloud

class SetUserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    var settingVC: SettingVC!
    var imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? = nil
    private var displayName: String = ""
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var userProfileImgView: UIImageView!{
        didSet {
            if let image = selectedImage{
                userProfileImgView.image = image
            }else{
                userProfileImgView.image = UIImage(named: "user_profile") ?? UIImage()
            }
            userProfileImgView.layer.cornerRadius = userProfileImgView.layer.frame.width/2.0
            userProfileImgView.layer.masksToBounds = true
        }
    }
    @IBOutlet var displayNameTextField: UITextField!{
        didSet{
            displayNameTextField.attributedPlaceholder = NSAttributedString(string: "输入显示名称",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet var submitBtn: UIButton!{
        didSet {
            submitBtn.backgroundColor = .lightGray
            submitBtn.isEnabled = false
            submitBtn.layer.cornerRadius = 9.0
            submitBtn.layer.masksToBounds = true
        }
    }
    
    func detectBtnEnable()
    {
        DispatchQueue.main.async { [self] in
            if selectedImage != nil && !displayName.isEmpty{
                submitBtn.backgroundColor = .systemGreen
                submitBtn.isEnabled = true
            }else{
                submitBtn.backgroundColor = .lightGray
                submitBtn.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    func initVC(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        addRcgToUserProfileImgView()
    }
    
    func addRcgToUserProfileImgView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage(tapGestureRecognizer:)))
        userProfileImgView.isUserInteractionEnabled = true
        userProfileImgView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func selectImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async { [self] in
                picker.dismiss(animated: true, completion: nil)
                
                let targetLength:CGFloat = view.bounds.width * UIScreen.main.scale
                
                let leftPosition = (pickedImage.size.width * pickedImage.scale - targetLength)/2.0
                let topPosition = (pickedImage.size.height * pickedImage.scale - targetLength)/2.0
                let cropController = CropViewController(image: pickedImage)
                cropController.title = "「缩放」或「拖拽」来调整"
                cropController.doneButtonTitle = "确定"
                cropController.cancelButtonTitle = "取消"
                cropController.imageCropFrame = CGRect(x: leftPosition, y: topPosition, width: targetLength, height: targetLength)
                cropController.aspectRatioPreset = .presetSquare
                cropController.rotateButtonsHidden = true
                cropController.rotateClockwiseButtonHidden = true
                cropController.resetButtonHidden = true
                cropController.aspectRatioLockEnabled = true
                cropController.resetAspectRatioEnabled = false
                cropController.aspectRatioPickerButtonHidden = true
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [self] in
            selectedImage = image
            userProfileImgView.image = selectedImage
            detectBtnEnable()
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func setElements(enable: Bool){
        self.view.isUserInteractionEnabled = enable
        self.backBtn.isUserInteractionEnabled = enable
        self.displayNameTextField.isUserInteractionEnabled = enable
        self.submitBtn.isUserInteractionEnabled = enable
    }
    
    @IBAction func setProfile(sender: UIButton){
        if !displayName.isEmpty{
            if let image = self.selectedImage{
                if let resizedImage = image.resizeWithWidth(width: 200){
                    let imageData: Data = resizedImage.jpegData(compressionQuality: 1.0)!
                    if let user = LCApplication.default.currentUser {
                        DispatchQueue.main.async {
                            self.setElements(enable: false)
                            initIndicator(view: self.view)
                        }
                        DispatchQueue.global(qos: .background).async {
                            do {
                                let file = LCFile(payload: .data(data: imageData))
                                _ = file.save { result in
                                    switch result {
                                    case .success:
                                        // 将对象保存到云端
                                        do {
                                            let name = self.displayName
                                            try user.set("avatar", value: file)
                                            try user.set("name", value: name)
                                            _ = user.save { result in
                                                stopIndicator()
                                                switch result {
                                                case .success:
                                                    self.dismiss(animated: true, completion: {
                                                        self.settingVC.setDisplayNameAndUpdate(name: name)
                                                    })
                                                case .failure(error: let error):
                                                    self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                                                    self.setElements(enable: true)
                                                }
                                            }
                                        }catch {
                                            stopIndicator()
                                            self.setElements(enable: true)
                                            self.view.makeToast("设置失败，请稍后重试!", duration: 1.2, position: .center)
                                        }
                                        
                                    case .failure(error: let error):
                                        DispatchQueue.main.async {
                                            stopIndicator()
                                            self.setElements(enable: true)
                                            self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func inputTextChanged(_ sender: UITextField) {
        self.displayName = sender.text ?? ""
        detectBtnEnable()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
