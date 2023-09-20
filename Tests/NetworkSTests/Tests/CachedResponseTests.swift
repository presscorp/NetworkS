//
//  CachedResponseTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 17.09.2023.
//

import XCTest
@testable import NetworkS

final class CachedResponseTests: NetworkSTests {

    private func getTask(completion: @escaping (_ responseHeaders: [String: String]) -> Void) -> RequestTask? {
        let request = PngImageRequest()
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
        getTask { responseHeaders in
            responseHeaders1 = responseHeaders
            expectation1.fulfill()
        }?.run()

        wait(for: [expectation1], timeout: 5)

        let expectation2 = expectation(description: #function + " 2")
        var responseHeaders2 = [String: String]()
        getTask { responseHeaders in
            responseHeaders2 = responseHeaders
            expectation2.fulfill()
        }?.run()

        wait(for: [expectation2], timeout: 1)

        XCTAssertEqual(responseHeaders1, responseHeaders2)
    }

    func testCachedResponse_whenStopped_thenCancel() {
        let request = PngImageRequest()

        let expectation1 = expectation(description: #function + " 1")
        let task1 = networkService.buildTask(from: request) { response in
            XCTAssertTrue(response.success)
            expectation1.fulfill()
        }
        XCTAssertNotNil(task1)
        task1!.run()

        wait(for: [expectation1], timeout: 5)

        let expectation2 = expectation(description: #function + " 2")
        let task2 = networkService.buildTask(from: request) { response in
            XCTAssertNotNil(response.error)
            XCTAssertEqual(response.error!, NetworkError.cancelled)
            expectation2.fulfill()
        }
        XCTAssertNotNil(task2)
        task2!.stop()

        wait(for: [expectation2], timeout: 1)
    }
}
