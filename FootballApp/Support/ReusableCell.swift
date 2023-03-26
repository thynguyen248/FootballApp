//
//  ReusableCell.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/22/23.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
