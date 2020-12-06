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

let hud = JGProgressHUD(style: .light)
let hudWithProgress = JGProgressHUD(style: .light)

let thumbnailScale = 0.25
let wallpaperLimitEachFetch:Int = 15

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
