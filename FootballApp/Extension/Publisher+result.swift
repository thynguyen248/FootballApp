//
//  Publisher+result.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/24/23.
//

import Combine

extension Publisher {
    func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
