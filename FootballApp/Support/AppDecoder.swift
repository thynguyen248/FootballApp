//
//  AppDecoder.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/22/23.
//

import UIKit

class AppDecoder {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = AppDateTimeFormat.iso.rawValue
            return formatter
        }()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
