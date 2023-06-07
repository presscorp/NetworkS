//
//  SessionLifeCycleService.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

protocol SessionLifeCycleService: AnyObject {

    var dataKeepers: [Int: SessionTaskDataKeeper] { get set }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    )

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}
