//
//  AnythingRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation
import NetworkS

final class AnythingRequest: NetworkRequestExtensible {

    var url: RequestURL { HttpbinOrgURL.anything }
    var method: RequestMethod { .POST }
    var contentType: RequestContentType? { .json }
    let body: Data?

    init(dict: [String: Any]) {
        body = Self.json(dict)
    }
}
