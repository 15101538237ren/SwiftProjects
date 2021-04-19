//
//  AppDelegate.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import SwiftyStoreKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupLeanCloud()
        loadSwitchesSetting()
        self.setupUmeng(launchOptions: launchOptions)
        self.setupStoreKit()
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
    
    func setupLeanCloud(){
        do {
            
            try LCApplication.default.set(
                id: LCAppId,
                key: LCKey,
                serverURL: LCServerURL)
        } catch {
            print(error)
        }
    }
    
    func setupUmeng(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
            /// 友盟初始化
            UMCommonLogSwift.setUpUMCommonLogManager()
            UMCommonSwift.initWithAppkey(appKey: Config.share.keyUmeng, channel: Config.share.channelID)
            UMCommonSwift.setLogEnabled(bFlag: Config.share.isEnableUmengLog)
            
            print("Device ID")
            print(UMCommonSwift.deviceIDForIntegration())
        
            /// iOS 10 以上必須支援
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self
            }
            
            /// 友盟推送配置
            let entity = UMessageRegisterEntity.init()
            
            entity.types = Int(UMessageAuthorizationOptions.alert.rawValue) |
                Int(UMessageAuthorizationOptions.badge.rawValue) |
                Int(UMessageAuthorizationOptions.sound.rawValue)
            
            UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
                if granted {
                    // 用户选择了接收Push消息
                } else {
                    // 用户拒绝接收Push消息
                    print("用户拒绝接收Push消息")

                }
            }
            UMessage.setAutoAlert(false)
        }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    /// 拿到 Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        getDeviceId(deviceToken: deviceToken)
    }
    
    /// 註冊推送失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("注册推送失败")
        print(error.localizedDescription)
    }
    
    /// 接到推送訊息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    /// iOS10 新增：當 App 在＊＊前景＊＊模式下
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        UMessage.sendClickReport(forRemoteNotification: userInfo)
        print("User info: \(userInfo)")
        /// 處理遠程推送 ( Push Notification )
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            print("App 在＊＊前景＊＊模式下的遠程推送")
        } else {
            print("App 在＊＊前景＊＊模式下的本地推送")
        }
        completionHandler([.sound, .badge])
    }
        
    /// iOS10 新增：當 App 在＊＊背景＊＊模式下
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        
        (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false)
            /// 處理遠程推送 ( Push Notification )
            ? print("App 在＊＊背景＊＊模式下的遠程推送")
            /// 處理本地推送 ( Local Notification )
            : print("App 在＊＊背景＊＊模式下的本地推送")
    }
    
}

