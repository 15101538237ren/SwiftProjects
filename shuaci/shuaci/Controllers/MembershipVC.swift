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
import SwiftTheme

class MembershipVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var hasFreeTrialed:Bool!
    var mainPanelViewController: MainPanelViewController?
    let cellSpacing:CGFloat = CGFloat(2)
    let numberOfItemsPerRow:CGFloat = CGFloat(3)
    var products:[SKProduct?] = []
    let cellBorderColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
    let selectedCellBorderColor = UIColor(red: 211, green: 200, blue: 174, alpha: 1.0)
    
    let cellBgColor = UIColor.white
    let selectedCellBgColor = UIColor(red: 253, green: 249, blue: 242, alpha: 1.0)
    
    let borderWidth:CGFloat = 1.5
    
    // Variables
    var FailedReason: FailedVerifyReason!
    var ReasonForShow: ShowMembershipReason!
    var selectedIndex: Int = 0
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = VIPTitleText
        }
    }
    @IBOutlet weak var subscribeDescriptionLabel: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!{
        didSet{
            if FailedReason == .success{
                subscribeBtn.alpha = 0
            }else{
                subscribeBtn.alpha = 1
            }
        }
    }
    
    @IBOutlet weak var ProDurationLabel: UILabel!{
        didSet{
            if failedReason != .success{
                ProDurationLabel.text = ProDurationText
            }else{
                
                if let expiryDate = expireDate
                {
                    if english{
                        ProDurationLabel.font = UIFont(name: "Copperplate", size: 18.0)
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    let today_str:String = dateFormatter.string(from: expiryDate)
                    ProDurationLabel.text = "\(ValidUntilText) \(today_str)"
                }
                else{
                    ProDurationLabel.text = ProDurationText
                }
            }
        }
    }
    
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
    
    @IBOutlet weak var termOfUseBtn: UIButton!{
        didSet{
            termOfUseBtn.setTitle(serviceTermText, for: .normal)
        }
    }
    
    @IBOutlet weak var privacyPolicyBtn: UIButton!{
        didSet{
            privacyPolicyBtn.setTitle(privacyText, for: .normal)
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
        stopIndicator()
        let toastText = makeToastText()
        if !toastText.isEmpty{
            self.view.makeToast(toastText, duration: 3.0, position: .center)
        }
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
    
    func makeToastText() -> String{
        var failedReasonText:String = ""
        
        switch FailedReason {
        case .expired:
            failedReasonText = failedExpairedText
        case .notPurchasedOldUser:
            failedReasonText = failedExpairedText
        case .notPurchasedNewUser:
            failedReasonText = failedNewUserText
        case .unknownError:
            failedReasonText = failedNewUserText
        case .success:
            return ""
        default:
            return ""
        }
        
        var reasonToShowText:String = ""
        
        switch ReasonForShow {
        case .OVER_LIMIT:
            reasonToShowText = freeUseOverLimitText
        case .PRO_WORDLIST:
            reasonToShowText = proWordListText
        case .PRO_THEME:
            reasonToShowText = proThemeText
        case .PRO_COLLECTION:
            reasonToShowText = proCollectionText
        case .PRO_DICTIONARY:
            reasonToShowText = proDictText
        case .PRO_MAX_WORD_PER_DAY:
            reasonToShowText = proMaxWordPerDayText
        case .UNKNOWN:
            reasonToShowText = proUnknownAccessText
        case .NONE:
            reasonToShowText = ""
        default:
            reasonToShowText = ""
        }
        let returnStr = (!reasonToShowText.isEmpty) || (!failedReasonText.isEmpty) ? "\(failedReasonText). \(reasonToShowText)" : ""
        return returnStr
    }
    
    // Functions Related too CollectionView
    func setupCollectionView() {
        if hasFreeTrialed{
            vips = [
                VIP(duration: yearSubscriptionText, purchase: .YearVIP, price: 28, pastPrice: 56, numOfMonth: 12),
                VIP(duration: quarterSubscriptionText, purchase: .ThreeMonthVIP, price: 12, pastPrice: 24, numOfMonth: 3),
                VIP(duration: monthSubscriptionText, purchase: .MonthlySubscribed, price: 6, pastPrice: 12, numOfMonth: 1)]
        }else{
            vips = [
                VIP(duration: freetrialText, purchase: .YearVIP, price: 0, pastPrice: 56, numOfMonth: 12),
                VIP(duration: quarterSubscriptionText, purchase: .ThreeMonthVIP, price: 12, pastPrice: 36, numOfMonth: 3),
                VIP(duration: monthSubscriptionText, purchase: .MonthlySubscribed, price: 6, pastPrice: 12, numOfMonth: 1)]
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
                cell.amountSavedLabel.text = "1 Week Free"
                cell.avgPriceLabel.text = "then ¥28.00/Year"
            }else{
                cell.amountSavedLabel.text = "新用户首周免费"
                cell.avgPriceLabel.text = "之后自动28元/年"
            }
        }
        else{
            if enversion{
                cell.amountSavedLabel.text = "PRO Subscription"
                cell.avgPriceLabel.text = "Auto-Renewable"
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
    
    @IBAction func loadPrivacyURL(_ sender: UIButton) {
        let url = URL(string: "\(githubLink)/shuaci/privacy.html")!
        loadURL(url: url)
    }
    
    @IBAction func loadTermOfUseURL(_ sender: UIButton) {
        let url = URL(string: "\(githubLink)/shuaci/terms.html")!
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
                failedReason = .success // remember to set global variable expireDate: Date?, failedReason: FailedVerifyReason
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if let currentUser = LCApplication.default.currentUser {
            var pref = loadPreference(userId: currentUser.objectId!.stringValue!)
            if traitCollection.userInterfaceStyle == .dark{
                pref.dark_mode = true
            }else{
                pref.dark_mode = false
            }
            savePreference(userId: currentUser.objectId!.stringValue!, preference: pref)
            if let mainVC = mainPanelViewController{
                mainVC.update_preference()
                mainVC.loadWallpaper(force: true)
            }
            
            if pref.dark_mode{
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: theme_category_to_name[pref.current_theme]!.rawValue, path: .mainBundle)
            }
        }
    }
}
