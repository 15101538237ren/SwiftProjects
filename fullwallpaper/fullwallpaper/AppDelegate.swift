//
//  AppDelegate.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit
import LeanCloud
import SwiftTheme


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        do {
            var configuration = LCApplication.Configuration.default
            configuration.HTTPURLCache = URLCache(
                // 内存缓存容量，100 MB
                memoryCapacity: 100 * 1024 * 1024,
                // 磁盘缓存容量，100 MB
                diskCapacity: 100 * 1024 * 1024,
                // `nil` 表示使用系统默认的缓存路径，你也可以自定义路径
                diskPath: nil)
            
            try LCApplication.default.set(
                id: LCAppId,
                key: LCKey,
                serverURL: "https://y3wzjery.lc-cn-n1-shared.com",
                configuration: configuration)
        } catch {
            print(error)
        }
        
        UMCommonLogSwift.setUpUMCommonLogManager()
        UMCommonSwift.setLogEnabled(bFlag: true)
        UMCommonSwift.initWithAppkey(appKey: "5fd5163e498d9e0d4d8bc7f5", channel: "App Store")
        
//        print("DEVICE ID: \(UMCommonSwift.deviceIDForIntegration())")
        
        setTheme()
        
        loadCategories(completion:{})
        
        return true
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


}

