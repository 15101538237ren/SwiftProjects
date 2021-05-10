//
//  ClassicalStyleVC.swift
//  fullwallpaper
//
//  Created by Honglei on 5/8/21.
//

import UIKit
import IGColorPicker

class ClassicalStyleVC: UIViewController {
    // MARK: - Constants
    let animationDuration = 1.3
    let cornerRadius:CGFloat = 6
    let minimumLineSpacing:CGFloat = 4
    let minimumInteritemSpacing:CGFloat = 4
    let widthForColorCell:CGFloat = 25
    
    // MARK: - Variables
    var bgImg:UIImage!
    var centerImg:UIImage!
    var previewStatus: DisplayMode = .Plain
    var panStartPoint: CGFloat = 0
    var blurIsActive: Bool = false
    var bgColorIsActive: Bool = false
    var maxBlurAmount: CGFloat = 100.0
    var previousBlurAmount:CGFloat = 30.0
    var previousBgColor: UIColor? = nil
    var previousBorderColor: UIColor = .white
    var customizationStyle:CustomizationStyle!
    var isChangingBg:Bool = true{
        didSet{
            if isChangingBg{
                bgColorLabel.text = "背景颜色"
            }else{
                bgColorLabel.text = "边框颜色"
            }
        }
    }
    
    // MARK: - Outlet Variables
    
    @IBOutlet var tapGestureRecognizer1: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer2: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer3: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer4: UITapGestureRecognizer!
    @IBOutlet var tapGestureRecognizer5: UITapGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet var viewToSave: UIView!
    @IBOutlet var btnGroupView: UIView!
    
