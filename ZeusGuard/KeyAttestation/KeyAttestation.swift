//
//  KeyAttestation.swift
//  ZeusGuard
//
//  Created by Vladimir Dinic on 6.12.22..
//

import Foundation
import DeviceCheck
import CryptoKit

class KeyAttestation {
    
    func perform() {
        
        guard #available(iOS 14.0, *) else {
            print("No support for iOS < 14.0")
            return
        }
        let service = DCAppAttestService.shared
        guard service.isSupported else {    // Maybe we have to remove this because of https://swiftrocks.com/app-attest-apple-protect-ios-jailbreak
            print("Service not supported")
            return
        }
        service.generateKey { keyId, error in
            let challenge = "Challenge key from server"
            guard let challengeData = challenge.data(using: .utf8) else {
                return
            }
            let hash = Data(SHA256.hash(data: challengeData))
            guard let keyId = keyId else {
                return
            }
            service.attestKey(keyId, clientDataHash: hash) { attestation, error in
                guard error == nil else {
                    return
                }
                let attestationString = attestation?.base64EncodedString()  // We sand this back to backend / server
            }
        }
        
    }
    
}
