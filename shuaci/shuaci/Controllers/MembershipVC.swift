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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subscribeDescriptionLabel: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var  btnGroups: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentUser: LCUser!
    var vips:[VIP] = []
    fileprivate var timeOnThisPage: Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
                   VIP(duration: "连续包年", purchase: .YearVIP, price: 28, pastPrice: 72, numOfMonth: 12),
                   VIP(duration: "连续包季", purchase: .ThreeMonthVIP, price: 12, pastPrice: 36, numOfMonth: 3),
                   VIP(duration: "连续包月", purchase: .MonthlySubscribed, price: 6, pastPrice: 12, numOfMonth: 1)]
        }else{
            vips = [VIP(duration: "免费试用", purchase: .MonthlySubscribed, price: 0, pastPrice: 6, numOfMonth: 1),
                    VIP(duration: "连续包年", purchase: .YearVIP, price: 28, pastPrice: 72, numOfMonth: 12),
                    VIP(duration: "连续包季", purchase: .ThreeMonthVIP, price: 12, pastPrice: 36, numOfMonth: 3)]
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
        if price == 0{
            cell.amountSavedLabel.text = "新用户首月免费"
            cell.avgPriceLabel.text = "之后自动6元/月"
        }
        else{
            cell.amountSavedLabel.text = "立省\(pastPrice - price)元"
            let numOfMonth:Int = vips[row].numOfMonth
            let avgMonthPrice = Int(Double(price)/Double(numOfMonth))
            cell.avgPriceLabel.text = "平均\(avgMonthPrice)元/月"
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
                subscribeBtn.setTitle("立即试用!", for: .normal)
            }else{
                subscribeBtn.setTitle("成为会员!", for: .normal)
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
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            stopIndicator()
            self.view.isUserInteractionEnabled = true
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                print("RESTOREED: \(product.productId)")
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
