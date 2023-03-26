//
//  TeamsSection.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import UIKit

class TeamsSection: Hashable {
    let identifier = UUID()
    let title: String
    let teams: [TeamItemViewModel]
    
    init(title: String, teams: [TeamItemViewModel]) {
        self.title = title
        self.teams = teams
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: TeamsSection, rhs: TeamsSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct TeamItemViewModel: Hashable {
    let identifier: String
    let name: String?
    let logo: String?
    var isSelected = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: TeamItemViewModel, rhs: TeamItemViewModel) -> Bool {
      lhs.identifier == rhs.identifier
    }
    
    var logoUrl: URL? {
        guard let logo = logo else { return nil }
        return URL(string: logo)
    }
}

extension TeamItemViewModel {
    init(with teamModel: TeamModel) {
        self.identifier = teamModel.id
        self.name = teamModel.name
        self.logo = teamModel.logo
    }
}
