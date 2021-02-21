//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit
import SwiftyStoreKit
import StoreKit

class VIPBenefitsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
    // Constants
    let vips:[VIP] = [VIP(duration: "3个月", purchase: .ThreeMonthVIP, price: 18, pastPrice: 36), VIP(duration: "1年", purchase: .YearVIP, price: 45, pastPrice: 99), VIP(duration: "1个月", purchase: .OneMonthVIP, price: 12, pastPrice: 20) ]
    var products:[SKProduct?] = []
    let cellBorderColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
    let selectedCellBorderColor = UIColor(red: 211, green: 200, blue: 174, alpha: 1.0)
    
    let cellBgColor = UIColor.white
    let selectedCellBgColor = UIColor(red: 253, green: 249, blue: 242, alpha: 1.0)
    
    let borderWidth:CGFloat = 1.5
    
    
    // Variables
    var showHint: Bool = false
    var selectedIndex: Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var pastPriceLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var headerView: UIView!{
        didSet{
            headerView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    @IBOutlet weak var upperView: UIView!{
        didSet{
            upperView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var midView: UIView!{
        didSet{
            midView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var bottomView: UIView!{
        didSet{
            bottomView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet var upperDimUIView: UIView!{
        didSet{
            upperDimUIView.theme_alpha = "VIPPageDimView.Alpha"
        }
    }
    
    @IBOutlet var bottomDimUIView: UIView!{
        didSet{
            bottomDimUIView.theme_alpha = "VIPPageDimView.Alpha"
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var vipLabel: UILabel!{
        didSet{
            vipLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
        }
    }
    
    func checkHint(){
        var hintNum:Int = 0
        let uploadHintKey:String = "ProWallpaperHint"
        if isKeyPresentInUserDefaults(key: uploadHintKey){
            hintNum = UserDefaults.standard.integer(forKey: uploadHintKey)
        }
        if hintNum < 3 {
            self.view.makeToast("这是一张会员专属壁纸哦~", duration: 1.0, position: .center)
        }
        
        UserDefaults.standard.set(hintNum + 1, forKey: uploadHintKey)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "View.BackgroundColor"
        super.viewDidLoad()
        setupCollectionView()
        if showHint{
            checkHint()
        }
        enableEdgeSwipeGesture()
    }
    
    func enableEdgeSwipeGesture(){
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }
    
    @objc func screenEdgeSwiped(sender: UIScreenEdgePanGestureRecognizer){
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            
            if viewTranslation.x > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: 0)
                })
            }
        case .ended:
            if viewTranslation.x < (view.width/3.0) {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                let transition = CATransition()
                transition.duration = 0.7
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                transition.type = CATransitionType.fade
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window!.layer.add(transition, forKey: nil)
                self.dismiss(animated: false, completion: nil)
            }
        default:
            break
        }
    }
    
    @IBAction func purchaseVIP(_ sender: UIButton) {
        switch selectedIndex {
        case 0:
            purchase(purchase: .ThreeMonthVIP)
        case 1:
            purchase(purchase: .YearVIP)
        case 2:
            purchase(purchase: .OneMonthVIP)
        default:
            purchase(purchase: .ThreeMonthVIP)
        }
    }
    
    @IBAction func restoreVIP(_ sender: UIButton) {
        restorePurchases()
    }
    
    
    func makeProductId(purchase: RegisteredPurchase)-> String{
        return "\(bundleId).\(purchase.rawValue)"
    }
    
    func getTimeInterval(product: RegisteredPurchase) -> TimeInterval{
        switch product {
        case .OneMonthVIP:
            return 3600 * 24 * 30
        case .YearVIP:
            return 3600 * 24 * 365
        case .ThreeMonthVIP:
            return 3600 * 24 * 90
        }
    }
    
    func getInfo(purchase : RegisteredPurchase) {
        SwiftyStoreKit.retrieveProductsInfo([makeProductId(purchase: purchase)], completion: {
            result in
            
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))

        })
    }
    
    // Functions Related to In-App Purchase
    func purchase(purchase : RegisteredPurchase) {
        SwiftyStoreKit.purchaseProduct( makeProductId(purchase: purchase), quantity: 1, atomically: true, completion: {
            result in
            if case .success(let product) = result {
                
                if product.productId == self.makeProductId(purchase: .OneMonthVIP){
                    // Logic for post-processing
                }

                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
        })
    }
    
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            
            self.showAlert(alert: self.alertForRestorePurchases(result: result))

        })
    }
    
    func verifyReceipt() {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false, completion:{
            result in
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
        })
        
    }
    
    func verifyPurcahse(product : RegisteredPurchase) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false, completion: {
            result in
            
            switch result{
            case .success(let receipt):
                
                let productID = self.makeProductId(purchase: product)
                
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .nonRenewing(validDuration: self.getTimeInterval(product: product)), productId: productID, inReceipt: receipt, validUntil: Date())
                
                self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
            case .error(_):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            }
           

        })
    }
    
    // Functions Related too CollectionView
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "membershipCollectionViewCell", for: indexPath) as! MembershipCollectionViewCell
        let row:Int = indexPath.row
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "¥ \(vips[row].pastPrice).00")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        if row != selectedIndex {
            cell.layer.borderColor = cellBorderColor.cgColor
            cell.layer.backgroundColor = cellBgColor.cgColor
        }else{
            cell.layer.borderColor = selectedCellBorderColor.cgColor
            cell.layer.backgroundColor = selectedCellBgColor.cgColor
            priceLabel.text = "¥ \(vips[row].price).00"
            pastPriceLabel.attributedText = attributeString
        }
        
        cell.layer.borderWidth = borderWidth
        
        cell.durationLabel.text = "\(vips[row].duration)"
        
        cell.priceLabel.text = "\(vips[row].price)"
        
        cell.pastPriceLabel.attributedText = attributeString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height:CGFloat = 120.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension VIPBenefitsVC {
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
        return alert

    }
    
    func showAlert(alert : UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(result : RetrieveResults) -> UIAlertController {
            let error_info = "无法获取产品信息"
            if let product = result.retrievedProducts.first {
                return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(product.localizedPrice!)")
                
            }
            
            else if let invalidProductID = result.invalidProductIDs.first {
                return alertWithTitle(title: error_info, message: "找不到产品ID: \(invalidProductID)")
            }
            else {
                let errorString = result.error?.localizedDescription ?? "未知错误，请稍后重试"
                return alertWithTitle(title: error_info , message: errorString)
                
            }
            
        }
    
        func alertForPurchaseResult(result : PurchaseResult) -> UIAlertController {
            switch result {
            case .success:
                return alertWithTitle(title: "购买成功", message: "恭喜您成为PRO会员，尽享壁纸与特权吧😊")
            case .error(let error):
                var err_msg = (error as NSError).localizedDescription
                switch error.code {
                case .unknown: err_msg = "未知错误，请稍后再试"
                case .clientInvalid: err_msg = "系统购买功能被您禁止"
                case .paymentCancelled: err_msg = "购买被取消"
                case .paymentNotAllowed: err_msg = "系统购买功能被您禁止"
                case .storeProductNotAvailable: err_msg = "当前产品不支持在您所在的国家购买"
                default:
                    break
                }
                
                return alertWithTitle(title: "购买失败", message: err_msg)
            }
            
        }
        
        func alertForRestorePurchases(result : RestoreResults) -> UIAlertController {
            if result.restoreFailedPurchases.count > 0 {
                print("恢复购买失败: \(result.restoreFailedPurchases)")
                return alertWithTitle(title: "恢复购买失败", message: "未知错误，请反馈至客服")
            }
            else if result.restoreFailedPurchases.count > 0 {
                return alertWithTitle(title: "恢复购买成功", message: "")
                
            }
            else {
                return alertWithTitle(title: "无历史购买", message: "")
            }
            
        }
    
        func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
            switch result {
            case.success:
                return alertWithTitle(title: "收据已验证", message: "")
            case .error(let error):
                switch error {
                case .noReceiptData:
                    return alertWithTitle(title: "无收据数据", message: "")
                default:
                    return alertWithTitle(title: "收据验证失败", message: "")
                }
            }
        }
    
        func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
            switch result {
            case .purchased(let expiryDate, _):
                return alertWithTitle(title: "您的会员身份有效", message: "过期时间: \(expiryDate)")
            case .notPurchased:
                return alertWithTitle(title: "您未购买过会员", message: "")
            case .expired(let expiryDate, _):
                return alertWithTitle(title: "会员已过期", message: "过期时间: \(expiryDate)")
            }
        }
    
        func alertForVerifyPurchase(result : VerifyPurchaseResult) -> UIAlertController {
            switch result {
            case .purchased:
                return alertWithTitle(title: "您已是会员", message: "")
            case .notPurchased:
                return alertWithTitle(title: "您未购买会员", message: "")
            }
        }
}
