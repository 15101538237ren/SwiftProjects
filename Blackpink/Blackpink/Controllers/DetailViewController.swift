//
//  DetailViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/3/20.
//

import UIKit
import CloudKit
import AVFoundation

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
    @IBOutlet weak var largeHeartImgV: UIImageView!
    @IBOutlet weak var likeImgV: UIImageView!
    @IBOutlet weak var downloadImgV: UIImageView!
    @IBOutlet weak var lockScreenImgV: UIImageView!
    @IBOutlet weak var homeScreenImgV: UIImageView!
    
    // Variables
    var image: UIImage!
    var record: CKRecord!
    var db: CKDatabase!
    var lockInPreview: Bool = false
    var homeInPreview: Bool = false
    var liked: Bool = false
    var reviewFuncCalled: Bool = false
    
    let likedRecordIds:[String] = getLikedRecordIds()
    let scaleForAnimation: CGFloat = 2
    
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
            if self.likedRecordIds.contains(self.record.recordID.recordName){
                self.likeImgV.image = UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon")
                self.liked = true
            }
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
        if backBtn.alpha < 0.05{
            showButtons()
        }
    }
    
    func addGestureRcgToLike(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeImgViewTapped(tapGestureRecognizer:)))
        likeImgV.isUserInteractionEnabled = true
        likeImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func toggleLikeBtn() {
        liked.toggle()
        likeChangedRecordId = record.recordID.recordName
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
        
        if liked{
            addLikedRecordId(recordName: record.recordID.recordName)
        }else{
            removeLikedRecordId(recordName: record.recordID.recordName)
        }
        if !reviewFuncCalled{
            AppStoreReviewManager.requestReviewIfAppropriate()
            reviewFuncCalled = true
        }
    }
    
    @objc func likeImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let offset:Int = liked ? -1 : 1
        if let likes: Int = record.object(forKey: "likes") as? Int{
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                record["likes"] = likes + offset as CKRecordValue
                db.save(record) { record, error in
                        DispatchQueue.main.async {
                            if error == nil {
                                self.toggleLikeBtn()
                            } else {
                                let ac = UIAlertController(title: "Error", message: "Error for like, \(error!.localizedDescription)", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                            }
                        }
                    }
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
        }
        
    }
    
    func addGestureRcgToDownload(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(downloadImgViewTapped(tapGestureRecognizer:)))
        downloadImgV.isUserInteractionEnabled = true
        downloadImgV.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func downloadImgViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        if !reviewFuncCalled{
            AppStoreReviewManager.requestReviewIfAppropriate()
            reviewFuncCalled = true
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
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "Error: \(error.localizedDescription)", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        else{
            let ac = UIAlertController(title: "Saved Successful!", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
