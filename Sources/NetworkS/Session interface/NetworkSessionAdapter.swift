//
//  NetworkSessionAdapter.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation
import Network

/// Classic implementation of adapter between fundamental network session and its worker (request maker);
/// It's much better to use worker (NetworkService) instead of applying adapter directly for network tasks
public class NetworkSessionAdapter: SessionAuthChallenger, SessionLifeCycle, NetworkConnectionChecker {

    public var defaultSSLChallengeEnabled = false

    public var sslCertificates = [NSData]()

    public var additionalHTTPHeaders = [String: String]()

    public weak var sessionRenewal: SessionRenewalService?

    public var loggingEnabled = false

    private lazy var session = setNewSession()

    private let sessionDelegate = SessionDelegationHandler()

    var dataKeepers = [Int: SessionTaskDataKeeper]()

    var networkIsReachable = false

    let connectionMonitor = NWPathMonitor()

    let connectionMonitorQueue = DispatchQueue(label: String(describing: NetworkConnectionChecker.self))

    public required init() {
        sessionDelegate.authChallenge = self
        sessionDelegate.lifeCycle = self
        runConnectionMonitor()
    }

    deinit {
        stopConnectionMonitor()
    }
}

extension NetworkSessionAdapter: NetworkSessionInterface {

    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request)
        let dataKeeper = SessionTaskDataKeeper(completionHandler)
        sessionDelegate.lifeCycle?.dataKeepers[dataTask.taskIdentifier] = dataKeeper
        return dataTask
    }

    public func uploadTask(
        with request: URLRequest,
        from bodyData: Data,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask {
        let uploadTask = session.uploadTask(with: request, from: bodyData)
        let dataKeeper = SessionTaskDataKeeper(completionHandler)
        sessionDelegate.lifeCycle?.dataKeepers[uploadTask.taskIdentifier] = dataKeeper
        return uploadTask
    }

    public func setNewSession(
        configuration: URLSessionConfiguration = URLSession.shared.configuration,
        delegateQueue: OperationQueue? = .main
    ) -> URLSession {
        let configuration = URLSession.shared.configuration
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: delegateQueue
        )
        return session
    }

    public func networkIsAvailable() -> Bool { networkIsReachable }
}
