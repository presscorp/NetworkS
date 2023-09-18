//
//  PngImageRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 18.09.2023.
//

import NetworkS

class PngImageRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.imagePng }
    var method: RequestMethod { .GET }
    var encoding: RequestContentEncoding { .url }
    var canRecieveCachedResponse: Bool { true }

    func edit(httpHeaders: inout [String: String]) {
        httpHeaders["accept"] = "image/png"
    }
}
