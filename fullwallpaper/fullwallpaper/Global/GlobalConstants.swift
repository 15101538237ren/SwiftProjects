//
//  GlobalConstant.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import Foundation
import UIKit

let numberOfItemsPerRow:CGFloat = CGFloat(3)
let cellSpacing:CGFloat = CGFloat(2)
let cellHeightWidthRatio:CGFloat = CGFloat(1.5)

let categoryJsonFileName = "Category.json"

let OkTxt = "好的"
let loadingTxt = "正在加载.."
let NoNetWorkStr = "没有网络,请检查网络连接"


enum CacheType {
    case image
    case json
}
