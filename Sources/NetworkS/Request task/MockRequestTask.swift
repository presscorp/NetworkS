//
//  MockRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

class MockRequestTask: UtilizableRequestTask {

    let id = UUID()

    var completion = {}

    var loggingEnabled = false

    var completionHandler: (Data?, URLResponse?, Error?) -> Void

    var urlRequest: URLRequest?

    private let mock: (urlResponse: URLResponse?, data: Data?, error: NSError?)

    init(mock: (URLResponse?, Data?, NSError?), completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.mock = mock
        self.completionHandler = completionHandler
    }

    func run() {
        if loggingEnabled, let request = urlRequest {
            NetworkLogger.log(request: request)
        }
        completionHandler(mock.data, mock.urlResponse, mock.error)
    }

    func stop() {
        completionHandler(nil, nil, NetworkError.cancelled)
    }
}
