//
//  GlobalVars.swift
//  fullwallpaper
//
//  Created by Honglei on 11/4/20.
//

import Foundation
import LeanCloud

var imageCache = NSCache<NSString, NSString>()

var categories:[Category] = []

var progressBarVisible: Bool = false
var userLikedWPs:[String] = []
