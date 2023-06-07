//
//  RequestTests.swift
//
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class RequestTests: NetworkSTests {

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

    func testMultipartRequest() {
        let expectation = expectation(description: #function)

        let bundle = Bundle.module
        let image = UIImage(named: "image32x32", in: bundle, with: nil)
        guard let uploadImageData = image?.pngData() else {
            return XCTAssert(false)
        }

        let params = (uploadImageData, "file", "image32x32.png", uploadImageData.mimeType)
        let request = UploadRequest(paramsArray: [params])
        let task = networkService.buildTask(from: request) { response in
            guard response.success,
                  let body = response.jsonBody,
                  let files = body["files"] as? [String: String],
                  let file = files["file"] else {
                return XCTAssert(false)
            }

            func imageData(fromBase64 string: String) -> Data? {
                guard let url = URL(string: string) else { return nil }
                return try? Data(contentsOf: url)
            }

            let downloadImageData = imageData(fromBase64: file)
            XCTAssertEqual(uploadImageData, downloadImageData)

            expectation.fulfill()
        }

        guard let task else { return XCTAssert(false) }
        task.run()

        wait(for: [expectation], timeout: 5)
    }
}
