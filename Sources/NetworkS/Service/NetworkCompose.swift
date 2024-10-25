//
//  NetworkCompose.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

protocol NetworkCompose {

    var sessionInterface: NetworkSessionInterface { get }
}

extension NetworkCompose {

    func composeUrlRequest(from request: NetworkRequest) -> URLRequest? {
        // Compose full URL path
        let composedUrl: URL
        guard var urlComponents = URLComponents(string: request.url.absolutePath) else { return nil }
        urlComponents.percentEncodedQueryItems = request.queryParameters.compactMap { name, anyValue -> URLQueryItem? in
            guard var value = anyValue?.description else { return nil }
            if value.removingPercentEncoding == value,
               let percentEncodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                value = percentEncodedValue
            }
            return URLQueryItem(name: name, value: value)
        }
        guard let url = urlComponents.url else { return nil }
        composedUrl = url

        // Compose URLRequest
        var urlRequest = URLRequest(url: composedUrl)
        urlRequest.httpMethod = request.method.rawValue
        if let timeoutInterval = request.timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        // Form headers
        var allHTTPHeaderFields = [String: String]()
        request.contentType.map { allHTTPHeaderFields["Content-Type"] = $0.header }
        sessionInterface.additionalHTTPHeaders.forEach { allHTTPHeaderFields[$0] = $1 }
        request.edit(httpHeaders: &allHTTPHeaderFields)
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields

        // Set body
        urlRequest.httpBody = request.body

        return urlRequest
    }

    func composeResponse(from urlResponse: URLResponse?, _ data: Data?, _ error: Error?) -> NetworkResponse {
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            if let error = error as? NetworkError {
                switch error {
                case .cancelled: return FailureResponse.cancelled
                case .timeout: return FailureResponse.timeout
                case .unknown: return FailureResponse.unknown
                case .notAvailable: return FailureResponse.notAvailable
                default: break
                }
            } else if let error = error as NSError? {
                switch error.code {
                case NSURLErrorCancelled: return FailureResponse.cancelled
                case NSURLErrorTimedOut: return FailureResponse.timeout
                default: return FailureResponse.server(code: error.code, error: error)
                }
            }
            return FailureResponse.unknown
        }

        guard 200..<300 ~= httpUrlResponse.statusCode else {
            return FailureResponse(
                statusCode: httpUrlResponse.statusCode,
                error: .server(error as? NSError),
                body: data,
                headers: httpUrlResponse.allHeaderFields
            )
        }

        return SuccessResponse(
            statusCode: httpUrlResponse.statusCode,
            body: data,
            headers: httpUrlResponse.allHeaderFields
        )
    }

    func composeMock(
        from url: URL,
        _ response: NetworkResponse
    ) -> (urlResponse: URLResponse?, data: Data?, error: Error?) {
        var headerFields = [String: String]()
        response.headers.forEach { key, value in
            guard let key = key as? String, let value = value as? String else { return }
            headerFields[key] = value
        }

        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: response.statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )

        return (urlResponse, response.body, error: response.error)
    }
}
