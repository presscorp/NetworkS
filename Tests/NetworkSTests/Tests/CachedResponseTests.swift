//
//  CachedResponseTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 17.09.2023.
//

import XCTest
@testable import NetworkS

final class CachedResponseTests: NetworkSTests {

    var request: NetworkRequest!

    override func setUp() {
        super.setUp()

        request = PngImageRequest()
    }

    override func tearDown() {
        request = nil

        super.tearDown()
    }

    private func getTask(completion: @escaping (_ responseHeaders: [String: String]) -> Void) -> RequestTask? {
        return networkService.buildTask(from: request) { response in
            XCTAssert(response.success)
            var responseHeaders = [String: String]()
            for (key, value) in response.headers {
                guard let key = key as? String, let value = value as? String else {
                    continue
                }
                responseHeaders[key] = value
            }

            completion(responseHeaders)
        }
    }

    func testCachedResponse() {
        let expectation1 = expectation(description: #function + " 1")
        var responseHeaders1 = [String: String]()
        let task1 = getTask { responseHeaders in
            responseHeaders1 = responseHeaders
            expectation1.fulfill()
        }
        XCTAssertNotNil(task1)
        task1!.run()

        wait(for: [expectation1], timeout: 5)

        let expectation2 = expectation(description: #function + " 2")
        var responseHeaders2 = [String: String]()
        let task2 = getTask { responseHeaders in
            responseHeaders2 = responseHeaders
            expectation2.fulfill()
        }
        XCTAssertNotNil(task2)
        task2!.run()

        wait(for: [expectation2], timeout: 1)

        XCTAssertEqual(responseHeaders1, responseHeaders2)
    }

    func testClearCachedResponseForRequest() {
        let expectation1 = expectation(description: #function + " 1")
        var responseHeaders1 = [String: String]()
        let task1 = getTask { responseHeaders in
            responseHeaders1 = responseHeaders
            expectation1.fulfill()
        }

        XCTAssertNotNil(task1)
        task1!.run()

        wait(for: [expectation1], timeout: 5)

        let expectation2 = expectation(description: #function + " 2")
        var responseHeaders2 = [String: String]()
        let task2 = getTask { responseHeaders in
            responseHeaders2 = responseHeaders
            expectation2.fulfill()
        }

        XCTAssertNotNil(task2)
        task2!.run()

        wait(for: [expectation2], timeout: 1)

        XCTAssertEqual(responseHeaders1, responseHeaders2)

        networkService.clearCachedResponse(for: request)

        sleep(1)

        let expectation3 = expectation(description: #function + " 3")
        var responseHeaders3 = [String: String]()
        let task3 = getTask { responseHeaders in
            responseHeaders3 = responseHeaders
            expectation3.fulfill()
        }

        XCTAssertNotNil(task3)
        task3!.run()

        wait(for: [expectation3], timeout: 5)

        XCTAssertNotEqual(responseHeaders2, responseHeaders3)
    }
}
