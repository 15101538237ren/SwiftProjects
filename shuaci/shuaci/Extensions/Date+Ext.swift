//
//  Date+Ext.swift
//  shuaci
//
//  Created by Honglei on 5/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation


extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate

        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
    
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
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}
        return localDate
    }
}
