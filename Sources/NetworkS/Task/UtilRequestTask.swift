//
//  UtilRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 18.07.2023.
//

import Foundation

typealias UtilizableRequestTask = RequestTask & UtilRequestTask

protocol UtilRequestTask {

    var operationCompletion: () -> Void { get set }

    var logger: NetworkLogger? { get set }

    var responseIsCached: Bool { get }

    var responseIsMocked: Bool { get }

    var stopped: Bool { get }
}

extension UtilRequestTask {

    var responseIsCached: Bool { false }

    var responseIsMocked: Bool { false }
}
