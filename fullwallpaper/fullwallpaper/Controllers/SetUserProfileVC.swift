//
//  SetUserProfileVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/3/20.
//

import UIKit
import CropViewController

class SetUserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet var userProfileImgView: UIImageView!{
        didSet {
            userProfileImgView.layer.cornerRadius = userProfileImgView.layer.frame.width/2.0
            userProfileImgView.layer.masksToBounds = true
        }
    }
    @IBOutlet var displayNameTextField: UITextField!{
        didSet{
            displayNameTextField.attributedPlaceholder = NSAttributedString(string: "显示名称",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet var submitBtn: UIButton!{
        didSet {
            submitBtn.layer.cornerRadius = 9.0
            submitBtn.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    func initVC(){
        self.displayNameTextField.becomeFirstResponder()
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
            userProfileImgView.image = image
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
