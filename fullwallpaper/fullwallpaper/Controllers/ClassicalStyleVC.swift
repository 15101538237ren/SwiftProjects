//
//  ClassicalStyleVC.swift
//  fullwallpaper
//
//  Created by Honglei on 5/8/21.
//

import UIKit

class ClassicalStyleVC: UIViewController {
    let animationDuration = 1.3
    let cornerRadius:CGFloat = 6
    var bgImg:UIImage!
    var centerImg:UIImage!
    var previewStatus: DisplayMode = .Plain
    var panStartPoint: CGFloat = 0
    var blurIsActive: Bool = false
    var maxBlurAmount: CGFloat = 100.0
    var previousBlurAmount:CGFloat = 30.0
    @IBOutlet var tapGestureRecognizer1: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer2: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer3: UITapGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet var viewToSave: UIView!
    @IBOutlet var bgImgView: UIImageView!{
        didSet{
            if let blurredImg = blurImage(usingImage: bgImg, blurAmount: previousBlurAmount){
                bgImgView.image = blurredImg
            }else{
                bgImgView.image = bgImg
            }
        }
    }
    
    @IBOutlet var centerImgView: UIImageView!{
        didSet {
            centerImgView.image = centerImg
            centerImgView.layer.cornerRadius = 12.0
            centerImgView.layer.masksToBounds = true
        }
    }
    @IBOutlet var homeLockImgView: UIImageView!
    @IBOutlet var btnGroupView: UIView!
    @IBOutlet var blurLabel: UILabel!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var blurBtn: UIButton!
    @IBOutlet var changeBgBtn: UIButton!
    @IBOutlet var downloadImgBtn: UIButton!
    @IBOutlet var closeBlurBtn: UIButton!
    @IBOutlet var checkBlurBtn: UIButton!
    
    @IBOutlet var progressView: UIProgressView!{
        didSet{
            // Set the rounded edge for the outer bar
            let progress = Float(previousBlurAmount/maxBlurAmount)
            progressView.setProgress(progress, animated: false)
            progressView.layer.cornerRadius = cornerRadius
            progressView.clipsToBounds = true
            progressView.layer.sublayers![1].cornerRadius = cornerRadius
            progressView.subviews[1].clipsToBounds = true
            addBlurBgToProgressView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addBlurBgToProgressView(){
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = progressView.bounds
        blurEffectView.layer.cornerRadius = cornerRadius
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.8
        progressView.insertSubview(blurEffectView, at: 0)
    }
    
    
    @IBAction func onBlurProgressDrag(gestureRecognizer: UIPanGestureRecognizer) {
        let progress: Float = Float(gestureRecognizer.location(in: progressView).x/progressView.width)
        let blurAmount = CGFloat(CGFloat(progress) * maxBlurAmount)
        DispatchQueue.main.async { [self] in
            progressView.setProgress(progress, animated: true)
            if let blurredImg = blurImage(usingImage: bgImg, blurAmount: blurAmount){
                bgImgView.image = blurredImg
            }
        }
        
    }
    
    @IBAction func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        previewStatus = (previewStatus == .Plain) ? .LockScreen : .Plain
        
        switch previewStatus {
        case .Plain:
            showViews(show: true)
        default:
            showViews(show: false)
        }
    }
    
    func showViews(show:Bool){
        
        DispatchQueue.main.async { [self] in
            self.btnGroupView.alpha = show ? 1 : 0
            self.homeLockImgView.alpha = show ? 0 : 1
        }
    }
    
    @IBAction func showBlurProgress(_ sender: UIButton) {
        blurIsActive = true
        updateBtnGroupVisibility()
    }
    
    @IBAction func cancelBlurProgress(_ sender: UIButton) {
        let progress:Float = Float(CGFloat(previousBlurAmount / maxBlurAmount))
        DispatchQueue.main.async { [self] in
            progressView.setProgress(progress, animated: true)
            if let blurredImg = blurImage(usingImage: bgImg, blurAmount: previousBlurAmount){
                bgImgView.image = blurredImg
            }
        }
        blurIsActive = false
        updateBtnGroupVisibility()
    }
    
    @IBAction func dismissBlurProgress(_ sender: UIButton) {
        previousBlurAmount = CGFloat(CGFloat(progressView.progress) * maxBlurAmount)
        blurIsActive = false
        updateBtnGroupVisibility()
    }
    
    func updateBtnGroupVisibility(){
        backBtn.alpha = blurIsActive ? 0 : 1
        blurBtn.alpha = blurIsActive ? 0 : 1
        changeBgBtn.alpha = blurIsActive ? 0 : 1
        downloadImgBtn.alpha = blurIsActive ? 0 : 1
        progressView.alpha = blurIsActive ? 1 : 0
        closeBlurBtn.alpha = blurIsActive ? 1 : 0
        checkBlurBtn.alpha = blurIsActive ? 1 : 0
        blurLabel.alpha = blurIsActive ? 1 : 0
        bgImgView.isUserInteractionEnabled = !blurIsActive
        centerImgView.isUserInteractionEnabled = !blurIsActive
        homeLockImgView.isUserInteractionEnabled = !blurIsActive
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        let image = viewToSave.asImage()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
                self.view.makeToast("出现错误: \(error.localizedDescription)", duration: 1.0, position: .center)
        }
        else{
            presentAlertForSaveSuccess()
        }
    }
    
    func presentAlertForSaveSuccess(){
        let alertController = UIAlertController(title: "保存成功", message: "是否前往相册查看?", preferredStyle: .alert)
        
        let goAlbumAction = UIAlertAction(title: "前往相册", style: .default){ _ in
            UIApplication.shared.open(URL(string:"photos-redirect://")!)
         }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(goAlbumAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
