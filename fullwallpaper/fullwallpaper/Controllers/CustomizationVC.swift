//
//  CustomizationVC.swift
//  fullwallpaper
//
//  Created by Honglei on 4/28/21.
//

import UIKit
import SwiftTheme
import CropViewController

class CustomizationVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    private let customizations:[String] = ["经典", "模糊", "小半", "相框"]
    private let customizationImages:[String] = ["center_square", "blurry", "half_screen", "border"]
    private let customizationStyles:[CustomizationStyle] = [.CenterSquare, .Blur, .HalfScreen, .Border]
    private let whRatios:[CGFloat] = [1.0, whRatio, widthsz/(heightsz * 0.618), CGFloat(5.0/6.0)]
    
    var customizationStyleSelected:CustomizationStyle? = nil
    var imagePicker = UIImagePickerController()
    var currentWHRatio: CGFloat = 1.0
    var currentRawImage: UIImage? = nil
    var currentCroppedImage: UIImage? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            currentRawImage = pickedImage
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
                let  cropController = createCropViewController(image: pickedImage, widthHeightRatio: self.currentWHRatio)
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        currentCroppedImage = image
        // 'image' is the newly cropped version of the original image
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let classicalStyleVC = mainStoryBoard.instantiateViewController(withIdentifier: "classicalStyleVC") as! ClassicalStyleVC
        classicalStyleVC.bgImg = currentRawImage
        classicalStyleVC.centerImg = currentCroppedImage
        classicalStyleVC.customizationStyle = customizationStyleSelected!
        classicalStyleVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: nil)
            self.present(classicalStyleVC, animated: true, completion: nil)
        }
    }
    
    func setupCollectionView() {
        collectionView.theme_backgroundColor = "View.BackgroundColor"
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: cellSpacingForCustomization, left: cellSpacingForCustomization, bottom: cellSpacingForCustomization, right: cellSpacingForCustomization)
        layout.minimumInteritemSpacing = cellSpacingForCustomization
        layout.minimumLineSpacing = cellSpacingForCustomization
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customizations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customizationCell", for: indexPath) as! CustomizationCollectionViewCell
        cell.contentView.layer.cornerRadius = 15.0
        cell.contentView.layer.masksToBounds = true
        cell.themeNameLabel.text = customizations[indexPath.row]
        cell.themeImageView.image = UIImage(named: customizationImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRowForCustomization + 1) * cellSpacingForCustomization) / numberOfItemsPerRowForCustomization
        let height = width * cellHeightWidthRatioForCustomization
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentWHRatio = whRatios[indexPath.row]
        customizationStyleSelected = customizationStyles[indexPath.row]
        selectImage()
    }

}
