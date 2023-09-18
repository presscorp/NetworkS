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

    func testCachedRequest() {
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
}
