//
//  GroupRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class GroupRequestTests: NetworkSTests {

    let taskManager = TaskManager()

    private func createTask(
        _ value: String,
        _ completion: @escaping (_ result: Result<String, NetworkError>) -> Void
    ) -> RequestTask? {
        let request = AnythingRequest(parameters: ["value": value])
        return networkService.buildTask(from: request) { response in
            guard response.success else {
                return completion(.failure(response.error ?? .unknown))
            }

            guard let body = response.jsonBody,
                  let json = body["json"] as? [String: String],
                  let value = json["value"] else {
                return completion(.failure(.unknown))
            }

            completion(.success(value))
        }
    }

    private func fetch(
        initialValues: [String],
        inSequence: Bool = false,
        completion: @escaping (_ values: [String]) -> Void
    ) {
        var values = [String]()

        for initialValue in initialValues {
            let task = createTask(initialValue) { result in
                if case .success(let value) = result {
                    values.append(value)
                }
            }

            if let task = task {
                taskManager.tasks.append(task)
            }
        }

        taskManager.run(inSequence: inSequence) { completion(values) }
    }

    func testGroupRequests() {
        let expectation = expectation(description: #function)

        let initialValues = Array(1...3).map { $0.description }
        fetch(initialValues: initialValues) { values in
            XCTAssert(values.sorted() == initialValues)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testGroupRequestsInSequence() {
        let expectation = expectation(description: #function)

        let initialValues = Array(1...3).map { $0.description }
        fetch(initialValues: initialValues, inSequence: true) { values in
            XCTAssert(values == initialValues)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
