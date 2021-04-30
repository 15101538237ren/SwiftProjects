//
//  CustomizationVC.swift
//  fullwallpaper
//
//  Created by Honglei on 4/28/21.
//

import UIKit
import SwiftTheme

class CustomizationVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    private let customizations:[String] = ["经典", "模糊", "小半", "相框"]
    private let customizationImages:[String] = ["center_square", "blurry", "half_screen", "border"]
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
    }

}
