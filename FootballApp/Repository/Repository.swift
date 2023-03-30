//
//  Repository.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Combine
import CoreData

protocol RepositoryInterface {
    func getLocalMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError>
    func getRemoteMatches() -> AnyPublisher<[MatchModel], AppError>
    @discardableResult
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError>
    
    func getLocalTeams() -> AnyPublisher<[TeamModel], AppError>
    func getRemoteTeams() -> AnyPublisher<[TeamModel], AppError>
    @discardableResult
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError>
}

final class Repository: RepositoryInterface {
    private let apiClient: APIClientInterface
    private let dbHandler: DBHandlerInterface
    
    init(apiClient: APIClientInterface = APIClient(),
         dbHandler: DBHandlerInterface = CoreDataStack.shared) {
        self.apiClient = apiClient
        self.dbHandler = dbHandler
    }
    
    func getLocalMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError> {
        return dbHandler.fetchMatches(with: team)
    }
    
    func getRemoteMatches() -> AnyPublisher<[MatchModel], AppError> {
        return apiClient.getMatches()
    }
    
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError> {
        return dbHandler.saveMatches(matches)
    }
    
    func getLocalTeams() -> AnyPublisher<[TeamModel], AppError> {
        return dbHandler.fetchTeams()
    }
    
    func getRemoteTeams() -> AnyPublisher<[TeamModel], AppError> {
        return apiClient.getTeams()
    }
    
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError> {
        return dbHandler.saveTeams(teams)
    }
}
