//
//  SessionAuthChallenger.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

protocol SessionAuthChallenger: SessionAuthChallengeService {}

extension SessionAuthChallenger {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let protectionSpace = challenge.protectionSpace
        switch sslCertificateCheck {
        case .enabled(let allowDefault):
            guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = protectionSpace.serverTrust,
                  SecTrustEvaluateWithError(serverTrust, nil),
                  let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                return completionHandler(allowDefault ? .performDefaultHandling : .cancelAuthenticationChallenge, nil)
            }

            let serverCertificateData = SecCertificateCopyData(serverCertificate)
            let data = CFDataGetBytePtr(serverCertificateData)
            let size = CFDataGetLength(serverCertificateData)
            let serverCertData = NSData(bytes: data, length: size)

            let credential = URLCredential(trust: serverTrust)

            for localCertData in sslCertificates {
                guard serverCertData.isEqual(to: localCertData as Data) else { continue }
                return completionHandler(.useCredential, credential)
            }

            completionHandler(allowDefault ? .performDefaultHandling : .cancelAuthenticationChallenge, nil)
        case .disabled:
            let serverTrust = protectionSpace.serverTrust
            let credential = serverTrust.map(URLCredential.init)
            completionHandler(.useCredential, credential)
        }
    }
}
