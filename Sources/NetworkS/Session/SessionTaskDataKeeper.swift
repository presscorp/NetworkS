//
//  SessionTaskDataKeeper.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

class SessionTaskDataKeeper {

    var response: URLResponse?

    var data: Data?

    var error: Error?

    private let completionHandler: (Data?, URLResponse?, Error?) -> Void

    init(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completionHandler = completionHandler
    }

    func handleCompletion() { completionHandler(data, response, error) }
}
