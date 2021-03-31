//
//  GMThirdPartyLogin.swift
//  友盟第三方登录分享
//
//  Created by Xinxibin on 16/10/21.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import Foundation

// MARK: - 平台授权获取用户基本信息

// 新浪微博授权登录
func getAuthInfoFromSinaUser(withVC vc:UIViewController , completion:@escaping (UMSocialAuthResponse?, Error?)->(Void)){
    
    UMSocialManager.default().auth(with: UMSocialPlatformType.sina, currentViewController: vc.self) { (result, error) in
        guard error == nil else{
            vc.view.makeToast("出现错误:\(error)", duration: 1.0, position: .center)
            return
        }
        let userInfo = result as! UMSocialAuthResponse
        
        completion(userInfo,error)
    }
}

// 微信授权登录
func getAuthInfoFromWechatUser(withVC vc:UIViewController , completion:@escaping (UMSocialAuthResponse?, Error?)->(Void)){
    UMSocialManager.default().cancelAuth(with: UMSocialPlatformType.wechatSession) { (result, error) in }
    
    UMSocialManager.default().auth(with: UMSocialPlatformType.wechatSession, currentViewController: nil) { (result, error) in
        guard error == nil else{
            vc.view.makeToast("出现错误:\(error)", duration: 1.0, position: .center)
            return
        }
        print("Results")
        print(result)
    }
    
//    UMSocialManager.default().auth(with: UMSocialPlatformType.wechatSession, currentViewController: vc.self) { (result, error) in
//        guard error == nil else{
//            vc.view.makeToast("出现错误:\(error)", duration: 1.0, position: .center)
//            return
//        }
//        let userInfo = result as! UMSocialAuthResponse
//
//        completion(userInfo,error)
//    }
}

// QQ授权登录
func getAuthInfoFromQQUser(withVC vc:UIViewController , completion:@escaping (UMSocialAuthResponse?, Error?)->(Void)){
    
    UMSocialManager.default().auth(with: UMSocialPlatformType.QQ, currentViewController: vc.self) { (result, error) in
        guard error == nil else{
            vc.view.makeToast("出现错误:\(error)", duration: 1.0, position: .center)
            return
        }
        let userInfo = result as! UMSocialAuthResponse
        completion(userInfo,error)
    }
}

// 获取用户信息
func getUserInfo(withType type:UMSocialPlatformType , withVC vc:UIViewController, completion:@escaping (UMSocialUserInfoResponse?, Error?)->(Void)) {
    
    UMSocialManager.default().getUserInfo(with: type, currentViewController: vc.self) { (result, error) in
        guard error == nil else{
            vc.view.makeToast("出现错误:\(error)", duration: 1.0, position: .center)
            return
        }
        let userinfo = result as! UMSocialUserInfoResponse
        print(userinfo)
        completion(userinfo,error)

    }
}

// MARK: - 分享相关

// 分享图文（新浪微博支持）微信/QQ，仅支持图或者文本
func shareImageAndTextToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping (Bool?)->(Void)) {
    
    let messageObject = UMSocialMessageObject()
    // 文本
    messageObject.text = "社会化组件UShare将各大社交平台接入您的应用，快速武装App。"
    // 图片
    let shareObject = UMShareImageObject.init()
    // 添加缩略图
    // shareObject.thumbImage = UIImage(named: "")
    shareObject.shareImage = "http://dev.umeng.com/images/tab2_1.png"
    
    // 分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject
    
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
    
}
// 分享视频内容
func shareVideoToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping (Bool?)->(Void)) {

    
    let messageObject = UMSocialMessageObject()
    let shareObject = UMShareVideoObject.shareObject(withTitle: "视频标题", descr: "分型内容描述", thumImage: "")
    
    shareObject?.videoUrl = "http://www.fengmi.tv/pshare/id/301998/?vid=301998&num=6114208&type=piandan&uid=&url=&version=2.1&from=singlemessage&isappinstalled=1"
    messageObject.shareObject = shareObject
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}

// 分享音乐内容
func shareMusicToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping ((Bool)->())) {

    let messageObject = UMSocialMessageObject()
    let shareObject = UMShareMusicObject.shareObject(withTitle: "分享标题", descr: "分型内容描述", thumImage: "http://dev.umeng.com/images/tab2_1.png")
    
    shareObject?.musicUrl = "http://c.y.qq.com/v8/playsong.html?songid=108782194&source=yqq#wechat_redirect"
    messageObject.shareObject = shareObject
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}

// 分享网页
func shareWebPageToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping ((Bool)->())) {
    
    let messageObject = UMSocialMessageObject()
    let shareObject = UMShareWebpageObject.shareObject(withTitle: "分享标题", descr: "分型内容描述", thumImage: "")
    
    shareObject?.webpageUrl = "http://mobile.umeng.com/social"
    messageObject.shareObject = shareObject
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}

// 分享图片
func shareImageToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping ((Bool)->())) {
    
    let messageObject = UMSocialMessageObject()
    let shareObject = UMShareImageObject()
    // 设置默认图
    // shareObject.thumbImage = UIImage(named: "")
    shareObject.shareImage = "http://dev.umeng.com/images/tab2_1.png"
    messageObject.shareObject = shareObject
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}

// 分享文本
func shareTextToPlatformType(platformType:UMSocialPlatformType,withVC vc:UIViewController,completion:@escaping ((Bool)->())) {
    
    let messageObject = UMSocialMessageObject()
    messageObject.text = "文本信息内容"
    
    UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: vc) { (result, error) in
        
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}





