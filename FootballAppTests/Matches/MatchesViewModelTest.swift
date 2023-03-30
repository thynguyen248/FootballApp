//
//  MatchesViewModelTest.swift
//  FootballAppTests
//
//  Created by Thy Nguyen on 3/30/23.
//

import XCTest
@testable import FootballApp
import Combine
import Foundation

final class MatchesViewModelTest: XCTestCase {
    var viewModel: MatchesViewModel!
    private var useCase: MatchesUseCaseInterface!
    private var input: MatchesViewModel.Input!
    private var output: MatchesViewModel.Output!
    private var loadTrigger: PassthroughSubject<Void, Never>!
    private var selectedTeams: CurrentValueSubject<[String], Never>!
    private var isReachable: PassthroughSubject<Bool, Never>!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        let apiClient = APIClientMock()
        let dbHandler = CoreDataStack(inMemory: true)
        let repository = Repository(apiClient: apiClient, dbHandler: dbHandler)
        useCase = MatchesUseCase(repository: repository)
        viewModel = MatchesViewModel(matchesUseCase: useCase)
        loadTrigger = PassthroughSubject<Void, Never>()
        selectedTeams = CurrentValueSubject<[String], Never>([])
        isReachable = PassthroughSubject<Bool, Never>()
        input = MatchesViewModel.Input(loadTrigger: loadTrigger, selectedTeams: selectedTeams, isReachable: isReachable)
        output = viewModel.transform(input: input)
    }
    
    func testSnapShotOnlineMode() {
        loadTrigger.send(())
        isReachable.send(true)
        selectedTeams.send([])
        let expectation = self.expectation(description: "testSnapShotOnlineMode")
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 2)
            let section0 = snapShot.sectionIdentifiers[0]
            let section1 = snapShot.sectionIdentifiers[1]
            XCTAssertEqual(section0.title, "Upcoming")
            XCTAssertEqual(section1.title, "Previous")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 1)
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[1]), 2)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testSnapShotOnlineModeWithSelectedTeam() {
        let selectedTeams = ["Team B"]
        loadTrigger.send(())
        isReachable.send(true)
        self.selectedTeams.send(selectedTeams)
        let expectation = self.expectation(description: "testSnapShotOnlineModeWithSelectedTeam")
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 1)
            let section0 = snapShot.sectionIdentifiers[0]
            XCTAssertEqual(section0.title, "Previous")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 2)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testSnapShotOfflineMode() {
        let expectation = self.expectation(description: "testSnapShotOfflineMode")
        useCase.saveMatches([
//            MatchModel(date: Date().addingTimeInterval(-2), description: "Team A vs team B", home: "Team A", winner: "Team A", away: "Team B", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(-1), description: "Team B vs team C", home: "Team B", winner: "Team B", away: "Team C", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(1), description: "Team C vs team D", home: "Team C", winner: "Team C", away: "Team D", highlights: "", matchType: .upcoming),
            MatchModel(date: Date().addingTimeInterval(2), description: "Team D vs team E", home: "Team D", winner: "Team D", away: "Team E", highlights: "", matchType: .upcoming)])
        .sink(receiveCompletion: { [weak self] _ in
            self?.loadTrigger.send(())
            self?.isReachable.send(false)
            self?.selectedTeams.send([])
        }, receiveValue: { _ in })
        .store(in: &cancellables)
        
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 2)
            let section0 = snapShot.sectionIdentifiers[0]
            let section1 = snapShot.sectionIdentifiers[1]
            XCTAssertEqual(section0.title, "Upcoming")
            XCTAssertEqual(section1.title, "Previous")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 2)
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[1]), 1)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
