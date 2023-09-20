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
            defer { requestTask?.operationCompletion() }

            guard let service = self else { return }

            if let logger = service.sessionInterface.logger {
                logger.log(
                    request: urlRequest,
                    response: response as? HTTPURLResponse,
                    responseData: data,
                    error: error,
                    responseIsCached: requestTask?.responseIsCached ?? false,
                    responseIsMocked: requestTask?.responseIsMocked ?? false
                )
            }

            let response = service.composeResponse(from: response, data, error)

            if let sessionRenewal = service.sessionInterface.sessionRenewal,
               sessionRenewal.renewIsNeeded(for: request, response) {
                sessionRenewal.renew { [weak self] in
                    guard let service = self else { return }
                    let task = service.buildTask(from: request, completion: completion)
                    task?.run()
                }

                return
            }

            if let queue = service.sessionInterface.completionQueue {
                queue.addOperation { completion(response) }
            } else {
                completion(response)
            }
        }

        if let url = urlRequest.url, let mockResponse = request.mockResponse {
            let mock = composeMock(from: url, mockResponse)
            requestTask = MockRequestTask(mock: mock, completionHandler: completionHandler)
            requestTask?.urlRequest = urlRequest
        } else if request.canRecieveCachedResponse,
                  let cache = sessionInterface.cache,
                  let cachedResponse = cache.cachedResponse(for: urlRequest) {
            let cache = (cachedResponse.response, cachedResponse.data)
            requestTask = CacheRequestTask(cache: cache, completionHandler: completionHandler)
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

        requestTask?.logger = sessionInterface.logger

        return requestTask
    }
}
