//
//  MockURL.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import NetworkS

struct MockURL: RequestURLExtensible {

    let path: String
    var host: String { "mock.host" }
}

extension MockURL {

    static let mock = Self("/mock")
}

