//
//  GlobalConstant.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import Foundation
import UIKit
import Nuke
import JGProgressHUD
import SwiftyStoreKit


//Constants
let sharedSecret = "02096ef5b63b455fa533027056c5ee73" //secret key for In-App Purchase
let bundleId = "com.hongleir.fullscreenwallpaper.cn"
let LCAppId: String = "Y3wzJERyrbjHzR7exzMChF7I-gzGzoHsz"
let LCKey: String = "cVvbrIE2rMLLziICGIvM52c8"

let productURL = URL(string: "https://itunes.apple.com/app/id1544907523")
let githubLink:String = "https://15101538237ren.github.io"
let privacyViewedKey: String = "privacyViewed"

let minimumReviewWorthyActionCount = 3

let hud = JGProgressHUD(style: .light)
let hudWithProgress = JGProgressHUD(style: .light)
let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)

let vips:[VIP] = [VIP(duration: "3个月", purchase: .ThreeMonthVIP, price: 18, pastPrice: 36), VIP(duration: "1年", purchase: .YearVIP, price: 45, pastPrice: 99), VIP(duration: "1个月", purchase: .OneMonthVIP, price: 12, pastPrice: 20) ]

let fadeDuration:Double = 1.0
let thumbnailScale = 0.25
let wallpaperLimitEachFetch:Int = 30

let whRatio:CGFloat = CGFloat(828.0/1792.0)

let wallpaperLoadingOptions = ImageLoadingOptions(
    placeholder: UIImage(named: "image_placeholder"),
    transition: .fadeIn(duration: 0.33)
)

let categoryLoadingOptions = ImageLoadingOptions(
    placeholder: UIImage(named: "wide_image_placeholder"),
    transition: .fadeIn(duration: 0.33)
)

let dimUIViewAlpha:CGFloat = 0.1
let numberOfWallpapersEachPage:Int = 30

let numberOfItemsPerRow:CGFloat = CGFloat(3)
let cellSpacing:CGFloat = CGFloat(2)
let cellHeightWidthRatio:CGFloat = CGFloat(1.5)


let numberOfItemsPerRowForCustomization:CGFloat = CGFloat(2)
let cellSpacingForCustomization:CGFloat = CGFloat(17.5)
let cellHeightWidthRatioForCustomization:CGFloat = CGFloat(2.1653)

let categoryJsonFileName = "Category.json"

enum CacheType {
    case image
    case json
}

typealias CompletionHandler = (_ success:Bool) -> Void
