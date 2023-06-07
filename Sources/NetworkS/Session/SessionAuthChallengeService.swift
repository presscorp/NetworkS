//
//  SessionAuthChallengeService.swift
//  
//
//  Created by Zhalgas Baibatyr on 02.06.2023.
//

import Foundation

protocol SessionAuthChallengeService: AnyObject {

    var defaultSSLChallengeEnabled: Bool { get set }

    var sslCertificates: [NSData] { get set }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}
