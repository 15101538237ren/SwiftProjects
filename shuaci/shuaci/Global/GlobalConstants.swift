//
//  GlobalConstants.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/1.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//
import Foundation
import UIKit
import JGProgressHUD
import Toast_Swift

// MARK: - typealias

typealias CompletionHandler = (_ success:Bool) -> Void
typealias CompletionHandlerWithData = (_ data: Data?, _ fromCloud: Bool) -> Void


// MARK: - Constants

let LCAppId: String = "5uWh02cHlO4NIBMyM1rAaRRm-gzGzoHsz"
let LCKey: String = "MbgqYXQna9aFYQq7GRqRWHkA"
let OfficialEmail = "shuaci@outlook.com"

let NoNetworkStr: String = "没有网络,请检查网络连接!"
let UserDisabledTitle: String = "您的账号目前已被封禁"
let UserDisabledContent: String = "如有疑问，请联系:\(OfficialEmail)"

let QueryLimit: Int = 1000

let numberOfContDaysForMasteredAWord:Int = 5 //多少次连续记住算是掌握

let minToChangingWallpaper:CGFloat = 0.5

let everyDayLearningReminderNotificationIdentifier = "dailyLearningReminder"

let hud = JGProgressHUD(style: .light)




