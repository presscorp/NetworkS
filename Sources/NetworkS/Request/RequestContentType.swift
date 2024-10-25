//
//  RequestContentType.swift
//
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

public enum RequestContentType {

    case json
    case urlEncoded
    case formData(boundary: String)

    var header: String {
        return switch self {
        case .json: "application/json; charset=UTF-8"
        case .urlEncoded: "application/x-www-form-urlencoded; charset=UTF-8"
        case .formData(let boundary): "multipart/form-data; boundary=" + boundary
        }
    }
}
