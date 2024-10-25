//
//  TaskRunner.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.06.2023.
//

import Foundation

public final class TaskRunner {

    private var queue: OperationQueue?

    private var dispatchGroup: DispatchGroup?

    public init() {}

    public func run(_ tasks: [RequestTask], inSequence: Bool = false, completion: @escaping () -> Void = {}) {
        let tasks = tasks.compactMap { $0 as? UtilizableRequestTask }

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = inSequence ? 1 : tasks.count
        self.queue = queue

        let dispatchGroup = DispatchGroup()
        self.dispatchGroup = dispatchGroup

        for (index, task) in tasks.enumerated() {
            let operation = TaskOperation(requestTask: task)
            operation.completionBlock = { [weak dispatchGroup] in
                if !inSequence || index == tasks.count - 1 {
                    dispatchGroup?.leave()
                }
            }

            if !inSequence || index == 0 { dispatchGroup.enter() }
            queue.addOperation(operation)
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            completion()
            if let self {
                self.queue = nil
                self.dispatchGroup = nil
            }
        }
    }

    public func stopTasks() {
        queue?.cancelAllOperations()
    }
}
