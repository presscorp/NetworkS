//
//  NetworkService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

/// Base service to perform network request
public protocol NetworkService: AnyObject {

    func buildTask(
        from request: some NetworkRequest,
        completion: @escaping ((_ response: NetworkResponse) -> Void)
    ) -> RequestTask?
}
