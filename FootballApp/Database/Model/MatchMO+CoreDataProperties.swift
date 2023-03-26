//
//  MatchMO+CoreDataProperties.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/25/23.
//
//

import Foundation
import CoreData


extension MatchMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchMO> {
        return NSFetchRequest<MatchMO>(entityName: "MatchMO")
    }

    @NSManaged public var away: String?
    @NSManaged public var date: Date?
    @NSManaged public var desc: String?
    @NSManaged public var highlights: String?
    @NSManaged public var home: String?
    @NSManaged public var type: Int64
    @NSManaged public var winner: String?
    @NSManaged public var identifier: String!
    
}

extension MatchMO {
    func update(with matchModel: MatchModel) {
        self.identifier = matchModel.identifier
        self.date = matchModel.date
        self.desc = matchModel.description
        self.home = matchModel.home
        self.winner = matchModel.winner
        self.away = matchModel.away
        self.type = Int64(matchModel.matchType.rawValue)
    }
    
    var matchModel: MatchModel {
        return MatchModel(date: self.date, description: self.desc, home: self.home, winner: self.winner, away: self.away, highlights: self.highlights, matchType: MatchType(rawValue: Int(self.type)) ?? .previous)
    }
}
