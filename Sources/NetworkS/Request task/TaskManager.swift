//
//  TaskManager.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.06.2023.
//

import Foundation

public class TaskManager {

    private var queue: OperationQueue?

    private var dispatchGroup: DispatchGroup?

    public var tasks = [RequestTask]()

    public init() {}

    public func run(taskIds: [UUID], inSequence: Bool = false, completion: @escaping () -> Void = {}) {
        let filteredTasks = tasks.filter { taskIds.contains($0.id) }
        let lastIndex = filteredTasks.count - 1

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = inSequence ? 1 : filteredTasks.count
        self.queue = queue

        let dispatchGroup = DispatchGroup()
        self.dispatchGroup = dispatchGroup

        for (index, task) in filteredTasks.enumerated() {
            let operation = TaskOperation(requestTask: task)
            operation.completionBlock = { [weak dispatchGroup] in
                if !inSequence || index == lastIndex {
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

    public func run(inSequence: Bool = false, completion: @escaping () -> Void = {}) {
        let ids = tasks.map { $0.id }
        run(taskIds: ids, inSequence: inSequence, completion: completion)
    }
}
