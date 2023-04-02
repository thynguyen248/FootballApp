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
        @Published var teamName: String?
        @Published var teamLogoUrl: URL?
        @Published var totalInfo: String?
        @Published var previousInfo: String?
        @Published var upcomingInfo: String?
    }
    
    private let teamDetailUseCase: TeamDetailUseCaseInterface
    private let teamName: String?
    private let teamLogo: String?
    
    init(teamName: String?,
         teamLogo: String?,
        teamDetailUseCase: TeamDetailUseCaseInterface = TeamDetailUseCase()) {
        self.teamName = teamName
        self.teamLogo = teamLogo
        self.teamDetailUseCase = teamDetailUseCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        output.teamName = teamName
        
        if let teamLogo = teamLogo {
            output.teamLogoUrl = URL(string: teamLogo)
        }
        
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
