//
//  APIClient+matches.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Combine

struct MatchesRequest: Request {
    typealias ReturnType = MatchesResponseModel
    var path: String { return "/teams/matches" }
}

extension APIClient {
    func getMatches() -> AnyPublisher<[MatchModel], AppError> {
        let matchesRequest = MatchesRequest()
        return request(matchesRequest).map { $0.matches ?? [] }.eraseToAnyPublisher()
    }
}
