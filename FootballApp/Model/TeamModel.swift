//
//  TeamModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Foundation

struct TeamsResponseModel: Decodable {
    let teams: [TeamModel]?
}

struct TeamModel: Decodable {
    let id: String
    let name: String?
    let logo: String?
}
