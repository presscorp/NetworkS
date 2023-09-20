//
//  MockRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

class MockRequestTask: UtilizableRequestTask {

    let id = UUID()

    var urlRequest: URLRequest?

    var operationCompletion = {}

    var logger: NetworkLogger?

    var responseIsMocked: Bool { true }

    var completionHandler: (Data?, URLResponse?, Error?) -> Void

    private let mock: (urlResponse: URLResponse?, data: Data?, error: Error?)

    init(mock: (URLResponse?, Data?, Error?), completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.mock = mock
        self.completionHandler = completionHandler
    }

    func run() {
        if let logger, let request = urlRequest {
            logger.log(request: request)
        }
        completionHandler(mock.data, mock.urlResponse, mock.error)
    }

    func stop() {
        completionHandler(nil, nil, NetworkError.cancelled)
    }
}
