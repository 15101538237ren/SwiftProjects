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
import SwiftyStoreKit

// MARK: - typealias

typealias CompletionHandler = (_ success:Bool) -> Void
typealias Completion = () -> Void
typealias CompletionHandlerWithData = (_ data: Data?, _ fromCloud: Bool) -> Void

let hoursLabels:[String] = ["刚复习", "1小时", "1天后", "3天后", "5天后", "1周后", "1月后", "3月后", "半年后"]
let daysLabels:[String] = ["今天", "3天后", "1周后", "15天后", "1个月后", "3个月后", "半年后", "1年后"]
let hoursOfEbbinhaus:[Double] = [0, 1, 24, 72, 120, 168, 720, 2160, 4320]
let daysOfLongTerm:[Int] = [0, 3, 7, 15, 30, 90, 180, 365]
let retentionOfEbbinhaus:[Double] = [100.0, 44.2, 33.7, 27.2, 26.0, 25.2, 21, 15, 11.5]
let minNumOfVocabsForRetentionCalc:Double = 2
// MARK: - Constants

let productURL = URL(string: "https://itunes.apple.com/app/id1560571805")
let sharedSecret = "3a2e76c0ad73427ea047d8835842c883" //secret key for In-App Purchase
let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
let bundleId = "com.shuaci"
let minimumReviewWorthyActionCount = 2
let LCAppId: String = "5uWh02cHlO4NIBMyM1rAaRRm-gzGzoHsz"
let LCKey: String = "MbgqYXQna9aFYQq7GRqRWHkA"
let OfficialEmail = "shuaci@outlook.com"

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

let durationOfNotificationText: Double = 4.0
