//
//  TaskOperation.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.06.2023.
//

import Foundation

class TaskOperation: Operation, @unchecked Sendable {

    enum State: String {
        case ready, executing, finished
        fileprivate var keyPath: String { "is" + rawValue.capitalized }
    }

    private var requestTask: UtilizableRequestTask?

    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override var isAsynchronous: Bool { true }
    override var isReady: Bool { super.isReady && state == .ready }
    override var isExecuting: Bool { state == .executing }
    override var isFinished: Bool { state == .finished }

    init(requestTask: UtilizableRequestTask) {
        self.requestTask = requestTask
        super.init()
        self.requestTask?.operationCompletion = { [weak self] in self?.state = .finished }
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        main()
        state = .executing
    }

    override func main() {
        requestTask?.run()
    }

    override func cancel() {
        super.cancel()
        requestTask?.stop()
    }
}
