//
//  MatchesViewModel.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Foundation
import Combine
import UIKit

final class MatchesViewModel: ViewModelType {
    typealias Snapshot = NSDiffableDataSourceSnapshot<MatchesSection, MatchItemViewModel>
    
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
    
    private let matchesUseCase: MatchesUseCaseInterface
    
    init(matchesUseCase: MatchesUseCaseInterface = MatchesUseCase()) {
        self.matchesUseCase = matchesUseCase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let matchesResultPublisher = Publishers.CombineLatest(input.isReachable,
                                                              input.loadTrigger)
            .flatMap { [matchesUseCase] (isReachable, _) in
                if isReachable {
                    return matchesUseCase.getRemoteMatches()
                        .handleEvents(receiveSubscription: { _ in
                            output.isLoading = true
                        }, receiveOutput: { matches in
                            matchesUseCase.saveMatches(matches)
                        })
                        .asResult()
                }
                return matchesUseCase.getLocalMatches().asResult()
            }
            .receive(on: DispatchQueue.main)
            .share()
            .handleEvents(receiveOutput: { _ in
                output.isLoading = false
            })
            .eraseToAnyPublisher()
        
        Publishers.CombineLatest(matchesResultPublisher,
                                 input.selectedTeams)
            .map { (result, selectedTeams) -> Snapshot in
                if case .success(let matches) = result {
                    var selectedMatches: [MatchModel] = []
                    if selectedTeams.isEmpty {
                        selectedMatches = matches
                    } else {
                        let homeDic = Dictionary(grouping: matches) { $0.home }
                        let awayDic = Dictionary(grouping: matches) { $0.away }
                        for team in selectedTeams {
                            selectedMatches += homeDic[team] ?? []
                            selectedMatches += awayDic[team] ?? []
                        }
                        //Remove duplicated matches
                        selectedMatches = Array(Set(selectedMatches))
                    }
                    let dic = Dictionary.init(grouping: selectedMatches) { $0.matchType }
                    let sections = dic
                        .sorted(by: { $0.key.title > $1.key.title })
                        .map {
                            let items = $0.value.map { MatchItemViewModel(with: $0) }
                            return MatchesSection(title: $0.key.title, matches: items)
                        }
                    var snapshot = Snapshot()
                    snapshot.appendSections(sections)
                    sections.forEach { section in
                        snapshot.appendItems(section.matches, toSection: section)
                    }
                    
                    return snapshot
                }
                return Snapshot()
            }
            .assign(to: &output.$snapShot)
        
        matchesResultPublisher
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
