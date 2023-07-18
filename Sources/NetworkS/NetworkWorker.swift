//
//  NetworkWorker.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

/// Worker class intended for making network requests
public class NetworkWorker: NetworkCompose {

    let sessionInterface: NetworkSessionInterface

    ///  Initializer that accepts session interface (adapter) argument
    /// - Parameter sessionInterface: Configured session interface
    public init(sessionInterface: NetworkSessionInterface) {
        self.sessionInterface = sessionInterface
    }
}

extension NetworkWorker: NetworkService {

    public func buildTask(
        from request: some NetworkRequest,
        completion: @escaping ((_ response: NetworkResponse) -> Void)
    ) -> RequestTask? {
        guard let urlRequest = composeUrlRequest(from: request) else {
            return nil
        }

        var requestTask: UtilizableRequestTask?
        let completionHandler = { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            guard let service = self else { return }

            if service.sessionInterface.loggingEnabled {
                NetworkLogger.log(
                    request: urlRequest,
                    response: response as? HTTPURLResponse,
                    responseData: data,
                    error: error as NSError?
                )
            }

            let response = service.composeResponse(from: response, data, error as NSError?)

            if let sessionRenewal = service.sessionInterface.sessionRenewal,
               sessionRenewal.renewIsNeeded(for: request, response) {
                sessionRenewal.renew { [weak self] in
                    guard let service = self else { return }
                    let task = service.buildTask(from: request, completion: completion)
                    task?.run()
                }

                return
            }

            completion(response)

            requestTask?.completion()
        }

        if let url = urlRequest.url, let mockResponse = request.mockResponse {
            let mock = composeMock(from: url, mockResponse)
            requestTask = MockRequestTask(mock: mock, completionHandler: completionHandler)
            requestTask?.urlRequest = urlRequest
        } else {
            if request is MultipartFormDataRequest, let bodyData = urlRequest.httpBody {
                let uploadTask = sessionInterface.uploadTask(
                    with: urlRequest,
                    from: bodyData,
                    completionHandler: completionHandler
                )
                requestTask = NetworkRequestTask(sessionTask: uploadTask)
            } else {
                let dataTask = sessionInterface.dataTask(with: urlRequest, completionHandler: completionHandler)
                requestTask = NetworkRequestTask(sessionTask: dataTask)
            }
        }

        requestTask?.loggingEnabled = sessionInterface.loggingEnabled

        return requestTask
    }
}
