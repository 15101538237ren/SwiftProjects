//
//  MembershipVC.swift
//  shuaci
//
//  Created by Honglei on 4/3/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import LeanCloud

class MembershipVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var hasFreeTrialed:Bool!
    let cellSpacing:CGFloat = CGFloat(2)
    let numberOfItemsPerRow:CGFloat = CGFloat(3)
    var products:[SKProduct?] = []
    let cellBorderColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
    let selectedCellBorderColor = UIColor(red: 211, green: 200, blue: 174, alpha: 1.0)
    
    let cellBgColor = UIColor.white
    let selectedCellBgColor = UIColor(red: 253, green: 249, blue: 242, alpha: 1.0)
    
    let borderWidth:CGFloat = 1.5
    
    // Variables
    var showHint: Bool = false
    var selectedIndex: Int = 0
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = VIPTitleText
        }
    }
    @IBOutlet weak var subscribeDescriptionLabel: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var redeemBtn: UIButton!{
        didSet{
            redeemBtn.setTitle(redeemBtnText, for: .normal)
        }
    }
    
    @IBOutlet weak var restoreBtn: UIButton!{
        didSet{
            restoreBtn.setTitle(restoreText, for: .normal)
        }
    }
    
    @IBOutlet weak var subscriptionTermBtn: UIButton!{
        didSet{
            subscriptionTermBtn.setTitle(subscriptionTermText, for: .normal)
        }
    }
    
    @IBOutlet weak var subscriptionDescriptionLabel: UILabel!{
        didSet{
            subscriptionDescriptionLabel.text = subscriptionDescription
        }
    }
    
    
    @IBOutlet weak var  btnGroups: UIStackView!
    @IBOutlet weak var vipCardImgView: UIImageView!{
        didSet{
            if let langStr = Locale.current.languageCode
            {
                if !langStr.contains("zh"){
                    vipCardImgView.image = UIImage(named: "vip_card_en")
                }
            }
        }
    }
    
    @IBOutlet weak var midIconsImgView: UIImageView!{
        didSet{
            if let langStr = Locale.current.languageCode
            {
                if !langStr.contains("zh"){
                    midIconsImgView.image = UIImage(named: "mid_icons_en")
                }
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentUser: LCUser!
    var vips:[VIP] = []
    fileprivate var timeOnThisPage: Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        if showHint
        {
            self.view.makeToast(hintText, duration: 3.5, position: .center)
        }
        stopIndicator()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(sender:))))
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
    }
    
    @objc func tictoc(){
        timeOnThisPage += 1
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
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    // Functions Related too CollectionView
    func setupCollectionView() {
        if hasFreeTrialed{
            vips = [
                VIP(duration: monthSubscriptionText, purchase: .MonthlySubscribed, price: 6, pastPrice: 12, numOfMonth: 1),
                   VIP(duration: quarterSubscriptionText, purchase: .ThreeMonthVIP, price: 12, pastPrice: 36, numOfMonth: 3),
                VIP(duration: yearSubscriptionText, purchase: .YearVIP, price: 28, pastPrice: 72, numOfMonth: 12)]
        }else{
            vips = [
                VIP(duration: freetrialText, purchase: .YearVIP, price: 28, pastPrice: 72, numOfMonth: 12),
                    VIP(duration: quarterSubscriptionText, purchase: .ThreeMonthVIP, price: 12, pastPrice: 36, numOfMonth: 3),
                VIP(duration: monthSubscriptionText, purchase: .MonthlySubscribed, price: 0, pastPrice: 6, numOfMonth: 1)]
        }
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
        var enversion:Bool = false
        if let langStr = Locale.current.languageCode
        {
            if !langStr.contains("zh"){
                enversion = true
            }
        }
        if price == 0{
            if enversion{
                cell.amountSavedLabel.text = "1 Month Free"
                cell.avgPriceLabel.text = "then ¥6.00/Mon"
            }else{
                cell.amountSavedLabel.text = "新用户首月免费"
                cell.avgPriceLabel.text = "之后自动6元/月"
            }
        }
        else{
            if enversion{
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
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func subscribeVIP(_ sender: UIButton) {
        let registeredPurchase:RegisteredPurchase = vips[selectedIndex].purchase
        purchase(purchase: registeredPurchase)
    }
    
    @IBAction func loadSubscriptionURL(_ sender: UIButton) {
        let url = URL(string: "\(githubLink)/shuaci/subscription_policy.html")!
        loadURL(url: url)
    }
    
    // Functions Related to In-App Purchase
    func purchase(purchase : RegisteredPurchase) {
        initIndicator(view: self.view)
        view.isUserInteractionEnabled = false
        let userInfo = ["Um_Key_UserID" : currentUser.objectId!.stringValue!]
        UMAnalyticsSwift.event(eventId: "Um_Event_VipClick", attributes: userInfo)
        SwiftyStoreKit.purchaseProduct( makeProductId(purchase: purchase), quantity: 1, atomically: true, completion: {
            result in
            stopIndicator()
            self.view.isUserInteractionEnabled = true
            switch result{
            case .success:
                UMAnalyticsSwift.event(eventId: "Um_Event_VipSuc", attributes: userInfo)
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
                
                let errInfo = ["Um_Key_Reasons": err_msg, "Um_Key_UserID" : self.currentUser.objectId!.stringValue!]
                
                UMAnalyticsSwift.event(eventId: "Um_Event_VipFailed", attributes: errInfo)
                
                let alertVC = self.alertWithTitle(title: purchaseFailedText, message: err_msg)
                self.showAlert(alert: alertVC)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let info = ["Um_Key_PageName": "会员购买页", "Um_Key_Duration": timeOnThisPage, "Um_Key_UserID" : currentUser.objectId!.stringValue!] as [String : Any]
        
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
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
    
}

extension MembershipVC {
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okText, style: .cancel, handler: nil))
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
            return alertWithTitle(title: restorePurchaseFailedText, message: unknownErrText)
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: restorePurchaseSuccessText, message: "")
        }
        else {
            return alertWithTitle(title: noHistoryPurchaseText, message: "")
        }
    }
}
