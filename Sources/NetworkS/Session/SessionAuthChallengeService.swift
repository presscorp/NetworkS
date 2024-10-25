//
//  SessionAuthChallengeService.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

protocol SessionAuthChallengeService: AnyObject {

    var sslCertificateCheck: SSLCertificateCheck { get set }

    var sslCertificates: [NSData] { get set }

    var logger: NetworkLogger? { get }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}
