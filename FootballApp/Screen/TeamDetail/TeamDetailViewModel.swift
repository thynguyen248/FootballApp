//
//  TeamDetailViewModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import Foundation

final class TeamDetailViewModel {
    private let teamName: String?
    
    init(teamName: String?) {
        self.teamName = teamName
    }
    
    var title: String? {
        return teamName
    }
}
