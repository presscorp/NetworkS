//
//  WebViewAuthChallengeService.swift
//
//
//  Created by Zhalgas Baibatyr on 30.10.2023.
//

import WebKit

public protocol WebViewAuthChallengeService: AnyObject {

    var sslCertificateCheck: SSLCertificateCheck { get }

    var sslCertificates: [NSData] { get }

    var logger: NetworkLogger? { get }

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}
