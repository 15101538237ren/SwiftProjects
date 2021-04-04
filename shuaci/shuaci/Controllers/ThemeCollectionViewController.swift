//
//  ThemeCollectionViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme

private let reuseIdentifier = "Cell"

class ThemeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    var userId: String!
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        collectionView.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.tintColor = .white
    }
      
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return themes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemeCollectionViewCell
        let theme = themes[indexPath.row]
        cell.themeImageView.image = UIImage(named: theme.background)
        cell.themeNameLabel.text = theme.name
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        
        let theme_category = theme.category
        
        preference.current_theme = theme_category
        
        savePreference(userId: userId, preference: preference)
        mainPanelViewController.update_preference()
        
        ThemeManager.setTheme(plistName: theme_category_to_name[theme.category]!.rawValue, path: .mainBundle)
        
        let info = ["Um_Key_ButtonName" : "\(theme.name)", "Um_Key_SourcePage":"选主题", "Um_Key_UserID" : userId]
        UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
        
        mainPanelViewController.setDefaultWallpaper(theme_category: theme_category)
        mainPanelViewController.getNextWallpaper(category: theme_category)
        self.dismiss(animated: true, completion: nil)
    }

}
