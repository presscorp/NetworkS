//
//  StatusRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

final class StatusRequest: NetworkRequestExtensible {

    var url: RequestURL { HttpbinOrgURL.status(code) }
    var method: RequestMethod { .GET }
    var code = "200"
}
