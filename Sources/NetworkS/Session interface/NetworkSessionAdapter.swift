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

    public weak var sessionRenewal: SessionRenewalService?

    public var logger: NetworkLogger?

    public private(set) var completionQueue: OperationQueue?

    public private(set) weak var cache: URLCache?

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

    @discardableResult
    public func setNewSession(
        configuration: URLSessionConfiguration = URLSession.shared.configuration,
        delegateQueue: OperationQueue? = nil,
        completionQueue: OperationQueue? = nil
    ) -> URLSession {
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: delegateQueue
        )
        self.completionQueue = completionQueue
        self.cache = configuration.urlCache
        return session
    }

    public var additionalHTTPHeaders: [String: String] {
        guard let httpAdditionalHeaders = session.configuration.httpAdditionalHeaders else { return [:] }
        var headers = [String: String]()
        for (key, value) in httpAdditionalHeaders {
            guard let key = key as? String, let value = value as? String else { continue }
            headers[key] = value
        }
        return headers
    }

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

    public func networkIsAvailable() -> Bool { networkIsReachable }
}
