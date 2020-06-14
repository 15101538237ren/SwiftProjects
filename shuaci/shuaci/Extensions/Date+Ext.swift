//
//  Date+Ext.swift
//  shuaci
//
//  Created by Honglei on 5/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation


extension Date {
    func adding(durationVal: Int, durationType: DurationType) -> Date {
        switch durationType {
        case .second:
            return Calendar.current.date(byAdding: .second, value: durationVal, to: self)!
        case .minute:
            return Calendar.current.date(byAdding: .minute, value: durationVal, to: self)!
        case .hour:
            return Calendar.current.date(byAdding: .hour, value: durationVal, to: self)!
        case .day:
            return Calendar.current.date(byAdding: .day, value: durationVal, to: self)!
        case .month:
            return Calendar.current.date(byAdding: .month, value: durationVal, to: self)!
        case .year:
            return Calendar.current.date(byAdding: .year, value: durationVal, to: self)!
        default:
            return Date()
        }
    }
    
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        return localDate
    }
}
