//
//  TeamDetailViewModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import Foundation
import Combine

final class TeamDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: PassthroughSubject<Void, Never>
    }
    
    final class Output {
        @Published var title: String?
        @Published var totalInfo: String?
        @Published var previousInfo: String?
        @Published var upcomingInfo: String?
    }
    
    private let teamDetailUseCase: TeamDetailUseCaseInterface
    private let teamName: String?
    
    init(teamName: String?,
        teamDetailUseCase: TeamDetailUseCaseInterface = TeamDetailUseCase()) {
        self.teamName = teamName
        self.teamDetailUseCase = teamDetailUseCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        output.title = teamName
        
        let totalMatchesResultPublisher =
        input.loadTrigger
            .flatMap { [teamName, teamDetailUseCase] in
                teamDetailUseCase.getMatches(with: teamName)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
        
        totalMatchesResultPublisher
            .map { result in
                if case .success(let matches) = result {
                    return "Total: \(matches.count) matches"
                }
                return nil
            }
            .assign(to: &output.$totalInfo)
        
        totalMatchesResultPublisher
            .map { [weak self] result in
                if case .success(let matches) = result {
                    let previousCount = matches.filter { $0.matchType == .previous }.count
                    let winCount = matches.filter { $0.winner == self?.teamName }.count
                    return "Previous: \(previousCount) matches (win \(winCount))"
                }
                return nil
            }
            .assign(to: &output.$previousInfo)
        
        totalMatchesResultPublisher
            .map { result in
                if case .success(let matches) = result {
                    let upcomingCount = matches.filter { $0.matchType == .upcoming }.count
                    return "Upcoming: \(upcomingCount) matches"
                }
                return nil
            }
            .assign(to: &output.$upcomingInfo)
        
        return output
    }
}
