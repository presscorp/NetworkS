//
//  AuthChallengeRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class AuthChallengeRequestTests: NetworkSTests {

    override func setUp() {
        super.setUp()

        sessionInterface.defaultSSLChallengeEnabled = false
        if let file = Bundle.module.path(forResource: "httpbin.org", ofType: "cer"),
           let certData = NSData(contentsOfFile: file) {
            sessionInterface.sslCertificates = [certData]
        }
    }

    func testRequest() {
        let expectation = expectation(description: #function)

        let request = AnythingRequest(parameters: ["key": "value"])
        let task = networkService.buildTask(from: request) { response in
            guard response.success,
                  let body = response.jsonBody,
                  let dict = body["json"] as? [String: String] else {
                return XCTAssert(false)
            }

            XCTAssert(dict["key"] == "value")
            expectation.fulfill()
        }

        guard let task else { return XCTAssert(false) }
        task.run()

        wait(for: [expectation], timeout: 5)
    }
}
