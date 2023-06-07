//
//  NetworkSessionInterface.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

/// Interface between fundamental network session and its worker (request maker)
public protocol NetworkSessionInterface: AnyObject {

    /// Common HTTP headers applied to all requests made within this session
    var additionalHTTPHeaders: [String: String] { get set }

    /// Default SSL certificate handling for the challenge
    var defaultSSLChallengeEnabled: Bool { get set }

    /// SSL certificates stored as binary data
    var sslCertificates: [NSData] { get set }

    /// Service intended for session renewal in case of specified condition (check for authorized request);
    /// Normally used to sign requests with updated authorization token
    var sessionRenewal: SessionRenewalService? { get set }

    /// Indication of log printing of request / response into the console
    var loggingEnabled: Bool { get set }

    init()

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask

    func uploadTask(
        with request: URLRequest,
        from bodyData: Data,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask

    /// Set new instance of URLSession
    /// - Parameters:
    ///   - configuration: A configuration object that specifies certain behaviors, such as caching policies, timeouts, proxies, pipelining, TLS versions to
    ///   support, cookie policies, and credential storage.
    ///   - delegateQueue: An operation queue for scheduling the delegate calls and completion handlers. The queue should be a serial queue, in order to ensure
    ///    the correct ordering of callbacks. If nil, the session creates a serial operation queue for performing all delegate method calls and completion handler
    ///    calls.
    /// - Returns: An object that coordinates a group of related, network data transfer tasks.
    @discardableResult
    func setNewSession(configuration: URLSessionConfiguration, delegateQueue: OperationQueue?) -> URLSession

    /// Network availability indicator
    /// - Returns: Boolean value that indicates whether network connection is available or not
    func networkIsAvailable() -> Bool
}
