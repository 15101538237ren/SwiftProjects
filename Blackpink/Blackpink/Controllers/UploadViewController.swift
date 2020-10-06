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
    
    @IBOutlet weak var uploadBtnV: UIImageView!
    @IBOutlet var chooseImgV: UIImageView!{
        didSet{
            chooseImgV.layer.cornerRadius = 10.0
            chooseImgV.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var chooseCategoryImgV: UIImageView!{
        didSet{
            chooseCategoryImgV.layer.cornerRadius = 10.0
            chooseCategoryImgV.layer.masksToBounds = true
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRcgToImageViews()
    }
    
    func addGestureRcgToImageViews(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImgVTapped(tapGestureRecognizer:)))
        chooseImgV.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(presentPopMenu))
        chooseCategoryImgV.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(loadPreviewVC))
        imgV.addGestureRecognizer(tapGestureRecognizer3)
        
        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(upload))
        uploadBtnV.addGestureRecognizer(tapGestureRecognizer4)
        
    }
    
    @objc func chooseImgVTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        selectImage()
    }
    
    @objc func upload()
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
    
    @objc func presentPopMenu() {
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
    
    func selectImage() {
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
    
    func uploadImage(image:UIImage, category: Int) -> Void {
        let connected = Reachability.isConnectedToNetwork()
        if connected
        {
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
                
                DispatchQueue.main.async {
                    if error == nil {
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
                if fieldsAllInput(){
                    uploadBtnV.tintColor = BlackPinkBlack
                }
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
            if fieldsAllInput(){
                uploadBtnV.tintColor = BlackPinkBlack
            }
        }
    }
}
