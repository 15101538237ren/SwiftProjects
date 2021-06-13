//
//  GlobalEnum.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/2.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation

enum RegisteredPurchase : String {
    case YearVIP = "yearlysubscribed"
    case ThreeMonthVIP = "threemonthsubscribed"
    case MonthlySubscribed = "onemonthsubscribed"
}

enum OnlineStatus: Int{
    case offline = 0
    case online  = 1
    case learning = 2
    case reviewing = 3
}

enum FailedVerifyReason{
    case success
    case expired
    case notPurchasedNewUser
    case notPurchasedOldUser
    case unknownError
}

enum ShowMembershipReason{
    case OVER_LIMIT
    case PRO_WORDLIST
    case PRO_SELECT_TO_REVIEW
    case PRO_DICTIONARY
    case PRO_THEME
    case PRO_COLLECTION
    case UNKNOWN
}
