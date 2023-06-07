//
//  SessionLifeCycle.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

protocol SessionLifeCycle: SessionLifeCycleService {}

extension SessionLifeCycle {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let dataKeeper = dataKeepers[dataTask.taskIdentifier]
        guard let dataKeeper else { return completionHandler(.cancel) }
        dataKeeper.response = response
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let completionMaker = dataKeepers[dataTask.taskIdentifier] else { return }
        if completionMaker.data == nil {
            completionMaker.data = Data()
        }
        completionMaker.data?.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let dataKeeper = dataKeepers[task.taskIdentifier] else { return }
        dataKeeper.error = error
        dataKeepers.removeValue(forKey: task.taskIdentifier)
        dataKeeper.handleCompletion()
    }
}
