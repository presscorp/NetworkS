//
//  MockRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class MockRequestTests: NetworkSTests {

    func testMockedResponse() {
        let expectation = expectation(description: #function)

        let request = MockRequest(dict: ["key": "value"])
        let task = networkService.buildTask(from: request) { response in
            guard response.success,
                  let dict = response.jsonBody as? [String: String] else {
                return XCTAssert(false)
            }

            XCTAssert(dict["key"] == "value")
            expectation.fulfill()
        }

        XCTAssertNotNil(task)
        task!.run()

        wait(for: [expectation], timeout: 1)
    }
}
