//
//  NetworkRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

public protocol NetworkRequest: AnyObject {

    var method: RequestMethod { get }

    var url: RequestURL { get }

    var queryParameters: [String: CustomStringConvertible?] { get }

    var contentType: RequestContentType? { get }

    var body: Data? { get }

    var timeoutInterval: TimeInterval? { get }

    var mockResponse: NetworkResponse? { get }

    var canRecieveCachedResponse: Bool { get }

    func edit(httpHeaders: inout [String: String])
}
