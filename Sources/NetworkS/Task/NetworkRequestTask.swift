//
//  NetworkRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

final class NetworkRequestTask: UtilizableRequestTask {

    let id = UUID()

    private(set) var urlRequest: URLRequest?

    var operationCompletion = {}

    var logger: NetworkLogger?

    var stopped: Bool { sessionTask?.state == .canceling }

    var sessionTask: URLSessionTask? {
        didSet { urlRequest = sessionTask?.originalRequest }
    }

    func run() {
        guard let sessionTask, sessionTask.state != .running else { return }

        if let logger, let request = urlRequest {
            logger.log(request: request)
        }

        sessionTask.resume()
    }

    func stop() {
        guard let sessionTask, sessionTask.state == .running else { return }
        sessionTask.cancel()
    }
}
