//
//  MultipartFormDataRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

public typealias MultipartFormDataParams = (data: Data, name: String, fileName: String, mimeType: String)

public protocol MultipartFormDataRequest: NetworkRequestExtensible {

    var boundary: String { get }
}

public extension MultipartFormDataRequest {

    var contentType: RequestContentType? { .formData(boundary: boundary) }

    static func multipartFormData(
        from dict: [String: Any] = [:],
        paramsArray: [MultipartFormDataParams],
        boundary: String
    ) -> Data? {
        var data = Data()

        dict.forEach { key, value in
            guard let value = value as? CustomStringConvertible else { return }
            data.append("\r\n--" + boundary + "\r\n")
            data.append("Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n")
            data.append(value.description + "\r\n")
        }

        paramsArray.forEach { param in
            data.append("\r\n--" + boundary + "\r\n")
            data.append("Content-Disposition: form-data; name=\"" + param.name + "\"; filename=\"" + param.fileName)
            data.append("\"\r\nContent-Type: " + param.mimeType + "\r\n\r\n")
            data.append(param.data)
            data.append("\r\n")
        }

        data.append("--" + boundary + "--\r\n")

        return data as Data
    }

    static func newBoundary() -> String { "Boundary-" + UUID().uuidString }
}

fileprivate extension Data {

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
