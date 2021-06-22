//
//  AppDelegate.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit
import LeanCloud
import SwiftTheme
import SwiftyStoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        do {
            try LCApplication.default.set(
                id: LCAppId,
                key: LCKey,
                serverURL: LCServerURL)
        } catch {
            print(error)
        }
        
        setTheme()
        
        self.setupUmeng(launchOptions: launchOptions)
        self.setupStoreKit()
        checkIfEnglishEnv()
        return true
    }
    
    func setupStoreKit(){
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    func setupUmeng(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
            
            /// 友盟初始化
            UMCommonLogSwift.setUpUMCommonLogManager()
            UMCommonSwift.initWithAppkey(appKey: Config.share.keyUmeng, channel: Config.share.channelID)
            UMCommonSwift.setLogEnabled(bFlag: Config.share.isEnableUmengLog)
        }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

