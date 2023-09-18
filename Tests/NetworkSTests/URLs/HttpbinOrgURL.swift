//
//  HttpbinOrgURL.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

struct HttpbinOrgURL: RequestURLExtensible {

    let path: String
    var host: String { "httpbin.org" }
}

extension HttpbinOrgURL {

    static let anything = Self("/anything")

    static let post = Self("/post")

    static let imagePng = Self("/image/png")

    static func status(_ code: String) -> Self {
        Self("/status/" + code)
    }
}
