//
//  AnythingRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

class AnythingRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.anything }
    var method: RequestMethod { .POST }
    var encoding: RequestContentEncoding { .json }
    let parameters: [String: Any]

    init(parameters: [String: Any]) {
        self.parameters = parameters
    }
}
