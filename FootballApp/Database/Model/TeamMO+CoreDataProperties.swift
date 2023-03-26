//
//  TeamMO+CoreDataProperties.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//
//

import Foundation
import CoreData


extension TeamMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMO> {
        return NSFetchRequest<TeamMO>(entityName: "TeamMO")
    }

    @NSManaged public var identifier: String!
    @NSManaged public var name: String?
    @NSManaged public var logo: String?

}

extension TeamMO {
    func update(with teamModel: TeamModel) {
        self.identifier = teamModel.id
        self.name = teamModel.name
        self.logo = teamModel.logo
    }
    
    var teamModel: TeamModel {
        return TeamModel(id: self.identifier, name: self.name, logo: self.logo)
    }
}
