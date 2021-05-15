//
//  GlobalVars.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import LeanCloud

var imageCache = NSCache<NSString, NSString>()
var isDisabled: Bool = false
var categories:[Category] = []
var categoryENtoCN:[String : String] = [:]
var english:Bool = false
var failedReason: FailedVerifyReason? = nil

var progressBarVisible: Bool = false
var userLikedWPs:[String] = []

