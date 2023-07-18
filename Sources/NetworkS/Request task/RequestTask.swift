//
//  RequestTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

public protocol RequestTask: AnyObject {

    var id: UUID { get }

    var urlRequest: URLRequest? { get set }

    func run()

    func stop()
}
