//
//  SessionRenewalService.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

/// Service for session renewal
public protocol SessionRenewalService: AnyObject {

    /// Session renewal request;
    /// Implementing this method check if renew process is already launched with regard of `renewIsNeeded`
    func renew(completion: () -> Void)

    /// Necessity for session renewal check
    /// - Parameters:
    ///   - request: Composed network request
    ///   - response: Generated network response
    /// - Returns: Boolean that indicates if session renewal is necessary
    func renewIsNeeded(for request: NetworkRequest, _ response: NetworkResponse) -> Bool
}

public extension SessionRenewalService {

    func renewIsNeeded(for request: NetworkRequest, _ response: NetworkResponse) -> Bool {
        return response.statusCode == 401
    }
}
