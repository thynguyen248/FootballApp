//
//  DBHandler.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Combine
import Foundation
import CoreData

protocol DBHandlerInterface {
    func fetchMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError>
    @discardableResult
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError>
    func fetchTeams() -> AnyPublisher<[TeamModel], AppError>
    @discardableResult
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError>
}
