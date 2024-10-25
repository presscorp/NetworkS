//
//  NetworkRequestExtensible.swift
//  NetworkS
//
//  Created by Zhalgas Baibatyr on 24.10.2024.
//

import Foundation

public protocol NetworkRequestExtensible: NetworkRequest {}

public extension NetworkRequestExtensible {

    var queryParameters: [String: CustomStringConvertible?] { [:] }

    var contentType: RequestContentType? { nil }

    var body: Data? { nil }

    var timeoutInterval: TimeInterval? { nil }

    var mockResponse: NetworkResponse? { nil }

    var canRecieveCachedResponse: Bool { false }

    func edit(httpHeaders: inout [String: String]) {}

    static func json<T: Encodable>(_ object: T) -> Data? { try? JSONEncoder().encode(object) }

    static func json(_ dict: [String: Any]) -> Data? {
        let jsonObject = dict.compactMapValues { $0 }
        guard JSONSerialization.isValidJSONObject(jsonObject),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        return data
    }

    static func urlEncoded(_ dict: [String: Any]) -> Data? {
        let parameters = dict.reduce("") { (result: String, pair: (String, Any)) -> String in
            guard let value = pair.1 as? CustomStringConvertible else { return "" }
            return result + (result.isEmpty ? "" : "&") + pair.0 + "=" + value.description
        }
        return parameters.data(using: .utf8)
    }
}
