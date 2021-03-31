//
//  AppDelegate.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupLeanCloud()
        self.setupUmeng(launchOptions: launchOptions)
        return true
    }
    
    func setupLeanCloud(){
        do {
            
            try LCApplication.default.set(
                id: LCAppId,
                key: LCKey,
                serverURL: "https://5uwh02ch.lc-cn-n1-shared.com")
        } catch {
            print(error)
        }
    }
    
    func setupUmeng(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
            
            /// 友盟初始化
            UMCommonLogSwift.setUpUMCommonLogManager()
            UMCommonSwift.initWithAppkey(appKey: Config.share.keyUmeng, channel: Config.share.channelID)
            UMCommonSwift.setLogEnabled(bFlag: Config.share.isEnableUmengLog)
            configUShareSettings()
            print("Device ID")
            print(UMCommonSwift.deviceIDForIntegration())
        }

    // MARK: UISceneSession Lifecycle

    func configUShareSettings() {
        UMSocialManager.default().openLog(true)
        UMSocialGlobal.shareInstance().isUsingHttpsWhenShareContent = false
        //设置微信的appkey和appsecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatSession, appKey: wexinAppId, appSecret: wexinAppSecret, redirectURL: "")
        //设置QQ的APPkey和appsecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.QQ, appKey: QQKey, appSecret: QQAppSecret, redirectURL: "")
    }
    
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        UMSocialManager.default().handleOpen(url, options: options)
        return true
    }

}

