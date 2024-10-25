//
//  UploadRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation
import NetworkS

final class UploadRequest: MultipartFormDataRequest {

    var url: RequestURL { HttpbinOrgURL.post }
    var method: RequestMethod { .POST }
    let boundary: String
    let body: Data?

    init(paramsArray: [MultipartFormDataParams]) {
        boundary = Self.newBoundary()
        body = Self.multipartFormData(paramsArray: paramsArray, boundary: boundary)
    }
}
