//
//  PngImageRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 18.09.2023.
//

import NetworkS

final class PngImageRequest: NetworkRequestExtensible {

    var url: RequestURL { HttpbinOrgURL.imagePng }
    var method: RequestMethod { .GET }
    var canRecieveCachedResponse: Bool { true }

    func edit(httpHeaders: inout [String: String]) {
        httpHeaders["accept"] = "image/png"
    }
}
