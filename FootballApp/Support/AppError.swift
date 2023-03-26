//
//  AppError.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError(_ message: String)
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case dbFetchError(_ message: String)
    case dbInsertError(_ message: String)
}
