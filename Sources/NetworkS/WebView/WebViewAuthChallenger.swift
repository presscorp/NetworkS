//
//  WebViewAuthChallenger.swift
//
//
//  Created by Zhalgas Baibatyr on 30.10.2023.
//

import WebKit

public protocol WebViewAuthChallenger: WebViewAuthChallengeService {}

public extension WebViewAuthChallenger {

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        var disposition: URLSession.AuthChallengeDisposition
        var credential: URLCredential?
        defer { completionHandler(disposition, credential) }

        let protectionSpace = challenge.protectionSpace
        switch sslCertificateCheck {
        case .enabled(let allowDefault):
            guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = protectionSpace.serverTrust,
                  SecTrustEvaluateWithError(serverTrust, nil),
                  let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                disposition = allowDefault ? .performDefaultHandling : .cancelAuthenticationChallenge
                return
            }

            let serverCertificateData = SecCertificateCopyData(serverCertificate)
            let data = CFDataGetBytePtr(serverCertificateData)
            let size = CFDataGetLength(serverCertificateData)
            let serverCertData = NSData(bytes: data, length: size)

            let urlCredential = URLCredential(trust: serverTrust)

            for localCertData in sslCertificates {
                guard serverCertData.isEqual(to: localCertData as Data) else { continue }
                disposition = .useCredential
                credential = urlCredential
                return
            }

            if allowDefault {
                disposition = .performDefaultHandling
                let text = "⚠️ Fell for default SSL certificate handling for " + challenge.protectionSpace.host + " ⚠️"
                logger?.log(message: text)
            } else {
                disposition = .cancelAuthenticationChallenge
            }
        case .disabled:
            let serverTrust = protectionSpace.serverTrust
            let urlCredential = serverTrust.map(URLCredential.init)
            disposition = .useCredential
            credential = urlCredential
        }
    }
}
