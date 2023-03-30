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
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let selectedTeams = CurrentValueSubject<[String], Never>([])
    private let isReachable = PassthroughSubject<Bool, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        let apiClient = APIClientMock()
        let dbHandler = CoreDataStack(inMemory: true)
        let repository = Repository(apiClient: apiClient, dbHandler: dbHandler)
        useCase = MatchesUseCase(repository: repository)
        viewModel = MatchesViewModel(matchesUseCase: useCase)
        input = MatchesViewModel.Input(loadTrigger: loadTrigger, selectedTeams: selectedTeams, isReachable: isReachable)
        output = viewModel.transform(input: input)
    }
    
    func testSnapShot() {
        loadTrigger.send(())
        isReachable.send(true)
        selectedTeams.send([])
        let expectation = self.expectation(description: "testSnapShot")
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

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
