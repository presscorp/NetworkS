//
//  TaskOperation.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.06.2023.
//

import Foundation

class TaskOperation: Operation {

    enum State: String { case ready, executing, finished }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }

    override var isAsynchronous: Bool { true }

    override var isExecuting: Bool { state == .executing }

    override var isFinished: Bool {
        if isCancelled && state != .executing { return true }
        return state == .finished
    }

    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func main() {
        guard !isCancelled else { return }
        state = .executing
        closure()
    }
}
