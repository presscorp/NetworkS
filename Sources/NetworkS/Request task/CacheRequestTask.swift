//
//  CacheRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 17.09.2023.
//

import Foundation

class CacheRequestTask: UtilizableRequestTask {

    let id = UUID()

    var operationCompletion = {}

    var loggingEnabled = false

    var responseIsCached: Bool { true }

    var completionHandler: (Data?, URLResponse?, Error?) -> Void

    var urlRequest: URLRequest?

    private let cache: (urlResponse: URLResponse, data: Data)

    init(cache: (URLResponse, Data), completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.cache = cache
        self.completionHandler = completionHandler
    }

    func run() {
        if loggingEnabled, let request = urlRequest {
            NetworkLogger.log(request: request)
        }
        completionHandler(cache.data, cache.urlResponse, nil)
    }

    func stop() {
        completionHandler(nil, nil, NetworkError.cancelled)
    }
}
