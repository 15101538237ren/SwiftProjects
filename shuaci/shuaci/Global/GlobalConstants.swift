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

let hoursOfEbbinhaus:[Double] = [0, 1, 24, 72, 120, 168, 720, 2160, 4320]
let hoursLabels:[String] = ["刚复习", "1小时", "1天后", "3天后", "5天后", "1周后", "1月后", "3月后", "半年后"]

let daysOfLongTerm:[Int] = [0, 3, 7, 15, 30, 90, 180, 365]
let daysLabels:[String] = ["今天", "3天后", "1周后", "15天后", "1个月后", "3个月后", "半年后", "1年后"]
let retentionOfEbbinhaus:[Double] = [100.0, 44.2, 33.7, 27.2, 26.0, 25.2, 21, 15, 11.5]
let minNumOfVocabsForRetentionCalc:Double = 2
// MARK: - Constants

let productURL = URL(string: "https://itunes.apple.com/app/id1560571805")
let minimumReviewWorthyActionCount = 2
let LCAppId: String = "5uWh02cHlO4NIBMyM1rAaRRm-gzGzoHsz"
let LCKey: String = "MbgqYXQna9aFYQq7GRqRWHkA"
let OfficialEmail = "shuaci@outlook.com"

let NoNetworkStr: String = "没有网络,请检查网络连接!"
let UserDisabledTitle: String = "您的账号目前已被封禁"
let UserDisabledContent: String = "如有疑问，请联系:\(OfficialEmail)"

let QueryLimit: Int = 1000

let numberOfContDaysForMasteredAWord:Int = 4 //多少次连续记住算是掌握

let minToChangingWallpaper:CGFloat = 0.5

let everyDayLearningReminderNotificationIdentifier = "dailyLearningReminder"

let hud = JGProgressHUD(style: .light)

let numOfDayInStatCurve:Int = 7

let wexinAppId:String = "wx42c3db507ab657fd"
let wexinAppSecret:String = "b7ead6152fe001e053255c989c64b940"

let QQKey:String = "101943862"
let QQAppSecret:String = "60e06004933e39bc3c565f1f79a8ad58"

let githubLink:String = "https://15101538237ren.github.io"

let privacyViewedKey: String = "privacyViewed"
let notificationAskedKey: String = "notificationAsked"
let welcomeText: String = "欢迎使用「刷词」，请您仔细阅读隐私协议和服务条款，并确定您是否同意我们的规则。我们深知个人信息的重要性，并且会全力保护您的个人信息安全可靠。"

let nicknameOfApp:String = "小刷"

let ebbinhausNotificationText: String = "\(nicknameOfApp)需要开启「通知」权限来根据「艾宾浩斯遗忘规律」，提醒您在最高效的时间复习。"

let everydayNotificationText: String = "\(nicknameOfApp)需要开启「通知」权限，来每日提醒您复习。"

let noVocabToReviewText:String = "您当前没有待复习的单词，\n放松一下吧😊"

let notificationRejectedText:String = "您拒绝了开启「通知」，\(nicknameOfApp)将无法提醒您复习☹️。如需提醒，您可以前往「设置」，手动开启「通知」权限。"

let durationOfNotificationText: Double = 4.0
