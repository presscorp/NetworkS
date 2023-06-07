//
//  SessionRenewalTest.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class SessionRenewalTest: NetworkSTests {

    let request = StatusRequest()

    override func setUp() {
        super.setUp()
        request.code = "401"
        sessionInterface.sessionRenewal = self
    }

    func testSessionRenewal() {
        let expectation = expectation(description: #function)

        let task = networkService.buildTask(from: request) { response in
            XCTAssert(response.success)
            expectation.fulfill()
        }

        task?.run()

        wait(for: [expectation], timeout: 5)
    }
}

extension SessionRenewalTest: SessionRenewalService {

    func renew(completion: () -> Void) {
        request.code = "200"
        completion()
    }
}
