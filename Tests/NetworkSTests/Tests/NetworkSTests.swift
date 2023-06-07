//
//  NetworkSTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

class NetworkSTests: XCTestCase {

    let sessionInterface: NetworkSessionInterface = {
        let sessionAdapter = NetworkSessionAdapter()
        sessionAdapter.defaultSSLChallengeEnabled = true
        sessionAdapter.loggingEnabled = true
        return sessionAdapter
    }()

    lazy var networkService: NetworkService = NetworkWorker(sessionInterface: sessionInterface)
}
