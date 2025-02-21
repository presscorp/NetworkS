//
//  NetworkSTests.swift
//
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

class NetworkSTests: XCTestCase {

    var sessionInterface: NetworkSessionInterface!

    var networkService: NetworkService!

    override func setUp() {
        super.setUp()

        let sessionAdapter = NetworkSessionAdapter()
        sessionAdapter.sslCertificateCheck = .enabled(allowDefault: true)
        sessionAdapter.logger = ConsoleLogger()
        sessionInterface = sessionAdapter

        networkService = NetworkWorker(sessionInterface: sessionInterface)
    }

    override func tearDown() {
        networkService = nil
        sessionInterface = nil
        super.tearDown()
    }
}
