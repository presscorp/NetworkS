//
//  MockRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class MockRequestTests: NetworkSTests {

    func testMock() {
        let expectation = expectation(description: #function)

        let request = MockRequest(parameters: ["key": "value"])
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

        wait(for: [expectation], timeout: 5)
    }

    func testMeockedRequest_whenStopped_thenCancel() {
        let expectation = expectation(description: #function)

        let request = MockRequest(parameters: ["key": "value"])
        let task = networkService.buildTask(from: request) { response in
            XCTAssertNotNil(response.error)
            XCTAssertEqual(response.error!, NetworkError.cancelled)
            expectation.fulfill()
        }

        XCTAssertNotNil(task)
        task!.stop()

        wait(for: [expectation], timeout: 5)
    }
}
