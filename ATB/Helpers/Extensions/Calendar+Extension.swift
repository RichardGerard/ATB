//
//  Calendar+Extension.swift
//  ATB
//
//  Created by YueXi on 1/4/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import Foundation

extension Calendar {
    private var currentDate: Date { return Date() }

    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
    }

    func isDateInThisMonth(_ date: Date) -> Bool {
        return isDate(date, equalTo: currentDate, toGranularity: .month)
    }

    func isDateInNextWeek(_ date: Date) -> Bool {
        guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: 1), to: currentDate) else {
          return false
        }
        return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
    }

    func isDateInNextMonth(_ date: Date) -> Bool {
        guard let nextMonth = self.date(byAdding: DateComponents(month: 1), to: currentDate) else {
          return false
        }
        return isDate(date, equalTo: nextMonth, toGranularity: .month)
    }

    func isDateInFollowingMonth(_ date: Date) -> Bool {
        guard let followingMonth = self.date(byAdding: DateComponents(month: 2), to: currentDate) else {
          return false
        }
        
        return isDate(date, equalTo: followingMonth, toGranularity: .month)
    }
}
