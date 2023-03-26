//
//  MatchesSection.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/22/23.
//

import UIKit

class MatchesSection: Hashable {
    let identifier = UUID()
    let title: String
    let matches: [MatchItemViewModel]
    
    init(title: String, matches: [MatchItemViewModel]) {
        self.title = title
        self.matches = matches
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: MatchesSection, rhs: MatchesSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct MatchItemViewModel: Hashable {
    let identifier: String
    let date: String?
    let description: String?
    let home: String?
    let away: String?
    let highlights: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: MatchItemViewModel, rhs: MatchItemViewModel) -> Bool {
      lhs.identifier == rhs.identifier
    }
}

extension MatchItemViewModel {
    init(with matchModel: MatchModel) {
        self.identifier = matchModel.identifier
        self.date = matchModel.date?.toString()
        self.description = matchModel.description
        self.home = (matchModel.home ?? "") + (matchModel.home == matchModel.winner ? " (winner)" : "")
        self.away = (matchModel.away ?? "") + (matchModel.away == matchModel.winner ? " (winner)" : "")
        self.highlights = matchModel.highlights
    }
}
