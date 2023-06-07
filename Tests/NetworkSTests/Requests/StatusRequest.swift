//
//  StatusRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

class StatusRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.status(code) }
    var method: RequestMethod { .GET }
    var encoding: RequestContentEncoding { .url }
    var code = "200"
}
