//
//  CacheRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 17.09.2023.
//

import Foundation

class CacheRequestTask: UtilizableRequestTask {

    let id = UUID()

    var urlRequest: URLRequest?

    var operationCompletion = {}

    var logger: NetworkLogger?

    var responseIsCached: Bool { true }

    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    var cache: (urlResponse: URLResponse, data: Data)?

    func run() {
        guard let completionHandler, let cache else { return }
        
        if let logger, let request = urlRequest {
            logger.log(request: request)
        }

        completionHandler(cache.data, cache.urlResponse, nil)
    }

    func stop() {
        completionHandler?(nil, nil, NetworkError.cancelled)
    }
}
