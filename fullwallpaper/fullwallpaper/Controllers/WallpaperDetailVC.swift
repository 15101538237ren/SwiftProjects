//
//  WallpaperDetailVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import AVFoundation
import Nuke

class WallpaperDetailVC: UIViewController {

    //Outlet Variables
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lockScreenPreviewImgV: UIImageView!
    @IBOutlet var homeScreenPreviewImgV: UIImageView!
    @IBOutlet weak var largeHeartImgV: UIImageView!
    @IBOutlet weak var likeImgV: UIImageView!
    @IBOutlet weak var downloadImgV: UIImageView!
    @IBOutlet weak var lockScreenImgV: UIImageView!
    @IBOutlet weak var homeScreenImgV: UIImageView!
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.layer.cornerRadius = 15.0
            dimUIView.layer.masksToBounds = true
            dimUIView.alpha = dimUIViewAlpha
            dimUIView.backgroundColor = .black
        }
    }
    
    // Variables
    var imageUrl: URL!
    var lockInPreview: Bool = false
    var homeInPreview: Bool = false
    var liked: Bool = false
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    let scaleForAnimation: CGFloat = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        Nuke.loadImage(with: imageUrl, options: wallpaperLoadingOptions, into: imageView)
        addGestureRcg()
    }
    
    func addGestureRcg(){
        addGestureRcgToView()
        addGestureRcgToLike()
        addGestureRcgToDownload()
        addGestureRcgToLockScreen()
        addGestureRcgToHomeScreen()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            
            if viewTranslation.y > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    func hideButtons(){
        DispatchQueue.main.async {
            self.backBtn.alpha = 0
            self.likeImgV.alpha = 0
            self.downloadImgV.alpha = 0
            self.lockScreenImgV.alpha = 0
            self.homeScreenImgV.alpha = 0
            self.dimUIView.alpha = 0
        }
    }
    
    
    func showButtons(){
        DispatchQueue.main.async {
            self.backBtn.alpha = 1
            self.likeImgV.alpha = 1
            self.downloadImgV.alpha = 1
            self.lockScreenImgV.alpha = 1
            self.homeScreenImgV.alpha = 1
            self.dimUIView.alpha = dimUIViewAlpha
        }
    }
    
    func addGestureRcgToView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addGestureRcgToLike(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeImgViewTapped(tapGestureRecognizer:)))
        likeImgV.isUserInteractionEnabled = true
        likeImgV.addGestureRecognizer(tapGestureRecognizer)
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
        if backBtn.alpha < 0.05{
            showButtons()
        }
    }
    
    func toggleLikeBtn() {
        liked.toggle()
        let tmp_image = liked ? UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon") : UIImage(systemName: "heart") ?? UIImage(named: "heart-icon")
        likeImgV.image = tmp_image
        largeHeartImgV.image = tmp_image
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.largeHeartImgV.alpha = 1.0
            self.largeHeartImgV.transform = self.largeHeartImgV.transform.scaledBy(x: self.scaleForAnimation, y: self.scaleForAnimation)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.largeHeartImgV.alpha = 0.0
                    self.largeHeartImgV.transform = .identity
                })
        })
    }
    
    @objc func likeImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        toggleLikeBtn()
    }
    
    func addGestureRcgToDownload(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(downloadImgViewTapped(tapGestureRecognizer:)))
        downloadImgV.isUserInteractionEnabled = true
        downloadImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func downloadImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let image = imageView.image{
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
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
            self.homeScreenPreviewImgV.alpha = 1
        }
    }
    
    func hideHomeScreenPreview(){
        DispatchQueue.main.async {
            self.homeScreenPreviewImgV.alpha = 0
        }
    }
    
    @objc func homeScreenImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        homeInPreview = true
        hideButtons()
        showHomeScreenPreview()
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "出现错误: \(error.localizedDescription)", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        else{
            let ac = UIAlertController(title: "保存成功!", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
