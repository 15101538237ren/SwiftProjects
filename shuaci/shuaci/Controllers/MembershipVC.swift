//
//  MembershipVC.swift
//  shuaci
//
//  Created by Honglei on 4/3/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import LeanCloud

class MembershipVC: UIViewController {
    
    var currentUser: LCUser!
    fileprivate var timeOnThisPage: Int = 0
    @IBOutlet weak var demoImgView: UIImageView!
    var viewTranslation = CGPoint(x: 0, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGIF()
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
    
    func loadGIF(){
        var imageData: Data? = nil
        do {
            imageData = try Data(contentsOf: Bundle.main.url(forResource: "card_animation", withExtension: "gif")!)
            let advTimeGif = UIImage.gifImageWithData(imageData!)
            demoImgView.image = advTimeGif
        } catch {
            print("error when loading gif")
        }
    }
    
    @IBAction func subscribeVIP(_ sender: UIButton) {
        purchase(purchase: .MonthlySubscribed)
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
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
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
                
                let errInfo = ["Um_Key_Reasons": err_msg, "Um_Key_UserID" : self.currentUser.objectId!.stringValue!]
                
                UMAnalyticsSwift.event(eventId: "Um_Event_VipFailed", attributes: errInfo)
                
                let alertVC = self.alertWithTitle(title: "购买失败", message: err_msg)
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
        alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
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
            print("恢复购买失败: \(result.restoreFailedPurchases)")
            return alertWithTitle(title: "恢复购买失败", message: "未知错误，请反馈至客服")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "恢复购买成功", message: "")
        }
        else {
            return alertWithTitle(title: "无历史购买", message: "")
        }
    }
}
