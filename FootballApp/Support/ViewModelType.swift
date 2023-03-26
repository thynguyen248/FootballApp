//
//  ViewModelType.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

protocol Bindable: AnyObject {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType { get set }
    
    func bindViewModel()
}
