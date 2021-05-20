//
//  Config.swift
//  shuaci
//
//  Created by Honglei on 3/30/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation

public final class Config {
    
    static let share = Config()
    
    let keyUmeng: String = "6063714818b72d2d243df1c6"
    
    /// 上架記得改成 false
    let isEnableUmengLog: Bool = false
    
    let channelID: String = "App Store"
}
