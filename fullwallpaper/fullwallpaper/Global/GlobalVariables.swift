//
//  GlobalVars.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import LeanCloud

var imageCache = NSCache<NSString, NSString>()
var isProValid: Bool = false
var isDisabled: Bool = false
var categories:[Category] = []
var categoryENtoCN:[String : String] = [:]

var progressBarVisible: Bool = false
var userLikedWPs:[String] = []
var testMode: Bool = false // load scene before learning
var switchesLoaded: Bool = false // load scene before learning

