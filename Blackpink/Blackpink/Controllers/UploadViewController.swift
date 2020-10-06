//
//  UploadViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import UIKit
import CloudKit
import PopMenu

class UploadViewController: UIViewController, UINavigationControllerDelegate {
    
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    @IBOutlet weak var uploadBtn: UIButton!{
        didSet{
            uploadBtn.layer.cornerRadius = 10.0
            uploadBtn.layer.masksToBounds = true
            uploadBtn.setTitleColor(BlackPinkBlack, for: .normal)
            uploadBtn.setTitleColor(.lightGray, for: .disabled)
            uploadBtn.layer.borderWidth = 3
            uploadBtn.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet var chooseImgBtn: UIButton!{
        didSet{
            chooseImgBtn.layer.cornerRadius = 10.0
            chooseImgBtn.layer.masksToBounds = true
            chooseImgBtn.setTitleColor(BlackPinkBlack, for: .normal)
            chooseImgBtn.setTitleColor(.lightGray, for: .disabled)
            chooseImgBtn.layer.borderWidth = 3
            chooseImgBtn.layer.borderColor = BlackPinkBlack.cgColor
        }
    }
    
    @IBOutlet var chooseCategoryBtn: UIButton!{
        didSet{
            chooseCategoryBtn.layer.cornerRadius = 10.0
            chooseCategoryBtn.layer.masksToBounds = true
            chooseCategoryBtn.setTitleColor(BlackPinkBlack, for: .normal)
            chooseCategoryBtn.setTitleColor(.lightGray, for: .disabled)
            chooseCategoryBtn.layer.borderWidth = 3
            chooseCategoryBtn.layer.borderColor = BlackPinkBlack.cgColor
        }
    }
    
    @IBOutlet var imgV: UIImageView!{
        didSet{
            imgV.layer.cornerRadius = 10.0
            imgV.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var categoryImgV: UIImageView!{
        didSet {
            categoryImgV.layer.cornerRadius = categoryImgV.layer.frame.width/2.0
            categoryImgV.layer.masksToBounds = true
        }
    }
    
    var imageToUpload: UIImage?
    var currentWallpaperCategory:Int? = nil
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 46.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
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
        addGestureRcgToImageViews()
    }
    
    func addGestureRcgToImageViews(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadPreviewVC))
        imgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func upload(sender: UIButton)
    {
        if imageToUpload == nil{
            let ac = getAlert(title: "Please click [Choose Image] to select image first!", message: "", okText: "OK")
            self.present(ac, animated: true, completion: nil)
            return
        }
        if currentWallpaperCategory == nil{
            let ac = getAlert(title: "Please click [Select Category] to select the category of the wallpaper", message: "!", okText: "OK")
            self.present(ac, animated: true, completion: nil)
            return
        }
        uploadImage(image: imageToUpload!, category: currentWallpaperCategory!)
    }
    
    @IBAction func presentPopMenu(sender: UIButton) {
        let actions = [
            PopMenuDefaultAction(title: "Group", image: UIImage(named: "group")),
            PopMenuDefaultAction(title: "Lisa", image: UIImage(named: "lisa")),
            PopMenuDefaultAction(title: "Jisoo", image: UIImage(named: "jisoo")),
            PopMenuDefaultAction(title: "Rosé", image: UIImage(named: "rose")),
            PopMenuDefaultAction(title: "Jennie", image: UIImage(named: "jennie"))
        ]
        for action in actions{
            action.imageRenderingMode = .alwaysOriginal
            action.iconWidthHeight = 40
        }
        let menuVC = PopMenuViewController(sourceView:categoryImgV, actions: actions)
        menuVC.delegate = self
        let backgroundColor = BlackPinkPink
        menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: backgroundColor)
        self.present(menuVC, animated: true, completion: nil)
    }
    
    @objc func loadPreviewVC() -> Void{
        if imageToUpload != nil{
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let previewVC = mainStoryBoard.instantiateViewController(withIdentifier: "previewVC") as! ImagePreviewVC
            previewVC.image = imageToUpload
            previewVC.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(previewVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func selectImage(sender: UIButton) {
        let photoSourceController = UIAlertController(title: "", message: "Please select wallpaper" , preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library" , style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoSourceController.addAction(photoLibraryAction)
        photoSourceController.addAction(cancelAction)
        present(photoSourceController, animated: true, completion: nil)
    }
    
    func fieldsAllInput() -> Bool{
        if currentWallpaperCategory != nil && imageToUpload != nil{
            return true
        }else{
            return false
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUploadBtn(){
        if fieldsAllInput(){
            uploadBtn.isEnabled = true
            uploadBtn.layer.borderColor = BlackPinkBlack.cgColor
        }else{
            uploadBtn.isEnabled = false
            uploadBtn.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func uploadImage(image:UIImage, category: Int) -> Void {
        let connected = Reachability.isConnectedToNetwork()
        if connected
        {
            
            DispatchQueue.main.async { [self] in
                uploadBtn.isEnabled = false
                chooseImgBtn.isEnabled = false
                chooseCategoryBtn.isEnabled = false
                uploadBtn.layer.borderColor = UIColor.lightGray.cgColor
                chooseImgBtn.layer.borderColor = UIColor.lightGray.cgColor
                chooseCategoryBtn.layer.borderColor = UIColor.lightGray.cgColor
                initActivityIndicator(text: "Uploading")
            }
            
            // Prepare the record to save
            let record = CKRecord(recordType: "Wallpaper")
            record.setValue(category, forKey: "category")
            record.setValue(1, forKey: "issued")
            record.setValue(0, forKey: "likes")

            // Resize the image
            let originalImage = image

            // Write the image to local file for temporary use
            let uuid = UUID().uuidString
            let imageFilePath = NSTemporaryDirectory() + uuid
            let imageFileURL = URL(fileURLWithPath: imageFilePath)
            try? originalImage.jpegData(compressionQuality: 1.0)?.write(to: imageFileURL)

            // Create image asset for upload
            let imageAsset = CKAsset(fileURL: imageFileURL)
            record.setValue(imageAsset, forKey: "image")

            // Get the Public iCloud Database
            let cloudContainer = CKContainer.init(identifier: icloudContainerID)
            let publicDatabase = cloudContainer.publicCloudDatabase
            publicDatabase.save(record, completionHandler: { (record, error) -> Void  in
                // Remove temp file
                
                DispatchQueue.main.async { [self] in
                    if error == nil {
                        stopIndicator()
                        try? FileManager.default.removeItem(at: imageFileURL)
                        let ac = UIAlertController(title: "Upload successful, we will review the quality of the wallpaper and make public ASAP!", message: "", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler:
                            {_ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(ac, animated: true)
                    } else {
                        let ac = UIAlertController(title: "Error", message: "Error in uploading, \(error!.localizedDescription)", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
                
            })
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
}

extension UploadViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            imageToUpload = pickedImage
            DispatchQueue.main.async { [self] in
                imgV.image = imageToUpload
                updateUploadBtn()
            }
        }
    }
}

extension UploadViewController: PopMenuViewControllerDelegate {
    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        currentWallpaperCategory = index + 1
        let category: WallpaperCategory = convertIntToCategory(categoryInt: currentWallpaperCategory!)
        let imageName = getSoloImageNameByCategory(category: category)
        let image = UIImage(named: imageName) ?? UIImage()
        DispatchQueue.main.async { [self] in
            categoryImgV.image = image
            updateUploadBtn()
        }
    }
}
