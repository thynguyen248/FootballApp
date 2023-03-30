//
//  TeamDetailViewModelTests.swift
//  FootballAppTests
//
//  Created by Thy Nguyen on 3/30/23.
//

import XCTest
@testable import FootballApp
import Combine
import Foundation

final class TeamDetailViewModelTests: XCTestCase {
    var viewModel: TeamDetailViewModel!
    private var useCase: TeamDetailUseCase!
    private var matchesuseCase: MatchesUseCaseInterface!
    private var loadTrigger: PassthroughSubject<Void, Never>!
    private var input: TeamDetailViewModel.Input!
    private var output: TeamDetailViewModel.Output!
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        let apiClient = APIClientMock()
        let dbHandler = CoreDataStack(inMemory: true)
        let repository = Repository(apiClient: apiClient, dbHandler: dbHandler)
        useCase = TeamDetailUseCase(repository: repository)
        matchesuseCase = MatchesUseCase(repository: repository)
        loadTrigger = PassthroughSubject<Void, Never>()
        viewModel = TeamDetailViewModel(teamName: "Team B", teamDetailUseCase: useCase)
        input = TeamDetailViewModel.Input(loadTrigger: loadTrigger)
        output = viewModel.transform(input: input)
    }
    
    var fakeMatchesData: [MatchModel] = {
        [
            MatchModel(date: Date().addingTimeInterval(-2), description: "Team A vs team B", home: "Team A", winner: "Team A", away: "Team B", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(-1), description: "Team B vs team C", home: "Team B", winner: "Team B", away: "Team C", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(1), description: "Team C vs team D", home: "Team C", winner: "Team C", away: "Team D", highlights: "", matchType: .upcoming)
        ]
    }()
    
    func testTeamDetailTotalInfo() {
        matchesuseCase.saveMatches(fakeMatchesData)
            .sink { [loadTrigger] _ in
                loadTrigger?.send(())
            } receiveValue: { _ in }
            .store(in: &cancellables)

        let expectation = self.expectation(description: "testTeamDetailTotalInfo")
        output.$totalInfo.dropFirst().sink { info in
            XCTAssertEqual(info, "Total: 2 matches")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testTeamDetailPreviousInfo() {
        matchesuseCase.saveMatches(fakeMatchesData)
            .sink { [loadTrigger] _ in
                loadTrigger?.send(())
            } receiveValue: { _ in }
            .store(in: &cancellables)

        let expectation = self.expectation(description: "testTeamDetailPreviousInfo")
        output.$previousInfo.dropFirst().sink { info in
            XCTAssertEqual(info, "Previous: 2 matches (win 1)")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testTeamDetailUpcomingInfo() {
        matchesuseCase.saveMatches(fakeMatchesData)
            .sink { [loadTrigger] _ in
                loadTrigger?.send(())
            } receiveValue: { _ in }
            .store(in: &cancellables)

        let expectation = self.expectation(description: "testTeamDetailUpcomingInfo")
        output.$upcomingInfo.dropFirst().sink { info in
            XCTAssertEqual(info, "Upcoming: 0 matches")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
