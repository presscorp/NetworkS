//
//  MockRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation
import NetworkS

final class MockRequest: NetworkRequestExtensible {

    var url: RequestURL { MockURL.mock }
    var method: RequestMethod { .POST }
    var contentType: RequestContentType? { .json }
    let dict: [String: Any]
    let body: Data?

    var mockResponse: NetworkResponse? {
        let data = try? JSONSerialization.data(withJSONObject: dict)
        return SuccessResponse(statusCode: 200, body: data, headers: [:])
    }

    init(dict: [String: Any]) {
        self.dict = dict
        body = Self.json(dict)
    }
}
