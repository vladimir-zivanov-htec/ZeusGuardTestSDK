//
//  CertificatePinningManager.swift
//  ZeusGuard
//
//  Created by Vladimir Dinic on 8.12.22..
//

import Foundation

class CertificatePinningManager {
    
}

class SessionManagerDelegate: NSObject, URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust), let serverTrust = challenge.protectionSpace.serverTrust {
            var secresult = SecTrustResultType.invalid
            let statusSuccess: Bool = {
                if #available(iOS 13.0, *) {
                    return SecTrustEvaluateWithError(serverTrust, nil)
                } else {
                    return SecTrustEvaluate(serverTrust, &secresult) == errSecSuccess
                }
            }()

            if (statusSuccess) {
                if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
                    let data = CFDataGetBytePtr(serverCertificateData);
                    let size = CFDataGetLength(serverCertificateData);
                    let cert1 = NSData(bytes: data, length: size)
                    let file_der = Bundle.main.path(forResource: "cert", ofType: "cer") // Must be exported in der format

                    if let file = file_der {
                        if let cert2 = NSData(contentsOfFile: file) {
                            print("Cert1 \(cert1.count)")
                            print("Cert2 \(cert2.count)")
                            if cert1.isEqual(to: cert2 as Data) {
                                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                return
                            }
                        }
                    }
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
        
}