    @IBOutlet var homeLockImgView: UIImageView!{
        didSet{
            if customizationStyle == .Blur{
                if Device.IS_5_5_INCHES(){
                    homeLockImgView.image = UIImage(named: "HomeScreen_small")
                }else{
                    homeLockImgView.image = UIImage(named: "HomeScreen")
                }
            }else{
                if Device.IS_5_5_INCHES(){
                    homeLockImgView.image = UIImage(named: "LockScreen_small")
                }
            }
        }
    }
    
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
            if customizationStyle != .CenterSquare{
                centerImgView.alpha = 0
            }else{
                centerImgView.image = centerImg
                centerImgView.layer.cornerRadius = 12.0
                centerImgView.layer.masksToBounds = true
            }
        }
    }
    
    @IBOutlet var halfScreenImgView: UIImageView!{
        didSet {
            if customizationStyle != .HalfScreen{
                halfScreenImgView.alpha = 0
            }else{
                halfScreenImgView.image = centerImg
            }
        }
    }
    
    @IBOutlet var borderImgView: UIImageView!{
        didSet {
            if customizationStyle != .Border{
                borderImgView.alpha = 0
            }else{
                borderImgView.image = centerImg
                borderImgView.borderWidth = 2.5
                borderImgView.borderColor = .white
            }
        }
    }
    
    @IBOutlet var blurLabel: UILabel!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var blurBtn: UIButton!
    @IBOutlet var changeBgBtn: UIButton!
    @IBOutlet var changeBorderBtn: UIButton!
    @IBOutlet var downloadImgBtn: UIButton!
    @IBOutlet var closeBlurBtn: UIButton!
    @IBOutlet var checkBlurBtn: UIButton!
    @IBOutlet var stackView: UIStackView!
    
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
    @IBOutlet var bgColorLabel: UILabel!
    @IBOutlet var closeBgColorBtn: UIButton!
    @IBOutlet var checkBgColorBtn: UIButton!
    @IBOutlet var colorPickerView: ColorPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        adjustLayout()
    }
    
    func adjustLayout(){
        if customizationStyle != .Border{
            changeBorderBtn.removeFromSuperview()
        }
        stackView.layoutIfNeeded()
    }
    
    // MARK: - View Tap for Preview
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
    // MARK: - ProgressView For Changing Blurriness
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
    
    func addBlurBgToProgressView(){
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = progressView.bounds
        blurEffectView.layer.cornerRadius = cornerRadius
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.8
        progressView.insertSubview(blurEffectView, at: 0)
    }
    
    
    @IBAction func showBlurProgress(_ sender: UIButton) {
        blurIsActive = true
        updateBtnGroupVisibilityForBlur()
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
        updateBtnGroupVisibilityForBlur()
    }
    
    @IBAction func dismissBlurProgress(_ sender: UIButton) {
        previousBlurAmount = CGFloat(CGFloat(progressView.progress) * maxBlurAmount)
        blurIsActive = false
        updateBtnGroupVisibilityForBlur()
    }
    
    func updateBtnGroupVisibilityForBlur(){
        backBtn.alpha = blurIsActive ? 0 : 1
        changeBgBtn.alpha = blurIsActive ? 0 : 1
        if customizationStyle == .Border{
             changeBorderBtn.alpha = blurIsActive ? 0 : 1
        }
        blurBtn.alpha = blurIsActive ? 0 : 1
        downloadImgBtn.alpha = blurIsActive ? 0 : 1
        progressView.alpha = blurIsActive ? 1 : 0
        closeBlurBtn.alpha = blurIsActive ? 1 : 0
        checkBlurBtn.alpha = blurIsActive ? 1 : 0
        blurLabel.alpha = blurIsActive ? 1 : 0
        bgImgView.isUserInteractionEnabled = !blurIsActive
        centerImgView.isUserInteractionEnabled = !blurIsActive
        homeLockImgView.isUserInteractionEnabled = !blurIsActive
        borderImgView.isUserInteractionEnabled = !blurIsActive
        halfScreenImgView.isUserInteractionEnabled = !blurIsActive
    }
    
    // MARK: - ColorPickerView For Changing Background Color
    @IBAction func showBgColorPickerView(_ sender: UIButton) {
        bgColorIsActive = true
        isChangingBg = true
        updateBtnGroupVisibilityForBgColor()
    }
    
    @IBAction func showBorderColorPickerView(_ sender: UIButton) {
        bgColorIsActive = true
        isChangingBg = false
        updateBtnGroupVisibilityForBgColor()
    }
    
    func updateBtnGroupVisibilityForBgColor(){
        backBtn.alpha = bgColorIsActive ? 0 : 1
        if customizationStyle == .Border{
             changeBorderBtn.alpha = bgColorIsActive ? 0 : 1
        }
        blurBtn.alpha = bgColorIsActive ? 0 : 1
        changeBgBtn.alpha = bgColorIsActive ? 0 : 1
        downloadImgBtn.alpha = bgColorIsActive ? 0 : 1
        
        colorPickerView.alpha = bgColorIsActive ? 1 : 0
        closeBgColorBtn.alpha = bgColorIsActive ? 1 : 0
        checkBgColorBtn.alpha = bgColorIsActive ? 1 : 0
        bgColorLabel.alpha = bgColorIsActive ? 1 : 0
        
        bgImgView.isUserInteractionEnabled = !bgColorIsActive
        centerImgView.isUserInteractionEnabled = !bgColorIsActive
        homeLockImgView.isUserInteractionEnabled = !bgColorIsActive
        halfScreenImgView.isUserInteractionEnabled = !bgColorIsActive
        borderImgView.isUserInteractionEnabled = !bgColorIsActive
    }
    
    @IBAction func cancelBgColor(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            if isChangingBg{
                if let bgColor = previousBgColor{
                    bgImgView.image = bgImgView.image?.imageWithColor(tintColor: bgColor)
                }else{
                    if let blurredImg = blurImage(usingImage: bgImg, blurAmount: previousBlurAmount){
                        bgImgView.image = blurredImg
                    }
                }
            }else{
                borderImgView.borderColor = previousBorderColor
            }
            
        }
        bgColorIsActive = false
        updateBtnGroupVisibilityForBgColor()
    }
    
    @IBAction func acceptBgColor(_ sender: UIButton) {
        bgColorIsActive = false
        updateBtnGroupVisibilityForBgColor()
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

// MARK: - ColorPickerViewDelegate
extension ClassicalStyleVC: ColorPickerViewDelegate {

  func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
    // A color has been selected
    let colorSelected:UIColor = colorPickerView.colors[indexPath.row]
    
    
    DispatchQueue.main.async { [self] in
        if isChangingBg{
            bgImgView.image = bgImgView.image?.imageWithColor(tintColor: colorSelected)
        }else{
            borderImgView.borderColor = colorSelected
        }
    }
  }

}

// MARK: - ColorPickerViewDelegateFlowLayout
extension ClassicalStyleVC: ColorPickerViewDelegateFlowLayout {

  func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // The size for each cell
    // 👉🏻 WIDTH AND HEIGHT MUST BE EQUALS!
    let cellSize:CGSize = CGSize.init(width: widthForColorCell, height: widthForColorCell)
    return cellSize
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Space between cells
        return minimumLineSpacing
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Space between rows
    return minimumInteritemSpacing
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
    // Inset used aroud the view
    let insets = UIEdgeInsets.init(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    return insets
  }

}
