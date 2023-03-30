//
//  TeamsViewModelTests.swift
//  FootballAppTests
//
//  Created by Thy Nguyen on 3/30/23.
//

import XCTest
@testable import FootballApp
import Combine
import Foundation

final class TeamsViewModelTests: XCTestCase {
    var viewModel: TeamsViewModel!
    private var useCase: TeamsUseCaseInterface!
    private var input: TeamsViewModel.Input!
    private var output: TeamsViewModel.Output!
    private var loadTrigger: PassthroughSubject<Void, Never>!
    private var selectedTeams: CurrentValueSubject<[String], Never>!
    private var isReachable: PassthroughSubject<Bool, Never>!
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        let apiClient = APIClientMock()
        let dbHandler = CoreDataStack(inMemory: true)
        let repository = Repository(apiClient: apiClient, dbHandler: dbHandler)
        useCase = TeamsUseCase(repository: repository)
        viewModel = TeamsViewModel(teamsUseCase: useCase)
        loadTrigger = PassthroughSubject<Void, Never>()
        selectedTeams = CurrentValueSubject<[String], Never>([])
        isReachable = PassthroughSubject<Bool, Never>()
        input = TeamsViewModel.Input(loadTrigger: loadTrigger, selectedTeams: selectedTeams, isReachable: isReachable)
        output = viewModel.transform(input: input)
    }
    
    func testTeamsOnlineMode() {
        loadTrigger.send(())
        isReachable.send(true)
        let expectation = self.expectation(description: "testTeamsOnlineMode")
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 1)
            let section0 = snapShot.sectionIdentifiers[0]
            XCTAssertEqual(section0.title, "")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 4)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testTeamsOnlineModeWithSelectedTeam() {
        let selectedTeams = ["Team B", "Team C"]
        loadTrigger.send(())
        isReachable.send(true)
        self.selectedTeams.send(selectedTeams)
        let expectation = self.expectation(description: "testTeamsOnlineModeWithSelectedTeam")
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 1)
            let section0 = snapShot.sectionIdentifiers[0]
            let item0 = snapShot.itemIdentifiers(inSection: section0).first(where: { $0.name == "Team A" })
            let item1 = snapShot.itemIdentifiers(inSection: section0).first(where: { $0.name == "Team B" })
            let item2 = snapShot.itemIdentifiers(inSection: section0).first(where: { $0.name == "Team C" })
            let item3 = snapShot.itemIdentifiers(inSection: section0).first(where: { $0.name == "Team D" })
            XCTAssertTrue([item1?.isSelected ?? false, item2?.isSelected ?? false].allSatisfy { $0 })
            XCTAssertTrue([item0?.isSelected ?? false, item3?.isSelected ?? false].allSatisfy { !$0 })
            XCTAssertEqual(section0.title, "")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 4)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }
    
    func testTeamsOfflineMode() {
        let expectation = self.expectation(description: "testSnapShotOfflineMode")
        useCase.saveTeams([
            TeamModel(id: "A", name: "Team A", logo: ""),
            TeamModel(id: "B", name: "Team B", logo: ""),
            TeamModel(id: "C", name: "Team C", logo: "")])
        .sink(receiveCompletion: { [weak self] _ in
            self?.loadTrigger.send(())
            self?.isReachable.send(false)
        }, receiveValue: { _ in })
        .store(in: &cancellables)
        
        output.$snapShot.dropFirst().sink { snapShot in
            XCTAssertEqual(snapShot.numberOfSections, 1)
            let section0 = snapShot.sectionIdentifiers[0]
            XCTAssertEqual(section0.title, "")
            XCTAssertEqual(snapShot.numberOfItems(inSection: snapShot.sectionIdentifiers[0]), 3)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 30)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
