//
//  AppStoreReviewManager.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/15/20.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
      let defaults = UserDefaults.standard
      let bundle = Bundle.main
      let numReviewAsked = defaults.integer(forKey: NumReviewAskedKey)
      let bundleVersionKey = kCFBundleVersionKey as String
      let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
      if numReviewAsked > maxNumReviewAsk{
         defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
         return
      }
        
      let actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
      // 5.
      guard actionCount % minimumReviewWorthyActionCount == 0 else {
        return
      }

      // 6.
      let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

      // 7.
      guard lastVersion == nil || lastVersion != currentVersion else {
        return
      }

      // 8.
      SKStoreReviewController.requestReview()

      // 9.
        defaults.set(0, forKey: .reviewWorthyActionCount)
        defaults.set(numReviewAsked + 1, forKey: NumReviewAskedKey)
    }
}
