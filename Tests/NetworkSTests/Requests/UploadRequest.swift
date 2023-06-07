//
//  UploadRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

class UploadRequest: MultipartFormDataRequest {

    var url: RequestURL { HttpbinOrgURL.post }
    let paramsArray: [MultipartFormDataParams]
    var boundary: String

    required init(paramsArray: [MultipartFormDataParams]) {
        self.paramsArray = paramsArray
        self.boundary = Self.generateBoundary()
    }
}
