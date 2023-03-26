//
//  APIClient+teams.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Combine

struct TeamsRequest: Request {
    typealias ReturnType = TeamsResponseModel
    var path: String { return "/teams" }
}

extension APIClient {
    func getTeams() -> AnyPublisher<[TeamModel], AppError> {
        let teamsRequest = TeamsRequest()
        return request(teamsRequest).map { $0.teams ?? [] }.eraseToAnyPublisher()
    }
}
