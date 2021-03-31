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
let wexinAppSecret:String = "05aa97ef930d5dd0a63e070167455456"

let QQKey:String = "wx42c3db507ab657fd"
let QQAppSecret:String = "05aa97ef930d5dd0a63e070167455456"

