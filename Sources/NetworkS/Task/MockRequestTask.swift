//
//  MockRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

final class MockRequestTask: UtilizableRequestTask {

    let id = UUID()

    var urlRequest: URLRequest?

    var operationCompletion = {}

    var logger: NetworkLogger?

    var responseIsMocked: Bool { true }

    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    var mock: (urlResponse: URLResponse?, data: Data?, error: Error?)?

    var stopped = false

    func run() {
        stopped = false
        guard let completionHandler, let mock else { return }

        if let logger, let request = urlRequest {
            logger.log(request: request)
        }

        completionHandler(mock.data, mock.urlResponse, mock.error)
    }

    func stop() {
        stopped = true
    }
}
