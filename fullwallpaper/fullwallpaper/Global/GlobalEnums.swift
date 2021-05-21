//
//  GlobalEnums.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import Foundation

enum CustomizationStyle{
    case CenterSquare
    case Blur
    case HalfScreen
    case Border
}

enum RegisteredPurchase : String {
    case ThreeMonthVIP = "3monsvip"
    case YearVIP = "1yearvip"
    case OneMonthVIP = "1monvip"
}

enum SortType {
    case byLike
    case byCreateDate
}


enum DisplayMode {
    case Plain
    case LockScreen
    case HomeScreen
}


enum ACTION_TYPE: String {
    case save = "下载"
    case like = "收藏"
    case upload = "上传"
    case report = "举报"
}

enum THEME: String {
    case day = "day"
    case night = "night"
    case system = "system"
}


enum FailedVerifyReason{
    case success
    case expired
    case notPurchasedNewUser
    case notPurchasedOldUser
    case unknownError
}

enum ShowVIPPageReason{
    case DOWNLOAD_FREE_WALLPAPER_OVER_LIMIT
    case PRO_WALLPAPER
    case PRO_COLLECTION
    case PRO_CATEGORY
    case PRO_CUSTOMIZATION
    case PRO_SEARCH
    case UNKNOWN
}
