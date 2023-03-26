//
//  TeamsUseCase.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import Combine

protocol TeamsUseCaseInterface {
    func getLocalTeams() -> AnyPublisher<[TeamModel], AppError>
    func getRemoteTeams() -> AnyPublisher<[TeamModel], AppError>
    @discardableResult
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError>
}

final class TeamsUseCase: TeamsUseCaseInterface {
    private let repository: RepositoryInterface
    
    init(repository: RepositoryInterface = Repository()) {
        self.repository = repository
    }
    
    func getLocalTeams() -> AnyPublisher<[TeamModel], AppError> {
        return repository.getLocalTeams()
    }
    
    func getRemoteTeams() -> AnyPublisher<[TeamModel], AppError> {
        return repository.getRemoteTeams()
    }
    
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError> {
        return repository.saveTeams(teams)
    }
}
