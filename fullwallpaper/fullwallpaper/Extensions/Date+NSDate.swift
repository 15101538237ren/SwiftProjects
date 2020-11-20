//
//  Date+NSDate.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/19/20.
//

import Foundation

extension Date {
    init(date: NSDate) {
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}
