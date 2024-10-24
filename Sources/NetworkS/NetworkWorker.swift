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

    private func completionHandler(
        request: NetworkRequest,
        completion: @escaping ((_ response: NetworkResponse) -> Void),
        urlRequest: URLRequest,
        requestTask: UtilizableRequestTask?
    ) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { [weak self, weak requestTask] (data: Data?, response: URLResponse?, error: Error?) in
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
                sessionRenewal.renew { [weak self] success in
                    guard success, let service = self else { return }
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
    }
}

extension NetworkWorker: NetworkService {

    public func buildTask(
        from request: NetworkRequest,
        completion: @escaping ((_ response: NetworkResponse) -> Void)
    ) -> RequestTask? {
        guard let urlRequest = composeUrlRequest(from: request) else {
            return nil
        }

        var requestTask: UtilizableRequestTask?
        lazy var completionHandler = completionHandler(
            request: request,
            completion: completion,
            urlRequest: urlRequest,
            requestTask: requestTask
        )

        if let url = urlRequest.url, let mockResponse = request.mockResponse {
            let mockRequestTask = MockRequestTask()
            requestTask = mockRequestTask
            mockRequestTask.mock = composeMock(from: url, mockResponse)
            mockRequestTask.completionHandler = completionHandler
            mockRequestTask.urlRequest = urlRequest
        } else if request.canRecieveCachedResponse,
                  let cache = sessionInterface.cache,
                  let cachedResponse = cache.cachedResponse(for: urlRequest) {
            let cacheRequestTask = CacheRequestTask()
            requestTask = cacheRequestTask
            cacheRequestTask.cache = (cachedResponse.response, cachedResponse.data)
            cacheRequestTask.completionHandler = completionHandler
            cacheRequestTask.urlRequest = urlRequest
        } else {
            if request is MultipartFormDataRequest, let bodyData = urlRequest.httpBody {
                let networkRequestTask = NetworkRequestTask()
                requestTask = networkRequestTask
                networkRequestTask.sessionTask = sessionInterface.uploadTask(
                    with: urlRequest,
                    from: bodyData,
                    completionHandler: completionHandler
                )
            } else {
                let networkRequestTask = NetworkRequestTask()
                requestTask = networkRequestTask
                networkRequestTask.sessionTask = sessionInterface.dataTask(
                    with: urlRequest,
                    completionHandler: completionHandler
                )
            }
        }

        requestTask?.logger = sessionInterface.logger

        return requestTask
    }

    public func clearCachedResponse(for request: NetworkRequest) {
        guard let urlRequest = composeUrlRequest(from: request),
              let cache = sessionInterface.cache else {
            return
        }

        cache.removeCachedResponse(for: urlRequest)
    }

    public func clearAllCachedResponses() {
        guard let cache = sessionInterface.cache else {
            return
        }

        cache.removeAllCachedResponses()
    }
}
