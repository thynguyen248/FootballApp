//
//  DateExtension.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Foundation

enum AppDateTimeFormat: String {
    case iso = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case normal = "MMM dd, yyyy HH:mm"
}

extension Date {
    func toString(format: String = AppDateTimeFormat.normal.rawValue) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func addDays(numberOfDays: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
        return endDate ?? Date()
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = AppDateTimeFormat.normal.rawValue
        return dateFormatter.date(from: self)
    }
}
