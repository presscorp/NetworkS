//
//  ConsoleLogger.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

public class ConsoleLogger {

    private let formatter = NetworkLogFormatter()

    public init() {}
}

extension ConsoleLogger: NetworkLogger {

    /// Network request logging
    public func log(request: URLRequest) {
        let log = formatter.printableLog(request: request)
        print(log)
    }

    /// Network response logging
    public func log(
        request: URLRequest,
        response: HTTPURLResponse?,
        responseData: Data?,
        error: Error?,
        responseIsCached: Bool,
        responseIsMocked: Bool
    ) {
        let log = formatter.printableLog(
            request: request,
            response: response,
            responseData: responseData,
            error: error,
            responseIsCached: responseIsCached,
            responseIsMocked: responseIsMocked
        )
        print(log)
    }
}
