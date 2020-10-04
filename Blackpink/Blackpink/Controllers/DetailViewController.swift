//
//  DetailViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/3/20.
//

import UIKit

class DetailViewController: UIViewController {
    //Outlet Variables
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lockScreenPreviewImgV: UIImageView!
    @IBOutlet var homeScreenUpperPreviewImgV: UIImageView!
    @IBOutlet var homeScreenLowerPreviewImgV: UIImageView!{
        didSet{
            homeScreenLowerPreviewImgV.layer.cornerRadius = 15
            homeScreenLowerPreviewImgV.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var likeImgV: UIImageView!
    @IBOutlet weak var downloadImgV: UIImageView!
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
        addGestureRcgToLike()
        addGestureRcgToDownload()
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
            self.likeImgV.alpha = 0
            self.downloadImgV.alpha = 0
            self.lockScreenImgV.alpha = 0
            self.homeScreenImgV.alpha = 0
        }
    }
    func showButtons(){
        DispatchQueue.main.async {
            self.backBtn.alpha = 1
            self.likeImgV.alpha = 1
            self.downloadImgV.alpha = 1
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
    
    func addGestureRcgToLike(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeImgViewTapped(tapGestureRecognizer:)))
        likeImgV.isUserInteractionEnabled = true
        likeImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func likeImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
    }
    
    func addGestureRcgToDownload(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(downloadImgViewTapped(tapGestureRecognizer:)))
        downloadImgV.isUserInteractionEnabled = true
        downloadImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func downloadImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

    }
    
    func addGestureRcgToLockScreen(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lockScreenImgViewTapped(tapGestureRecognizer:)))
        lockScreenImgV.isUserInteractionEnabled = true
        lockScreenImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showLockScreenPreview(){
        DispatchQueue.main.async {
            self.lockScreenPreviewImgV.alpha = 1.0
        }
    }
    
    func hideLockScreenPreview(){
        DispatchQueue.main.async {
            self.lockScreenPreviewImgV.alpha = 0
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
        DispatchQueue.main.async {
            self.homeScreenUpperPreviewImgV.alpha = 1
            self.homeScreenLowerPreviewImgV.alpha = 1
        }
    }
    
    func hideHomeScreenPreview(){
        DispatchQueue.main.async {
            self.homeScreenUpperPreviewImgV.alpha = 0
            self.homeScreenLowerPreviewImgV.alpha = 0
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
