//
//  UtilRequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 18.07.2023.
//

import Foundation

protocol UtilRequestTask {

    var urlRequest: URLRequest? { get set }

    var operationCompletion: () -> Void { get set }

    var loggingEnabled: Bool { get set }
}

typealias UtilizableRequestTask = RequestTask & UtilRequestTask
