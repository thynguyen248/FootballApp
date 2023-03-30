//
//  TeamDetailUseCase.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/29/23.
//

import Combine

protocol TeamDetailUseCaseInterface {
    func getMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError>
}

final class TeamDetailUseCase: TeamDetailUseCaseInterface {
    private let repository: RepositoryInterface
    
    init(repository: RepositoryInterface = Repository()) {
        self.repository = repository
    }
    
    func getMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError> {
        return repository.getLocalMatches(with: team)
    }
}
