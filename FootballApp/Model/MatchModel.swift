//
//  MatchModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Foundation

enum MatchType: Int {
    case previous = 0
    case upcoming
    
    var title: String {
        switch self {
        case .previous: return "Previous"
        case .upcoming: return "Upcoming"
        }
    }
}

struct MatchesResponseModel: Decodable {
    enum OuterKeys: String, CodingKey {
        case matches
    }
    enum MatchesKeys: String, CodingKey {
        case previous, upcoming
    }
    
    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
        let matchesContainer = try outerContainer.nestedContainer(keyedBy: MatchesKeys.self, forKey: .matches)
        let previous = try matchesContainer.decode([MatchModel].self, forKey: .previous)
        var upcoming = try matchesContainer.decode([MatchModel].self, forKey: .upcoming)
        for i in 0..<upcoming.count {
            upcoming[i].matchType = .upcoming
        }
        self.matches = previous + upcoming
    }
    
    let matches: [MatchModel]?
}

struct MatchModel: Decodable, Hashable {
    let date: Date?
    let description: String?
    let home: String?
    let winner: String?
    let away: String?
    let highlights: String?
    var matchType: MatchType = .previous
    
    enum CodingKeys: String, CodingKey {
        case date, description, home, winner, away, highlights
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: MatchModel, rhs: MatchModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var identifier: String {
        return (date?.toString() ?? "") + (description ?? "")
    }
}
