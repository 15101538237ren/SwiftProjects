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


//Constants
let LCAppId: String = "Y3wzJERyrbjHzR7exzMChF7I-gzGzoHsz"
let LCKey: String = "cVvbrIE2rMLLziICGIvM52c8"

let productURL = URL(string: "https://itunes.apple.com/app/id1544907523")

let githubLink:String = "https://15101538237ren.github.io"

let privacyViewedKey: String = "privacyViewed"
let welcomeText: String = "欢迎使用全面屏壁纸，请您仔细阅读隐私协议和服务条款，并确定您是否同意我们的规则。我们深知个人信息的重要性，并且会全力保护您的个人信息安全可靠。"

let minimumReviewWorthyActionCount = 3

let hud = JGProgressHUD(style: .light)
let hudWithProgress = JGProgressHUD(style: .light)

let thumbnailScale = 0.25
let wallpaperLimitEachFetch:Int = 50

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

let categoryJsonFileName = "Category.json"

let OkTxt = "好的"
let loadingTxt = "正在加载.."
let NoNetworkStr = "没有网络,请检查网络连接!"

enum CacheType {
    case image
    case json
}
