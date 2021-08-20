//
//  ThemeCollectionViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme
import LeanCloud

private let reuseIdentifier = "Cell"

class ThemeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barTitleLabel: UILabel!
    
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    var currentUser: LCUser!
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
        cell.proBtn.alpha = theme.isPro ? 1 : 0
        cell.themeImageView.image = UIImage(named: theme.background)
        cell.themeNameLabel.text = theme.name
        cell.backgroundColor = .clear
        return cell
    }
    
    func loadMembershipVC(hasTrialed: Bool, reason: FailedVerifyReason, reasonToShow: ShowMembershipReason){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let membershipVC = mainStoryBoard.instantiateViewController(withIdentifier: "membershipVC") as! MembershipVC
        membershipVC.modalPresentationStyle = .overCurrentContext
        membershipVC.currentUser = currentUser
        membershipVC.hasFreeTrialed = hasTrialed
        membershipVC.mainPanelViewController = mainPanelViewController
        membershipVC.FailedReason = reason
        membershipVC.ReasonForShow = reasonToShow
        DispatchQueue.main.async {
            self.present(membershipVC, animated: true, completion: nil)
        }
    }
    
    func changeIntoTheme(theme: Theme){
        let theme_category = theme.category
        preference.current_theme = theme_category
        
        savePreference(userId: currentUser.objectId!.stringValue!, preference: preference)
        mainPanelViewController.update_preference()
        
        ThemeManager.setTheme(plistName: theme_category_to_name[theme.category]!.rawValue, path: .mainBundle)
        
        let info = ["Um_Key_ButtonName" : "\(theme.name)", "Um_Key_SourcePage":"选主题", "Um_Key_UserID" : currentUser.objectId!.stringValue!]
        UMAnalyticsSwift.event(eventId: "Um_Event_ModularClick", attributes: info)
        
        mainPanelViewController.setDefaultWallpaper(theme_category: theme_category)
        mainPanelViewController.getNextWallpaper(category: theme_category)
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        
        if theme.isPro{
            initIndicator(view: self.view)
            checkIfVIPSubsciptionValid(successCompletion: { [self] in
                stopIndicator()
                changeIntoTheme(theme: theme)
            }, failedCompletion: { [self] reason in
                stopIndicator()
                if reason == .notPurchasedNewUser{
                    loadMembershipVC(hasTrialed: false, reason: reason, reasonToShow: .PRO_THEME)
                }else{
                    loadMembershipVC(hasTrialed: true, reason: reason, reasonToShow: .PRO_THEME)
                }
            })
        }else{
            changeIntoTheme(theme: theme)
        }
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if let currentUser = LCApplication.default.currentUser {
            var pref = loadPreference(userId: currentUser.objectId!.stringValue!)
            if traitCollection.userInterfaceStyle == .dark{
                pref.dark_mode = true
            }else{
                pref.dark_mode = false
            }
            savePreference(userId: currentUser.objectId!.stringValue!, preference: pref)
            mainPanelViewController.update_preference()
            mainPanelViewController.loadWallpaper(force: true)
            if pref.dark_mode{
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: theme_category_to_name[pref.current_theme]!.rawValue, path: .mainBundle)
            }
        }
    }
}
