//
//  ImagePreviewVC.swift
//  Blackpink
//
//  Created by Honglei on 10/6/20.
//

import UIKit
import CloudKit
import AVFoundation

class ImagePreviewVC: UIViewController {
    //Outlet Variables
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var homeScreenPreviewImgVForIpad: UIImageView!
    @IBOutlet var lockScreenPreviewImgVForIpad: UIImageView!
    
    @IBOutlet var lockScreenPreviewImgV: UIImageView!
    @IBOutlet var homeScreenUpperPreviewImgV: UIImageView!
    @IBOutlet var homeScreenLowerPreviewImgV: UIImageView!{
        didSet{
            homeScreenLowerPreviewImgV.layer.cornerRadius = 15
            homeScreenLowerPreviewImgV.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var lockScreenImgV: UIImageView!
    @IBOutlet weak var homeScreenImgV: UIImageView!
    
    // Variables
    var image: UIImage!
    var lockInPreview: Bool = false
    var homeInPreview: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
        addGestureRcgToView()
        addGestureRcgToLockScreen()
        addGestureRcgToHomeScreen()
    }
    
    func initVC(){
        DispatchQueue.main.async {
            self.imageView.image = self.image
        }
    }
    
    func hideButtons(){
        DispatchQueue.main.async {
            self.backBtn.alpha = 0
            self.lockScreenImgV.alpha = 0
            self.homeScreenImgV.alpha = 0
        }
    }
    func showButtons(){
        DispatchQueue.main.async {
            self.backBtn.alpha = 1
            self.lockScreenImgV.alpha = 1
            self.homeScreenImgV.alpha = 1
        }
    }
    
    func addGestureRcgToView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if lockInPreview{
            hideLockScreenPreview()
            lockInPreview.toggle()
        }
        if homeInPreview {
            hideHomeScreenPreview()
            homeInPreview.toggle()
        }
        if backBtn.alpha < 0.5{
            showButtons()
        }
    }
    
    func addGestureRcgToLockScreen(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lockScreenImgViewTapped(tapGestureRecognizer:)))
        lockScreenImgV.isUserInteractionEnabled = true
        lockScreenImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showLockScreenPreview(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            DispatchQueue.main.async {
                self.lockScreenPreviewImgVForIpad.alpha = 1.0
            }
        }else{
            DispatchQueue.main.async {
                self.lockScreenPreviewImgV.alpha = 1.0
            }
        }
    }
    
    func hideLockScreenPreview(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            DispatchQueue.main.async {
                self.lockScreenPreviewImgVForIpad.alpha = 0
            }
        }else{
            DispatchQueue.main.async {
                self.lockScreenPreviewImgV.alpha = 0
            }
        }
    }
    
    @objc func lockScreenImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        lockInPreview = true
        hideButtons()
        showLockScreenPreview()
    }
    
    func addGestureRcgToHomeScreen(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(homeScreenImgViewTapped(tapGestureRecognizer:)))
        homeScreenImgV.isUserInteractionEnabled = true
        homeScreenImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showHomeScreenPreview(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            DispatchQueue.main.async {
                self.homeScreenPreviewImgVForIpad.alpha = 1
            }
        }else{
            DispatchQueue.main.async {
                self.homeScreenUpperPreviewImgV.alpha = 1
                self.homeScreenLowerPreviewImgV.alpha = 1
            }
        }
    }
    
    func hideHomeScreenPreview(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            DispatchQueue.main.async {
                self.homeScreenPreviewImgVForIpad.alpha = 0
            }
        }else{
            DispatchQueue.main.async {
                self.homeScreenUpperPreviewImgV.alpha = 0
                self.homeScreenLowerPreviewImgV.alpha = 0
            }
        }
    }
    
    @objc func homeScreenImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        homeInPreview = true
        hideButtons()
        showHomeScreenPreview()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
