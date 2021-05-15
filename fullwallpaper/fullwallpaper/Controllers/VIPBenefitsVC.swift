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
    
    // Constants
    var products:[SKProduct?] = []
    let cellBorderColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
    let selectedCellBorderColor = UIColor(red: 211, green: 200, blue: 174, alpha: 1.0)
    
    let cellBgColor = UIColor.white
    let selectedCellBgColor = UIColor(red: 253, green: 249, blue: 242, alpha: 1.0)
    
    let borderWidth:CGFloat = 1.5
    
    
    // Variables
    var vips:[VIP] = []
    var showHint: Bool = false
    var selectedIndex: Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var subscriptionDescriptionLabel: UILabel!{
        didSet{
            subscriptionDescriptionLabel.text = subscriptionDescription
        }
    }
    @IBOutlet weak var subscribeBtn: UIButton!
    
    @IBOutlet weak var subscriptionTermBtn: UIButton!{
        didSet{
            subscriptionTermBtn.setTitle(subscriptionTermText, for: .normal)
        }
    }
    @IBOutlet weak var  btnGroups: UIStackView!
    
    @IBOutlet weak var restoreBtn: UIButton!{
        didSet{
            restoreBtn.setTitle(restorePurchaseText, for: .normal)
        }
    }
    
    
    @IBOutlet weak var pastPriceLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var vipCardImgView: UIImageView!{
        didSet{
            if english
            {
                vipCardImgView.image = UIImage(named: "vip_card_en")
            }
        }
    }
    
    @IBOutlet weak var midIconsImgView: UIImageView!{
        didSet{
            if english
            {
                midIconsImgView.image = UIImage(named: "mid_icons_en")
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = membershipText
            titleLabel.theme_textColor = "VIP.TextColor"
            if english{
                titleLabel.font = UIFont(name: "Clicker Script", size: 25.0)
            }
        }
    }
    
    @IBOutlet weak var vipLabel: UILabel!{
        didSet{
            vipLabel.text = proPreviligesText
            vipLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
            if english{
                cardImgView.image = UIImage(named: "vip_card_en")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        if showHint
        {
            self.view.makeToast(onlyProCanDownloadText, duration: 1.0, position: .center)
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
                transition.duration = fadeDuration
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
    
    @IBAction func restoreVIP(_ sender: UIButton) {
        restorePurchases()
    }
    
    @IBAction func loadSubscriptionURL(_ sender: UIButton) {
        let url = URL(string: "\(githubLink)/subscription_policy.html")!
        loadURL(url: url)
    }
    
    // Functions Related to In-App Purchase
    func purchase(purchase : RegisteredPurchase) {
        initIndicator(view: self.view)
        view.isUserInteractionEnabled = false
        SwiftyStoreKit.purchaseProduct( makeProductId(purchase: purchase), quantity: 1, atomically: true, completion: {
            result in
            stopIndicator()
            self.view.isUserInteractionEnabled = true
            switch result{
            case .success:
                UserDefaults.standard.set(purchase.rawValue, forKey: productKey)
                failedReason = .success
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .error(let error):
                
                var err_msg = (error as NSError).localizedDescription
                
                switch error.code {
                case .unknown: err_msg = unknownErrText
                case .clientInvalid: err_msg = paymentNotAllowedText
                case .paymentNotAllowed: err_msg = paymentNotAllowedText
                case .paymentCancelled: err_msg = purchaseCanceledText
                case .storeProductNotAvailable: err_msg = storeProductNotAvailableText
                default:
                    break
                }
                
                let alertVC = self.alertWithTitle(title: purchaseFailedText, message: err_msg)
                self.showAlert(alert: alertVC)
            }
        })
    }
    
    func restorePurchases() {
        initIndicator(view: self.view)
        view.isUserInteractionEnabled = false
        let existingProductIds:[String] = getProductIds()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            stopIndicator()
            self.view.isUserInteractionEnabled = true
            var lastPurchaseDate:Date? = nil
            var lastPurchaseId:String? = nil
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                if let transaction = product.originalTransaction{
                    if let transactionDate: Date = transaction.transactionDate{
                        if (lastPurchaseDate == nil || transactionDate > lastPurchaseDate!) && (existingProductIds.contains(product.productId)) && (transaction.transactionState == .purchased){
                            lastPurchaseDate = transactionDate
                            lastPurchaseId = product.productId
                        }
                    }
                }
            }
            if let purchaseId = lastPurchaseId{
                UserDefaults.standard.set(purchaseId, forKey: productKey)
            }
            self.showAlert(alert: self.alertForRestorePurchases(result: result))

        })
    }
    
    // Functions Related too CollectionView
    func setupCollectionView() {
        let oneYearTextHere:String = failedReason == .notPurchasedNewUser ? freetrialText: oneYearText
        vips = [
            VIP(duration: oneYearTextHere, purchase: .YearVIP, price: 28, pastPrice: 56, numOfMonth: 12),
            VIP(duration: threeMonthText, purchase: .ThreeMonthVIP, price: 12, pastPrice: 24, numOfMonth: 3),
            VIP(duration: oneMonthText, purchase: .OneMonthVIP, price: 6, pastPrice: 12, numOfMonth: 1)]
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        changeBtnTextOrTextBoxAlpha()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "membershipCollectionViewCell", for: indexPath) as! MembershipCollectionViewCell
        let row:Int = indexPath.row
        
        if row != selectedIndex {
            cell.layer.borderColor = cellBorderColor.cgColor
            cell.layer.backgroundColor = cellBgColor.cgColor
        }else{
            cell.layer.borderColor = selectedCellBorderColor.cgColor
            cell.layer.backgroundColor = selectedCellBgColor.cgColor
        }
        
        cell.layer.borderWidth = borderWidth
        
        cell.durationLabel.text = "\(vips[row].duration)"
        
        let price = vips[row].price
        cell.priceLabel.text = "¥\(price)"
        
        let pastPrice = vips[row].pastPrice
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "¥\(pastPrice)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.pastPriceLabel.attributedText = attributeString
        
        if price == 0{
            if english{
                cell.amountSavedLabel.text = "1 Month Free"
                cell.avgPriceLabel.text = "then ¥28.00/Year"
            }else{
                cell.amountSavedLabel.text = "新用户首月免费"
                cell.avgPriceLabel.text = "之后自动¥28/年"
            }
        }
        else{
            if english{
                cell.amountSavedLabel.text = "Save ¥\(pastPrice - price)"
                let numOfMonth:Int = vips[row].numOfMonth
                let avgMonthPrice = Int(Double(price)/Double(numOfMonth))
                cell.avgPriceLabel.text = "¥ \(avgMonthPrice).00/Mon in Average"
            }else{
                cell.amountSavedLabel.text = "立省\(pastPrice - price)元"
                let numOfMonth:Int = vips[row].numOfMonth
                let avgMonthPrice = Int(Double(price)/Double(numOfMonth))
                cell.avgPriceLabel.text = "平均\(avgMonthPrice)元/月"
            }
            
        }
        
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
        changeBtnTextOrTextBoxAlpha()
    }
    
    func changeBtnTextOrTextBoxAlpha(){
        if vips.count > selectedIndex{
            if vips[selectedIndex].price == 0{
                subscribeBtn.setTitle(tryNowText, for: .normal)
            }else{
                subscribeBtn.setTitle(beVIPText, for: .normal)
            }
        }
    }
    
    @IBAction func subscribeVIP(_ sender: UIButton) {
        let registeredPurchase:RegisteredPurchase = vips[selectedIndex].purchase
        purchase(purchase: registeredPurchase)
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension VIPBenefitsVC {
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: OkTxt, style: .cancel, handler: nil))
        return alert

    }
    
    func showAlert(alert : UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForRestorePurchases(result : RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            print("\(restorePurchaseFailedText): \(result.restoreFailedPurchases)")
            return alertWithTitle(title: restorePurchaseFailedText, message: unknownErrText)
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: restorePurchaseSuccessText, message: "")
        }
        else {
            return alertWithTitle(title: noHistoryPurchaseText, message: "")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            setTheme(theme: .day)
        } else {
            setTheme(theme: .night)
        }
    }
}
