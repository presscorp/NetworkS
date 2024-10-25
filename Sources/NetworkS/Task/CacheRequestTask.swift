//
//  CacheRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 17.09.2023.
//

import Foundation

final class CacheRequestTask: UtilizableRequestTask {

    let id = UUID()

    var urlRequest: URLRequest?

    var operationCompletion = {}

    var logger: NetworkLogger?

    var responseIsCached: Bool { true }

    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    var cache: (urlResponse: URLResponse, data: Data)?

    var stopped = false

    func run() {
        stopped = false
        guard let completionHandler, let cache else { return }

        if let logger, let request = urlRequest {
            logger.log(request: request)
        }

        completionHandler(cache.data, cache.urlResponse, nil)
    }

    func stop() {
        stopped = true
    }
}
