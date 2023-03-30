//
//  APIClientMock.swift
//  FootballAppTests
//
//  Created by Thy Nguyen on 3/30/23.
//

@testable import FootballApp
import Combine
import Foundation

class APIClientMock: APIClientInterface {
    func getMatches() -> AnyPublisher<[MatchModel], AppError> {
        return Just([
            MatchModel(date: Date().addingTimeInterval(-2), description: "Team A vs team B", home: "Team A", winner: "Team A", away: "Team B", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(-1), description: "Team B vs team C", home: "Team B", winner: "Team B", away: "Team C", highlights: "", matchType: .previous),
            MatchModel(date: Date().addingTimeInterval(1), description: "Team C vs team D", home: "Team C", winner: "Team C", away: "Team D", highlights: "", matchType: .upcoming)])
        .setFailureType(to: AppError.self)
        .eraseToAnyPublisher()
    }
    
    func getTeams() -> AnyPublisher<[TeamModel], AppError> {
        return Just([
            TeamModel(id: "A", name: "Team A", logo: ""),
            TeamModel(id: "B", name: "Team B", logo: ""),
            TeamModel(id: "C", name: "Team C", logo: ""),
            TeamModel(id: "D", name: "Team D", logo: "")])
        .setFailureType(to: AppError.self)
        .eraseToAnyPublisher()
    }
}
