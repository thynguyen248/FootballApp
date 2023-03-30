//
//  MatchesUseCase.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/22/23.
//

import Combine

protocol MatchesUseCaseInterface {
    func getLocalMatches() -> AnyPublisher<[MatchModel], AppError>
    func getRemoteMatches() -> AnyPublisher<[MatchModel], AppError>
    @discardableResult
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError>
}

final class MatchesUseCase: MatchesUseCaseInterface {
    private let repository: RepositoryInterface
    
    init(repository: RepositoryInterface = Repository()) {
        self.repository = repository
    }
    
    func getLocalMatches() -> AnyPublisher<[MatchModel], AppError> {
        return repository.getLocalMatches(with: nil)
    }
    
    func getRemoteMatches() -> AnyPublisher<[MatchModel], AppError> {
        return repository.getRemoteMatches()
    }
    
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError> {
        return repository.saveMatches(matches)
    }
}
