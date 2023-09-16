//
//  GroupRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import XCTest
@testable import NetworkS

final class GroupRequestTests: NetworkSTests {

    var taskRunner: TaskRunner!

    override func setUp() {
        super.setUp()
        taskRunner = TaskRunner()
    }

    override func tearDown() {
        taskRunner = nil
        super.tearDown()
    }

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

    private func createExpectationsAndTasks(initialValues: [String]) -> ([XCTestExpectation], [RequestTask]) {
        var expectations = [XCTestExpectation]()
        var tasks = [RequestTask]()

        for initialValue in initialValues {
            let expectation = expectation(description: #function + " with value " + initialValue)
            let task = createTask(initialValue) { result in
                if case .success(let value) = result {
                    XCTAssertEqual(initialValue, value)
                }
                expectation.fulfill()
            }

            if let task = task {
                tasks.append(task)
            }

            expectations += [expectation]
        }

        return (expectations, tasks)
    }

    func testGroupRequests() {
        let initialValues = Array(1...3).map { $0.description }
        let (expectations, tasks) = createExpectationsAndTasks(initialValues: initialValues)

        taskRunner.run(tasks)
        wait(for: expectations, timeout: 5)
    }

    func testGroupRequestsInSequence() {
        let initialValues = Array(1...3).map { $0.description }
        let (expectations, tasks) = createExpectationsAndTasks(initialValues: initialValues)

        taskRunner.run(tasks, inSequence: true)
        wait(for: expectations, timeout: 5, enforceOrder: true)
    }
}
