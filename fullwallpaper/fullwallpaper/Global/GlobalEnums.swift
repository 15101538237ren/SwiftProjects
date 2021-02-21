//
//  GlobalEnums.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/12/20.
//

import Foundation

enum RegisteredPurchase : String {
    case ThreeMonthVIP = "threemonthvip"
    case YearVIP = "yearvip"
    case OneMonthVIP = "onemonthvip"
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
