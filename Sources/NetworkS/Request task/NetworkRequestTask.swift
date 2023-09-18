//
//  NetworkRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

class NetworkRequestTask: UtilizableRequestTask {

    let id = UUID()

    var urlRequest: URLRequest?

    var operationCompletion: () -> Void

    var logger: NetworkLogger?

    let sessionTask: URLSessionTask

    init(sessionTask: URLSessionTask, completion: @escaping () -> Void = {}) {
        self.sessionTask = sessionTask
        self.urlRequest = sessionTask.originalRequest
        self.operationCompletion = completion
    }

    func run() {
        if let logger, let request = sessionTask.originalRequest {
            logger.log(request: request)
        }
        sessionTask.resume()
    }

    func stop() {
        sessionTask.cancel()
    }
}
