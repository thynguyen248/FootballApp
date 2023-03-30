//
//  TeamsViewModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import Foundation
import Combine
import UIKit
import Reachability

final class TeamsViewModel: ViewModelType {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TeamsSection, TeamItemViewModel>
    
    struct Input {
        let loadTrigger: PassthroughSubject<Void, Never>
        let selectedTeams: CurrentValueSubject<[String], Never>
        let isReachable: PassthroughSubject<Bool, Never>
    }
    
    final class Output {
        @Published var snapShot = Snapshot()
        @Published var error: AppError?
        @Published var isLoading = false
    }
    
    private let teamsUseCase: TeamsUseCaseInterface
    private let reachability = try! Reachability()
    
    init(teamsUseCase: TeamsUseCaseInterface = TeamsUseCase()) {
        self.teamsUseCase = teamsUseCase
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        let teamsResultPublisher = Publishers.CombineLatest(input.isReachable,
                                                            input.loadTrigger)
            .flatMap { [teamsUseCase] (isReachable, _) in
                if isReachable {
                    return teamsUseCase.getRemoteTeams()
                        .handleEvents(receiveSubscription: { _ in
                            output.isLoading = true
                        }, receiveOutput: { teams in
                            teamsUseCase.saveTeams(teams)
                        })
                        .asResult()
                }
                return teamsUseCase.getLocalTeams().asResult()
            }
            .receive(on: DispatchQueue.main)
            .share()
            .handleEvents(receiveOutput: { _ in
                output.isLoading = false
            })
            .eraseToAnyPublisher()
        
        Publishers.CombineLatest(teamsResultPublisher,
                                 input.selectedTeams)
        .map { (result, selectedTeams) -> Snapshot in
            if case .success(let models) = result {
                let section = TeamsSection(title: "", teams: models.map { TeamItemViewModel(identifier: $0.id, name: $0.name, logo: $0.logo, isSelected: selectedTeams.contains($0.name ?? "")) })
                var snapshot = Snapshot()
                snapshot.appendSections([section])
                snapshot.appendItems(section.teams, toSection: section)
                return snapshot
            }
            return Snapshot()
        }
        .assign(to: &output.$snapShot)
        
        teamsResultPublisher
            .map { result -> AppError? in
                if case .failure(let error) = result {
                    return error
                }
                return nil
            }
            .filter { $0 != nil }
            .assign(to: &output.$error)
        
        return output
    }
}
