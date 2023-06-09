//
//  NetworkRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

class NetworkRequestTask: RequestTask {

    let sessionTask: URLSessionTask

    let id = UUID()

    var urlRequest: URLRequest?

    var completion: () -> Void

    var loggingEnabled = false

    init(sessionTask: URLSessionTask, completion: @escaping () -> Void = {}) {
        self.sessionTask = sessionTask
        self.urlRequest = sessionTask.originalRequest
        self.completion = completion
    }

    func run() {
        if loggingEnabled, let request = sessionTask.originalRequest {
            NetworkLogger.log(request: request)
        }
        sessionTask.resume()
    }

    func stop() {
        sessionTask.cancel()
    }
}
