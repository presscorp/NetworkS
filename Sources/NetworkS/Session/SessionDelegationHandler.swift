//
//  SessionDelegationHandler.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

class SessionDelegationHandler: NSObject {

    weak var authChallenge: SessionAuthChallengeService?

    weak var lifeCycle: SessionLifeCycleService?
}

extension SessionDelegationHandler: URLSessionDelegate {

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let authChallenge = authChallenge else {
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }

        authChallenge.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
}

extension SessionDelegationHandler: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let lifeCycle {
            lifeCycle.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
}

extension SessionDelegationHandler: URLSessionDataDelegate {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let lifeCycle = lifeCycle else { return completionHandler(.allow) }
        lifeCycle.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let lifeCycle = lifeCycle else { return }
        lifeCycle.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
